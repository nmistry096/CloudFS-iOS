//
//  CFSItem.h
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
#import "CFSError.h"

@class CFSContainer;
@class CFSShare;

extern NSString *const CFSResponseNameKey;
extern NSString *const CFSResponseItemIdKey;
extern NSString *const CFSResponseTypeKey;
extern NSString *const CFSResponseParentIdKey;
extern NSString *const CFSResponseApplicationDataKey;
extern NSString *const CFSResponseDateContentLastModifiedKey;
extern NSString *const CFSResponseDateMetaLastModifiedKey;
extern NSString *const CFSResponseDateCreatedKey;
extern NSString *const CFSResponseIsMirroredKey;
extern NSString *const CFSResponseVersionKey;
extern NSString *const CFSOperationCopy;
extern NSString *const CFSOperationMove;
extern NSString *const CFSOperationDelete;
extern NSString *const CFSOperationRestore;
extern NSString *const CFSOperationChangeAttribute;
extern NSString *const CFSOperationCreateFolder;
extern NSString *const CFSOperationDownload;
extern NSString *const CFSOperationDownloadLink;
extern NSString *const CFSOperationUpload;
extern NSString *const CFSOperationRead;
extern NSString *const CFSOperationList;
extern NSString *const CFSOperationVersions;
extern NSString *const CFSOperationNotAllowedError;

/*!
 *  Represents an object managed by CloudFS. An item can be either a file or folder.
 */
@interface CFSItem : NSObject
{
    @protected
    CFSRestAdapter *_restAdapter;
}

/*!
 *  Path of the item.
 */
@property (nonatomic, retain, readonly) NSString *path;

/*!
 *  Id of the item.
 */
@property (nonatomic, retain, readonly) NSString *itemId;

/*!
 *  Type of item, either file or folder.
 */
@property (nonatomic, retain, readonly) NSString *type;

/*!
 *  Id of the parent of item
 */
@property (nonatomic, retain, readonly) NSString *parentId;

/*!
 *  Known current version of item.
 */
@property (nonatomic, readonly) int64_t version;

/*!
 *  Name of the item.
 */
@property (nonatomic, retain, readonly) NSString *name;

/*!
 *  Application data of the item. contains aditional meta data.
 */
@property (nonatomic, retain, readonly) NSDictionary *applicationData;

/*!
 *  Time when item's content was last modified.
 */
@property (nonatomic, retain, readonly) NSDate *dateContentLastModified;

/*!
 *  Time when item's metadata was last modified.
 */
@property (nonatomic, retain, readonly) NSDate *dateMetaLastModified;

/*!
 *  Time when item was created.
 */
@property (nonatomic, retain, readonly) NSDate *dateCreated;

/*!
 *  Indicating whether the item was created by mirroring a file.
 */
@property (nonatomic, readonly) BOOL isMirrored;

/*!
 *  Indicating whether the item is in trash.
 */
@property (nonatomic, readonly) BOOL isTrash;

/*!
 *  Indicating whether the item is shared.
 */
@property (nonatomic, readonly) BOOL isShare;

/*!
 *  Sharekey for items in shared state.
 */
@property (nonatomic, readonly) NSString *shareKey;

/*!
 *  Indicating whether the item is an old version.
 */
@property (nonatomic, readonly) BOOL isOldVersion;

/*!
 *  Indicating whether the item is an dead item.
 */
@property (nonatomic, readonly) BOOL isDead;

#pragma mark - Initilization

/*!
 *  Default constructer is private.
 *
 */
- (instancetype)init NS_UNAVAILABLE;

/*!
 *  Initializes CFSItem.
 *  This is the designated initializer.
 *
 *  @param dictionary  Dictionary with item meta deta.
 *  @param parent      Parent container of the item.
 *  @param restAdapter Restadapter for the item.
 *
 *  @return self as a object.
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary
      andParentContainer:(CFSContainer *)parent
          andRestAdapter:(CFSRestAdapter *)restAdapter;

/*!
 *  Initializes CFSItem.
 *  This is the designated initializer.
 *
 *  @param dictionary  Dictionary with item meta deta.
 *  @param parentPath  Path of the parent container.
 *  @param restAdapter Restadapter for the item.
 *
 *  @return self as a object.
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary
           andParentPath:(NSString *)parentPath
          andRestAdapter:(CFSRestAdapter *)restAdapter;

#pragma mark - copy
/*!
 *  Copy this item to destination.
 *
 *  @param destination  Destination to copy item to, should be folder.
 *  @param exists       Action to take in case of a conflict with an existing item.
 *  @param name         Name of the copied file.
 *  @param completion   The completion handler to call afer completion of method.
 */
- (void)copyToDestinationContainer:(CFSContainer *)destination
                        whenExists:(CFSExistsOperation)exists
                              name:(NSString *)name
                        completion:(void (^)(CFSItem *newItem, CFSError *error))completion;

#pragma mark - move
/*!
 *  Move this item to destination.
 *
 *  @param destination Destination to move item to, should be folder.
 *  @param exists     Action to take in case of a conflict with an existing item.
 *  @param completion    The completion handler to call afer completion of method.
 */
- (void)moveToDestinationContainer:(CFSContainer *)destination
                        whenExists:(CFSExistsOperation)exists
                        completion:(void (^)(CFSItem *movedItem, CFSError *error))completion;

#pragma mark - delete
/*!
 *  Delete this item.
 *
 *  @param commit     Set true to remove item permanently.
 *  @param force      Set true to delete non-empty folder.
 *  @param completion The completion handler to call afer completion of method.
 */
- (void)deleteWithCommit:(BOOL)commit
                   force:(BOOL)force
              completion:(void (^)(BOOL success, CFSError *error))completion;

#pragma mark - restore
/*!
 *  Restore this item from trash.
 *
 *  @param destination       Destination folder to restore.
 *  @param method          Action to take if the recovery operation encounters issues.
 *  @param restoreArgument Required arguments for the given option.
 *  @param completion      The completion handler to call afer completion of method.
 */
- (void)restoreToContainer:(CFSContainer *)destination
             restoreMethod:(RestoreOptions)method
           restoreArgument:(NSString *)restoreArgument
          maintainValidity:(BOOL)maintainValidity
                completion:(void (^)(BOOL success, CFSError *error))completion;

/*!
 *  Change attributes of the item with synchronous call.
 *
 *  @param values     Dictionary with new attribute details.
 *  @param ifConflict Enum value to handle version vonflicts.
 *
 *  @return true if change was successful.
 */
- (BOOL)changeAttributes:(NSDictionary *)values
              ifConflict:(VersionExists)ifConflict;

/*!
 *  Change attributes of the item with asynchronous call.
 *
 *  @param values     Dictionary with new attribute details.
 *  @param ifConflict Enum value to handle version vonflicts.
 *  @param completion The completion handler to call afer completion of method.
 */
- (void)changeAttributes:(NSDictionary *)values
              ifConflict:(VersionExists)ifConflict
              completion:(void (^)(BOOL success , CFSError *error))completion;

/*!
 *  Set application data of the item.
 *
 *  @param newApplicationData JSON-Encoded String of the new application data.
 *
 *  @return true if change was successful.
 */
- (BOOL)setApplicationData:(NSDictionary *)newApplicationData;

/*!
 *  Set application data of the item.
 *
 *  @param newName New name of the item.
 *
 *  @return true If change was successful.
 */
- (BOOL)setName:(NSString *)newName;

/*!
 *  Check if given operation is valid.
 *
 *  @param operation Operation type.
 *
 *  @return true If operationg is valid.
 */
- (BOOL)validateOperation:(NSString *)operation;

@end
