//
//  CFSShare.h
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
#import "CFSRestAdapter.h"

@class CFSContainer;
@class CFSError;

/*!
 *  Share class is used to create and manage shares in end-user's account
 */
@interface CFSShare : NSObject

/*!
 *  Key for this share.
 */
@property (nonatomic, strong, readonly) NSString *shareKey;

/*!
 *  Size of the share.
 */
@property (nonatomic, readonly) NSNumber *size;

/*!
 *  Name for the share.
 */
@property (nonatomic, readonly) NSString *name;

/*!
 *  Timestamp for the last time the metadata was modified for this share. In Seconds.
 */
@property (nonatomic, readonly) NSDate *dateMetaLastModified;

/*!
 *  Timestamp for the last time the content of this share was modified. In seconds.
 */
@property (nonatomic, readonly) NSDate *dateContentLastModified;

/*!
 *  Misc data storage. Contents are not defined in any way.
 */
@property (nonatomic,  readonly) NSDictionary *applicationData;

#pragma mark - Initilization

- (instancetype)init NS_UNAVAILABLE;

/*!
 *  Intializes and returns a CFSShare instance
 *
 *  @param dictionary The dictionary containing the share details
 *
 *  @return Returns a instance of a CFSShare
 */
- (CFSShare *)initWithDictionary:(NSDictionary *)dictionary
                 andRestAdapter:(CFSRestAdapter *)restAdapter NS_DESIGNATED_INITIALIZER;

/*!
 *  List the contents of the share
 *
 *  @param completion The completion handler to call afer completion of method
 */
- (void)listWithCompletion:(void (^)(NSArray *items, CFSError *error))completion;

/*!
 *  Changes, adds, or removes the share’s password
 *
 *  @param newPassword The new password that needs to be applied to the share
 *  @param oldPassword The old password of the share
 *  @param completion  The completion handler to call afer completion of method
 */
- (void)setPasswordTo:(NSString *)newPassword
                from:(NSString *)oldPassword
          completion:(void (^)(BOOL success, CFSError *error))completion;

/*!
 *  Delete the share
 *
 *  @param completion The completion handler to call afer completion of method
 */
- (void)deleteWithcompletion:(void (^)(BOOL success, CFSError *error))completion;

/*!
 *  Make bulk changes to this share
 *  Shares only support changing the name of the share, but this interface is included
 *  for consistency with Item.
 *
 *  @param values     The dictionary containing new attribute values
 *  @param password   The new password that needs to be applied to the share
 *  @param completion The completion handler to call afer completion of method
 */
- (void)changeAttributes:(NSDictionary *)values
                password:(NSString *)password
              completion:(void (^)(BOOL success, CFSError *error))completion;

/*!
 *  Add share contents to the filesystem of this user.
 *
 *  @param path  The path of the folder in the user’s file system to insert the files of this share into
 *  @param operation  Behavior if the given item exists on CloudFS. Defaults to rename.
 *  @param completion The completion handler to call afer completion of method
 */
- (void)receiveShare:(NSString *)path
          whenExists:(CFSExistsOperation)operation
          completion:(void (^)(NSArray *items, CFSError *error))completion;

/*!
 *  Unlocks the passed share for the duration of the login session.
 *
 *  @param password   The password of the share that needs to be unlocked
 *  @param completion The completion handler to call afer completion of method
 */
- (void)unlockShareWithPassword:(NSString *)password
                     completion:(void (^)(BOOL success, CFSError *error))completion;

/*!
 *  Sets the share name
 *
 *  @param newName     New name for the share
 *  @param password The current share password
 *
 *  @return Returns success status
 */
- (BOOL)setName:(NSString *)newName usingCurrentPassword:(NSString *)password;

@end
