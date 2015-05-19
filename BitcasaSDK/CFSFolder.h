//
//  CFSFolder.h
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

#import <Foundation/Foundation.h>
#import "CFSContainer.h"

@class CFSError;

/*!
 *  Represents a folder in the user's filesystem that can contain files and other folders.
 */
@interface CFSFolder : CFSContainer

#pragma mark - Initilization

- (instancetype)init NS_UNAVAILABLE;

#pragma mark - create folder

/*!
 *  Creates a folder with the specified name inside the current folder.
 *
 *  @param name The name of the folder being created.
 *  @param exists Action to take in case of a conflict with an existing folder.
 *  @param completion The completion handler to call afer completion of method.
 */
- (void)createFolder:(NSString *)name
          whenExists:(CFSItemExistsOperation)exists
          completion:(void (^)(CFSFolder *newDir, CFSError *error))completion;

/*!
 *  Uploads the file at the source URL to this folder.
 *
 *  @param fileSystemPath     The path to the local file to be uploaded.
 *  @param progress       The progress block which is called multiple times while the file is being uploaded.
 *  @param completion     The block to be called upon completion.
 *  @param exists      The operation to perform if the file already exists in the folder.
 */
- (void)upload:(NSString *)fileSystemPath
      progress:(CFSFileTransferProgress)progress
    completion:(CFSFileTransferCompletion)completion
    whenExists:(CFSExistsOperation)exists;

@end
