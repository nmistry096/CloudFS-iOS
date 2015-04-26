//
//  CFSTransferManager.h
//  BitcasaSDK
//
//  Bitcasa iOS SDK
//  Copyright (C) 2015 Bitcasa, Inc.
//  215 Castro Street, 2nd Floor
//  Mountain View, CA 94041
//
//  All rights reserved.
//
//  For support, please send email to support@bitcasa.com.
//

#import <Foundation/Foundation.h>
#import "CFSRestAdapter.h"

#pragma mark - CFSTransfer
/*!
 *  Contains details related to a specific file upload or download task.
 */
@interface CFSTransfer : NSObject

/*!
 *  The completion handler to be invoked when the task is completed.
 */
@property (nonatomic, copy) CFSFileTransferCompletion completionHandler;

/*!
 *  The progress object representing the progress of the upload or download task.
 */
@property (nonatomic, copy) CFSFileTransferProgress progressHandler;

/*!
 *  The redirect block to execute when a HTTP redirection happens.
 */
@property (nonatomic, copy) CFSFileTransferRedirect redirectHandler;

/*!
 *  The remote path if it is an upload. Local path if it is a download.
 */
@property (nonatomic, copy) NSString *path;

/*!
 *  The size of the file which is uploaded or downloaded.
 */
@property (nonatomic, assign) int64_t size;

/*!
 *  The HTTP response status code of the file transfer.
 */
@property (nonatomic, assign) NSInteger statusCode;

/*!
 *  The identifier of the transfer. Same as the data task identifier which performs the upload or download.
 */
@property (nonatomic, assign) NSInteger transferId;

/*!
 *  Holds the received data for this task of the response body (JSON); not the actual data of the file being uploaded or downloaded.
 */
@property (nonatomic, strong) NSMutableData *data;

/*!
 * The destination container if the transfer is for a file upload.
 */
@property (nonatomic, strong) CFSContainer *destContainer;

/*!
 *  The file object associated with this file transfer. If it is a upload, this is assigned after the completion.
 */
@property (nonatomic, strong) CFSFile *file;

/*!
 *  Holds an error object if any occurs during the transfer period and passed to completion. 
 */
@property (nonatomic, strong) CFSError *error;

@end

#pragma mark - CFSTransferManager
@interface CFSTransferManager : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate, NSURLConnectionDataDelegate>

/*!
 *  The background URL Session used for file downloads.
 */
@property (nonatomic, strong) NSURLSession *backgroundURLSession;

/*!
 *  The foreground URL Session used for file uploads.
 */
@property (nonatomic, strong) NSURLSession *foregroundURLSession;

- (instancetype)init NS_UNAVAILABLE;

/*!
 *  Initializes a CFSTransferManager with given rest adapter.
 *
 *  @param restAdapter A CFSRestAdapter object which is used to set on CFSItem objects.
 *
 *  @return An initialized CFSTrasnferManager instance.
 */
- (instancetype)initWithRestAdapter:(CFSRestAdapter *)restAdapter NS_DESIGNATED_INITIALIZER;

/*!
 *  Adds progress handler and completion handler for the upload task.
 *
 *  @param uploadTask       The upload task progress object and handler should be associated with.
 *  @param path             The upload path of the file.
 *  @param size             The size of the file.
 *  @param destContainer    Destination container which file is uploaded to.
 *  @param progress         Block to call with the progress of the upload.
 *  @param completion       The handler which is called upon completion of the upload.
 */
- (void)addTransferForUploadTask:(NSURLSessionTask *)uploadTask
                            path:(NSString *)path
                            size:(int64_t)size
                   destContainer:(CFSContainer *)destContainer
                        progress:(CFSFileTransferProgress)progress
                      completion:(CFSFileTransferCompletion)completion;

/*!
 *  Adds progress handler and completion handler for the download task.
 *
 *  @param downloadTask     The download task progress object and handler should be associated with.
 *  @param path             The local download path.
 *  @param file             The file object associated with the download.
 *  @param progress         Block to call with the progress of the download.
 *  @param completion       The handler which is called upon completion of the download.
 */
- (void)addTransferForDownloadTask:(NSURLSessionTask *)downloadTask
                              path:(NSString *)path
                              file:(CFSFile *)file
                          progress:(CFSFileTransferProgress)progress
                        completion:(CFSFileTransferCompletion)completion;

/*!
 *  Adds progress handler, completion handler and redirect handler for the download task.
 *
 *  @param downloadTask     The download task progress object and handler should be associated with.
 *  @param path             The local download path.
 *  @param file             The file object associated with the download.
 *  @param progress         Block to call with the progress of the download.
 *  @param completion       The handler which is called upon completion of the download.
 */
- (void)addTransferForDownloadTask:(NSURLSessionTask *)downloadTask
                              path:(NSString *)path
                              file:(CFSFile *)file
                          progress:(CFSFileTransferProgress)progress
                        completion:(CFSFileTransferCompletion)completion
                          redirect:(CFSFileTransferRedirect)redirect;

@end
