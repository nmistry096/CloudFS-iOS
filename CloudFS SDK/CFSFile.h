//
//  CFSFile.h
//  CloudFS SDK
//
//  CloudFS iOS SDK
//  Copyright (C) 2015 Bitcasa, Inc.
//  1200 Park Place, Suite 350
//  San Mateo, CA 94403
//
//  All rights reserved.
//
//  For support, please send email to sdks@bitcasa.com.
//

#import <Foundation/Foundation.h>
#import "CFSItem.h"

extern NSString* const CFSresponseMimeKey;
extern NSString* const CFSresponseExtensionKey;
extern NSString* const CFSresponseSizeKey;

/*!
 * File class is aimed to provide native File object like interface to cloudfs files
 */
@interface CFSFile : CFSItem

#pragma mark - Initilization

- (instancetype)init NS_UNAVAILABLE;

/*!
 *  Initializes and returns a CFSFile instance
 *
 *  @param dictionary  The dictionary containing the CFSFile details
 *  @param parentPath  The parent path of the file
 *  @param restAdapter The restAdaptor instance
 *
 *  @return Returns a CFSFile instance
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary
           andParentPath:(NSString *)parentPath
          andRestAdapter:(CFSRestAdapter *)restAdapter;

/*!
 *  Mime type of file.
 */
@property (nonatomic, retain, readonly) NSString *mime;

/*!
 *  Extension of file.
 */
@property (nonatomic, retain, readonly) NSString *extension;

/*!
 *  Size of file.
 */
@property (nonatomic, readonly) int64_t size;

/*!
 *  Downloads the file to given local destination path.
 *
 *  @param localDestinationPath     The local folder path where the file is downloaded.
 *  @param progress                 The progress block which is called multiple times while the file is being downloaded.
 *  @param completion               The block to be called upon completion.
 */
- (void)download:(NSString *)localDestinationPath
        progress:(CFSFileTransferProgress)progress
      completion:(CFSFileTransferCompletion)completion;

/*!
 *  List the previous versions of this file
 *
 *  @param startVersion Lowest version number to list
 *  @param endVersion   Last version of the file to list.
 *  @param limit        Limit on number of versions returned. Optional, defaults to 10.
 *  @param completion   The completion handler to call
 */
- (void)versionsWithStartVersion:(NSNumber *)startVersion
                  endVersion:(NSNumber *)endVersion
                       limit:(NSNumber *)limit
              withCompletion:(void (^)(NSArray *items, CFSError *error))completion;

/*!
 *  Gets a NSInputStream for the file on CloudFS server.
 *
 *  @param completion Executes the completion block with the NSInputStream upon completion.
 */
- (void)readWithCompletion:(void (^)(NSInputStream *inputStream))completion;

/*!
 *  Sets Mime type of file.
 *
 *  @param newMime The new mime value of file
 *
 *  @return Returns true if success
 */
- (BOOL)setMime:(NSString *)newMime;

/*!
 *  Gets the download Url.
 *
 *  @param completion The completion block to execute upon retrieval of the download URL.
 */
- (void)downloadUrlWithCompletion:(void (^)(NSString *downloadUrl))completion;

@end
