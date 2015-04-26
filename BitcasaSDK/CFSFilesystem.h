//
//  CFSFilesystem.h
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
#import "CFSFolder.h"

@class CFSContainer, CFSError, CFSShare, CFSRestAdapter;

/*!
 *  FileSystem class provides interface to maintain cloudfs user's filesystem
 */
@interface CFSFilesystem : NSObject

/*!
 *  Initializes CFSFilesystem.
 *  This is the designated initializer.
 *
 *  @param restAdapter Restadapter for the item.
 *
 *  @return Return Self as a object.
 */
-(instancetype)initWithRestAdapter:(CFSRestAdapter *)restAdapter NS_DESIGNATED_INITIALIZER;

#pragma mark - list trash
/*!
 *  List items in trash.
 *
 *  @param completion The completion handler to call afer completion of method.
 */
- (void)listTrashWithCompletion:(void (^)(NSArray *items, CFSError *error))completion;

#pragma mark - share

/*!
 *  Lists shares
 *
 *  @param completion The completion handler to call afer completion of method
 */
- (void)listSharesWithCompletion:(void (^)(NSArray *shares, CFSError *error))completion;

/*!
 *  Create a new share
 *
 *  @param path       The path of the item
 *  @param password   Password for share if desired. If omitted, share will be freely accessable with the share key.
 *  @param completion The completion handler to call afer completion of method
 */
- (void)createShare:(NSString *)path
           password:(NSString *)password
         completion:(void (^)(CFSShare *share, CFSError *error))completion;

/*!
 *  Retrieves the share for the duration of the login session.
 *
 *  @param shareKey   The share key
 *  @param password   The password of the share
 *  @param completion The completion handler to call afer completion of method
 */
- (void)retrieveShare:(NSString *)shareKey
             password:(NSString *)password
           completion:(void (^)(CFSShare *share, CFSError *error))completion;

#pragma mark - root
/*!
 *  Get root folder.
 *
 *  @param completion The completion block to execute when root results are retrieved.
 */
- (void)rootWithCompletion:(void (^)(CFSFolder *root, CFSError *error))completion;


#pragma mark - get item
/*!
 *  Get item from server.
 *
 *  @param path       Path of the item.
 *  @param completion The completion block to execute when item results are retrieved.
 */
- (void)getItem:(NSString *)path
     completion:(void (^)(CFSItem *item, CFSError *error))completion;
@end
