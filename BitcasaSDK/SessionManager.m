//
//  SessionManager.m
//  BitcasaSDK
//
//  Created by Olga on 9/11/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import "SessionManager.h"
#import "BitcasaAPI.h"

static SessionManager* _sharedManager;
NSString * const kBackgroundSessionIdentifier = @"com.Bitcasa.backgroundSession";

@interface SessionManager ()

@property (nonatomic, strong) NSOperationQueue *backgroundURLQueue;

@end

@implementation SessionManager

+ (instancetype)sharedManager
{
    dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[SessionManager alloc] init];
    });
    
    return _sharedManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.backgroundURLQueue = [[NSOperationQueue alloc] init];
        [self setupBackgroundURLSessionWithIdentifier:kBackgroundSessionIdentifier];
    }
    return self;
}

- (void)setupBackgroundURLSessionWithIdentifier:(NSString*)indentifier
{
    if (self.backgroundSession)
    {
        _backgroundSession = [NSURLSession sessionWithConfiguration:_backgroundSession.configuration delegate:self
                                                             delegateQueue:_backgroundURLQueue];
    }
    else
    {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfiguration:indentifier];
        sessionConfiguration.discretionary = NO;
        sessionConfiguration.requestCachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
        sessionConfiguration.allowsCellularAccess = YES;
        
        _backgroundSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:_backgroundURLQueue];
    }
}

#pragma mark - NSURLSession delegate
- (void) URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    if ([_delegate respondsToSelector:@selector(itemAtPath:didCompleteDownloadToURL:error:)])
        [_delegate itemAtPath:downloadTask.taskDescription didCompleteDownloadToURL:location error:nil];
}

- (void) URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    if ([_delegate respondsToSelector:@selector(itemAtPath:didDownload:outOfTotal:)])
        [_delegate itemAtPath:downloadTask.taskDescription didDownload:totalBytesWritten outOfTotal:totalBytesExpectedToWrite];
}

- (void) URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    // can't resume downloads yet
}

- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if ([_delegate respondsToSelector:@selector(itemAtPath:didCompleteDownloadToURL:error:)])
        [_delegate itemAtPath:task.taskDescription didCompleteDownloadToURL:nil error:error];
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    if (session == _backgroundSession)
    {
        _backgroundSession = nil;
        [self setupBackgroundURLSessionWithIdentifier:kBackgroundSessionIdentifier];
    }
}

#pragma mark - NSURLConnectionData delegate
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if ([_delegate respondsToSelector:@selector(fileAtPath:didUpload:outOfTotal:)])
    {
        NSString* requestURLString = [[connection originalRequest].URL absoluteString];
        [_delegate fileAtPath:requestURLString didUpload:bytesWritten outOfTotal:totalBytesWritten];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self finalizeUploadConnection:connection withError:nil];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self finalizeUploadConnection:connection withError:error];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([_delegate respondsToSelector:@selector(fileAtPath:didReceiveResponse:)])
    {
        NSString* requestURLString = [[connection originalRequest].URL absoluteString];
        [_delegate fileAtPath:requestURLString didReceiveResponse:response];
    }

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{

}

- (void)finalizeUploadConnection:(NSURLConnection *)connection withError:(NSError *)error
{
    if ([_delegate respondsToSelector:@selector(fileAtPath:didCompleteUploadWithError:)])
    {
        NSString* requestURLString = [[connection originalRequest].URL absoluteString];
        [_delegate fileAtPath:requestURLString didCompleteUploadWithError:error];
    }
}

@end
