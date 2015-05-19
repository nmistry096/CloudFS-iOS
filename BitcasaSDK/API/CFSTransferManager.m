//
//  CFSTransferManager.m
//  BitcasaSDK
//
//  Bitcasa iOS SDK
//  Copyright (C) 2015 Bitcasa, Inc.
//  1200 Park Place, Suite 350
//  San Mateo, CA 94403
//
//  All rights reserved.
//
//  For support, please send email to sdks@bitcasa.com.
//

#import "CFSTransferManager.h"
#import "CFSFile.h"
#import "CFSRestAdapter.h"
#import "CFSErrorUtil.h"

static CFSTransferManager* _sharedManager;

@implementation CFSTransfer

@end


@interface CFSTransferManager ()

@property (nonatomic, strong) NSMutableDictionary *transfers;
@property (nonatomic, weak) CFSRestAdapter *restAdapter;
@property (nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;
@property (nonatomic, strong) NSOperationQueue *foregroundURLQueue;

@end

@implementation CFSTransferManager

- (instancetype)initWithRestAdapter:(CFSRestAdapter *)restAdapter
{
    self = [super init];
    if (self) {
        self.restAdapter =  restAdapter;
        
        self.sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.foregroundURLQueue = [[NSOperationQueue alloc] init];
        self.foregroundURLSession = [NSURLSession sessionWithConfiguration:self.sessionConfiguration
                                                                  delegate:self
                                                             delegateQueue:self.foregroundURLQueue];
        
        _sharedManager = self;
        self.transfers = [NSMutableDictionary dictionary];
    }
    
    return self;
}

#pragma mark - NSURLSession delegates
#pragma mark - NSURLSession Data Tasks
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
    CFSTransfer *transfer = self.transfers[@(dataTask.taskIdentifier)];
    transfer.statusCode = statusCode;
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    CFSTransfer *transfer = self.transfers[@(dataTask.taskIdentifier)];
    [transfer.data appendData:data];
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    CFSTransfer *transfer = self.transfers[@(task.taskIdentifier)];
    
    if (((transfer.statusCode < 200 ||
          transfer.statusCode > 299) &&
         transfer.statusCode != 0) ||
         error != nil) {
         transfer.error = [CFSErrorUtil createErrorFrom:transfer.data
                                             statusCode:transfer.statusCode
                                                  error:error];
    } else {
        if (transfer.data.length) {
            NSError* err;
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:transfer.data
                                                                         options:NSJSONReadingAllowFragments
                                                                           error:&err];
            if (responseDict) {
                transfer.file = [[CFSFile alloc] initWithDictionary:responseDict[@"result"]
                                                 andParentContainer:transfer.destContainer
                                                     andRestAdapter:_restAdapter];
            }
        }
    }
    
    if (transfer.completionHandler) {
        transfer.completionHandler(task.taskIdentifier, transfer.path, transfer.file, transfer.error);
    }
    
    [self removeTransferForTask:task];
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    CFSTransfer *transfer = self.transfers[@(task.taskIdentifier)];
    CFSFileTransferRedirect redirect = transfer.redirectHandler;
    
    BOOL proceed = YES;
    if (redirect) {
        redirect(task.taskIdentifier, transfer.path, response, &proceed);
    }
    
    if (proceed) {
        completionHandler(request);
    } else {
        completionHandler(NULL);
    }
}

#pragma mark - Download Tasks
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    CFSTransfer *transfer = self.transfers[@(downloadTask.taskIdentifier)];
    transfer.statusCode = [(NSHTTPURLResponse *)downloadTask.response statusCode];
    NSError *error = nil;
    CFSError *cfsError = nil;
    
    if (transfer.statusCode >= 200 && transfer.statusCode < 300) {
        if ([fileManager fileExistsAtPath:transfer.path]) {
            [fileManager removeItemAtPath:transfer.path error:&error];
        }
        
        [fileManager copyItemAtPath:[location path] toPath:transfer.path error:&error];

        cfsError = [CFSErrorUtil errorWithError:error];
    } else {
        NSError *jsonError = nil;
        cfsError = [CFSErrorUtil createErrorFrom:[NSData dataWithContentsOfFile:[location path]]
                                        response:downloadTask.response
                                           error:jsonError];
    }
    
    transfer.error = cfsError;
}

- (void)URLSession:(NSURLSession *)session
     downloadTask:(NSURLSessionDownloadTask *)downloadTask
     didWriteData:(int64_t)bytesWritten
totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    CFSTransfer *transfer = self.transfers[@(downloadTask.taskIdentifier)];
    transfer.statusCode = [(NSHTTPURLResponse *)downloadTask.response statusCode];
    
    if (transfer.statusCode >= 200 && transfer.statusCode < 300) {
        if (transfer.progressHandler) {
            transfer.progressHandler(downloadTask.taskIdentifier, transfer.path, totalBytesWritten, transfer.size);
        }
    }
}

#pragma mark - Upload Tasks
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    CFSTransfer *transfer = self.transfers[@(task.taskIdentifier)];
    CFSFileTransferProgress progress = transfer.progressHandler;
    progress(task.taskIdentifier, transfer.path, totalBytesSent, transfer.size);
}

#pragma mark - Public Methods
- (void)addTransferForUploadTask:(NSURLSessionTask *)uploadTask
                            path:(NSString *)path
                            size:(int64_t)size
                   destContainer:(CFSContainer *)destContainer
                        progress:(CFSFileTransferProgress)progress
                      completion:(CFSFileTransferCompletion)completion
{
    CFSTransfer *uploadTransfer = [[CFSTransfer alloc] init];
    uploadTransfer.progressHandler = progress;
    uploadTransfer.completionHandler = completion;
    uploadTransfer.path = path;
    uploadTransfer.size = size;
    uploadTransfer.data = [NSMutableData data];
    uploadTransfer.destContainer = destContainer;
    uploadTask.taskDescription = [NSString stringWithFormat:@"%p", self];
    self.transfers[@(uploadTask.taskIdentifier)] = uploadTransfer;
}

- (void)addTransferForDownloadTask:(NSURLSessionTask *)downloadTask
                              path:(NSString *)path
                              file:(CFSFile *)file
                          progress:(CFSFileTransferProgress)progress
                        completion:(CFSFileTransferCompletion)completion
{
    [self addTransferForDownloadTask:downloadTask
                                path:path
                                file:file
                            progress:progress
                          completion:completion
                            redirect:nil];
}

- (void)addTransferForDownloadTask:(NSURLSessionTask *)downloadTask
                              path:(NSString *)path
                              file:(CFSFile *)file
                          progress:(CFSFileTransferProgress)progress
                        completion:(CFSFileTransferCompletion)completion
                          redirect:(CFSFileTransferRedirect)redirect
{
    CFSTransfer *downloadTransfer = [[CFSTransfer alloc] init];
    downloadTransfer.progressHandler = progress;
    downloadTransfer.completionHandler = completion;
    downloadTransfer.redirectHandler = redirect;
    downloadTransfer.path = path;
    downloadTransfer.size = file.size;
    downloadTransfer.file = file;
    downloadTask.taskDescription = [NSString stringWithFormat:@"%p", self];
    self.transfers[@(downloadTask.taskIdentifier)] = downloadTransfer;
}

#pragma mark - Private Methods
- (void)removeTransferForTask:(NSURLSessionTask *)task
{
    [self.transfers removeObjectForKey:@(task.taskIdentifier)];
}

@end
