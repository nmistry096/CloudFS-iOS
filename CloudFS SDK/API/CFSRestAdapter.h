//
//  CFSRestAdapter.h
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

@class CFSItem;
@class CFSFile;
@class CFSError;
@class CFSContainer;
@class CFSFolder;
@class CFSShare;
@class CFSUser;
@class CFSAccount;
@class CFSPlan;

/*! 
 *  This is the typedef for token retrieval completion block.
 *  Block is called upon completion with access token and an error object if there is any; otherwise error is nil.
 */
typedef void(^CFSRestAdapterTokenCompletion)(NSString *token, CFSError *error);

/*!
 *  The type definition to track file transfer progress.
 *  Block is called multiple times till the file transfer is completed with completed bytes and total bytes.
 *
 *  @param transferId       The identification of download or upload task.
 *  @param path             Represents the remote path when a file is uploading and local file path when downloading.
 *  @param completedBytes   Number of bytes uploaded or downloaded.
 *  @param totalBytes       Total number of bytes to be uploaded or downloaded.
 */
typedef void(^CFSFileTransferProgress)(NSInteger transferId, NSString *path, int64_t completedBytes, int64_t totalBytes);

/*!
 *  The type definition for file transfer completion block.
 *
 *  @param transferId   The identification of file transfer task.
 *  @param path         The remote path of the uploaded file or local path of the downloaded file.
 *  @param file         The CFSFile object referring to newly uploaded file or the file downloaded.
 *  @param error        The error if an error occurs while transfering the file.
 */
typedef void(^CFSFileTransferCompletion)(NSInteger transferId, NSString *path, CFSFile *file, CFSError *error);

/*!
 *  The type definition for file transfer HTTP redirect response block.
 *
 *  @param transferId   The identification of file transfer task.
 *  @param path         The remote path of the uploaded file or local path of the downloaded file.
 *  @param response     Dictionary containing deserialized JSON object data.
 *  @param proceed      Set proceed to YES to continue; otherwise set to NO.
 */
typedef void(^CFSFileTransferRedirect)(NSInteger transferId, NSString *path, NSURLResponse *response, BOOL *proceed);

typedef void(^CFSRestAdapterDictionaryWithErrorCompletion)(NSDictionary *dictionary, CFSError *error);

extern NSString *const CFSRestApiEndpointFiles;
extern NSString *const CFSItemTypeFile;
extern NSString *const CFSItemTypeFolder;
extern NSString *const CFSItemTypeFileSystem;
extern NSString *const CFSShareResponseResultShareKey;
extern NSString *const CFSItemStateIsTrash;
extern NSString *const CFSItemStateIsOldVersion;
extern NSString *const CFSItemStateIsShare;
extern NSString *const CFSItemShareKey;

@interface CFSRestAdapter : NSObject

typedef NS_ENUM(NSInteger, CFSExistsOperation) {
    CFSExistsFail,
    CFSExistsOverwrite,
    CFSExitsRename,
    CFSExistsDefault
};

typedef NS_ENUM(NSInteger, CFSItemExistsOperation) {
    CFSItemExistsFail,
    CFSItemExistsOverwrite,
    CFSItemExistsRename,
    CFSItemExistsReuse,
    CFSItemExistsDefault
};

/*!
 *  The access token used to communicate with CloudFS REST service.
 */
@property (nonatomic, copy) NSString *accessToken;

typedef NS_ENUM(NSInteger, VersionExists) {
    VersionExistsFail,
    VersionExistsIgnore
};

typedef NS_ENUM(NSInteger, RestoreOptions) {
    RestoreOptionsFail,
    RestoreOptionsRescue,
    RestoreOptionsRecreate    
};

#pragma mark - Initilization

- (instancetype)init NS_UNAVAILABLE;

/*!
 *  Initializes REST Adapter.
 *  This is the designated initializer.
 *
 *  @param serverUrl The CloudFS REST server url.
 *  @param clientId  The Client ID.
 *  @param secret    The Client Secret.
 *
 *  @return An instance of CFRestAdapter class.
 */
- (instancetype)initWithServerUrl:(NSString *)serverUrl
                         clientId:(NSString *)clientId
                     clientSecret:(NSString *)secret;

/*!
 *  Initializes REST Adapter.
 *  This is the designated initializer.
 *
 *  @param serverUrl    The CloudFS REST endpoint.
 *  @param clientId     The client ID.
 *  @param secret       The client secret.
 *  @param token        The access token.
 *
 *  @return An instance of CFRestAdapter class.
 */
- (instancetype)initWithServerUrl:(NSString *)serverUrl
                         clientId:(NSString *)clientId
                     clientSecret:(NSString *)secret
                      accessToken:(NSString *)token NS_DESIGNATED_INITIALIZER;

#pragma mark - Authentication
/*!
 *  Authenticates using the email and password. Executes the handler with OAuth token.
 *
 *  @param email    The email address of the user.
 *  @param password The password of the user.
 *  @param handler  Handler to execute upon completion with OAuth token.
 */
- (void)authenticateWithEmail:(NSString *)email
                     password:(NSString *)password
            completionHandler:(CFSRestAdapterTokenCompletion)handler;

#pragma mark - Get profile
/*!
 *  Gets the user profile details.
 *
 *  @param completion Executes with user profile details when the details are received.
 */
- (void)getProfileWithCompletion:(void(^)(NSDictionary* response, CFSError *error))completion;

#pragma mark - List directory contents

/*!
 *  Retrieves the item list at this path.
 *
 *  @param completion The completion handler to call afer completion of method.
 */
- (void)listContentsOfPath:(NSString *)path
                completion:(void (^)(NSArray *items, CFSError *error))completion;

/*!
 *  Retrieves the item list at this items path.
 *
 *  @param completion The completion handler to call afer completion of method.
 */
- (void)listContentsOfContainer:(CFSContainer *)container
                     completion:(void (^)(NSArray *items , CFSError *error))completion;

/*!
 *  Retrieves the item list on trash.
 *
 *  @param completion The completion handler to call afer completion of method.
 */
- (void)getContentsOfTrashWithPath:(NSString *)path completion:(void (^)(NSArray* items, CFSError *error))completion;

#pragma mark - Move item(
/*!
 *  Move item to a given destination
 *
 *  @param itemToMove item to be moved.
 *  @param destination     destination to be moved.
 *  @param operation  action to take in case of a conflict with an existing item.
 *  @param completion the completion handler to call afer completion of method.
 */
- (void)moveItem:(CFSItem*)itemToMove
              to:(CFSContainer*)destination
      whenExists:(CFSExistsOperation)operation
      completion:(void (^)(CFSItem *movedItem, CFSError *error))completion;

#pragma mark - Copy item
/*!
 *  Copy item to a given destination
 *
 *  @param itemToCopy    item to be copied.
 *  @param destination   destination to copy item to, should be folder.
 *  @param operation     action to take in case of a conflict with an existing item.
 *  @param name          Name of the copied file.
 *  @param completion    the completion handler to call afer completion of method.
 */
- (void)copyItem:(CFSItem*)itemToCopy
              to:(CFSContainer*)destination
      whenExists:(CFSExistsOperation)operation
            name:(NSString *)name
      completion:(void (^)(CFSItem* newItem, CFSError *error))completion;

#pragma mark - Delete item
/*!
 *  Delete item
 *
 *  @param itemToDelete item to be deleted
 *  @param commit     set true to remove item permanently.
 *  @param force      set true to delete non-empty folder.
 *  @param completion the completion handler to call afer completion of method.
 */
- (void)deleteItem:(CFSItem *)itemToDelete
            commit:(BOOL)commit
             force:(BOOL)force
        completion:(void (^)(BOOL success, CFSError *error))completion;

#pragma mark - Restore item
/*!
 *  Restore item from trash
 *
 *  @param itemToRestore   item to be restored
 *  @param option          action to take if the recovery operation encounters issues.
 *  @param restoreArgument required arguments for the given option.
 *  @param toItem          destination container
 *  @param completion      the completion handler to call afer completion of method.
 */
- (void)restoreItem:(CFSItem *)itemToRestore
      restoreMethod:(RestoreOptions)option
    restoreArgument:(NSString *)restoreArgument
                 to:(CFSContainer *)toItem
         completion:(void (^)(BOOL success, CFSError *error))completion;

#pragma mark - Shares
/*!
 *  Lists shares
 *
 *  @param completion The completion handler to call afer completion of method
 */
- (void)listSharesWithCompletion:(void (^)(NSArray* shares, CFSError *error))completion;

/*!
 *  List the contents of the share
 *
 *  @param shareKey   The share key of the share
 *  @param container  The container inside the share.
 *  @param completion The completion handler to call afer completion of method
 */
- (void)browseShare:(NSString *)shareKey
          container:(CFSContainer *)container
         completion:(void (^)(NSArray* items, CFSError *error))completion;

/*!
 *  Add share contents to the filesystem of this user.
 *
 *  @param shareKey   The share key of the share
 *  @param path  The path of the folder in the user’s file system to insert the files of this share into
 *  @param operation  Behavior if the given item exists on CloudFS. Defaults to rename.
 *  @param completion The completion handler to call afer completion of method
 */
- (void)receiveShare:(NSString *)shareKey
           path:(NSString *)path
          whenExists:(CFSExistsOperation)operation
          completion:(void (^)(NSArray *items, CFSError *error))completion;

/*!
 *  Delete the share
 *
 *  @param shareKey   The share key of the share
 *  @param completion The completion handler to call afer completion of method
 */
- (void)deleteShare:(NSString *)shareKey
         completion:(void (^)(BOOL success, CFSError *error))completion;

/*!
 *  Create a new share
 *
 *  @param paths      The paths of the items
 *  @param password   Password for share if desired. If omitted, share will be freely accessable with the share key.
 *  @param completion completion The completion handler to call afer completion of method
 */
- (void)createShare:(NSArray *)paths
           password:(NSString *)password
         completion:(void (^)(CFSShare *share, CFSError *error))completion;

/*!
 *  Updates the share name
 *
 *  @param name             New name for the share
 *  @param currentPassword  The current share password
 *  @param shareKey         The share key of the share
 *  @param completion       The completion handler to call afer completion of method
 */
- (void)setShareName:(NSString *)name
usingCurrentPassword:(NSString *)currentPassword
        withShareKey:(NSString *)shareKey completion:(void (^)(BOOL success, CFSShare *share, CFSError *error))completion;

/*!
 *  Updates the share name
 *
 *  @param name             New name for the share
 *  @param currentPassword  The current share password
 *  @param shareKey         The share key of the share
 *  @param error            The error to be handled, passed by reference
 *
 *  @return Returns a instance of CFSShare
 */
- (CFSShare *)setShareName:(NSString *)name
      usingCurrentPassword:(NSString *)currentPassword
              withShareKey:(NSString *)shareKey error:(CFSError **)error;

/*!
 *  Changes, adds, or removes the share’s password
 *
 *  @param newPassword The new password that needs to be applied to the share
 *  @param oldPassword The old password of the share
 *  @param shareKey    The share key of the share
 *  @param completion  The completion handler to call afer completion of method
 */
- (void)setSharePasswordTo:(NSString *)newPassword
                      from:(NSString *)oldPassword
              withShareKey:(NSString *)shareKey
                completion:(void (^)(BOOL success, CFSError *error))completion;

/*!
 *  Unlocks the passed share for the duration of the login session.
 *
 *  @param shareKey   The share key of the share
 *  @param password   The password of the share that needs to be unlocked
 *  @param completion The completion handler to call afer completion of method
 */
- (void)unlockShare:(NSString *)shareKey
           password:(NSString *)password
         completion:(void (^)(BOOL Success, CFSError *error))completion;


#pragma mark - Create new directory
/*!
 *  Creates a folder with the specified name inside the path
 *
 *  @param path       The path where the folder needs to be created
 *  @param operation  Action to take in case of a conflict with an existing folder.
 *  @param name       The name of the folder that needs to be created
 *  @param completion The completion handler to call afer completion of method
 */
- (void)createFolderInContainer:(NSString *)path
                     whenExists:(CFSItemExistsOperation)operation
                       withName:(NSString *)name
                     completion:(void (^)(NSDictionary *newFolderDict, CFSError *error))completion;

#pragma mark - Downloads
/*!
 *  Downloads the file to given local destination path.
 *
 *  @param file                     The file to be downloaded.
 *  @param localDestinationPath     The local folder path where the file is downloaded.
 *  @param progress                 The progress block which is called multiple times while the file is being downloaded.
 *  @param completion               The block to be called upon completion.
 */
- (void)downloadFile:(CFSFile *)file
                  to:(NSString *)localDestinationPath
            progress:(CFSFileTransferProgress)progress
          completion:(CFSFileTransferCompletion)completion;

/*!
 *  Gets a link to the given file.
 *
 *  @param file       The file to get the download Url.
 *  @param completion The block to be called with the download url.
 */
- (void)downloadUrlOfFile:(CFSFile *)file completion:(void (^)(NSString *downloadUrl))completion;

/*!
 *  Gets a NSInputStream for the given file on CloudFS server.
 *
 *  @param completion Executes the completion block with the NSInputStream upon completion.
 */
- (void)inputStreamOfFile:(CFSFile *)file completion:(void (^)(NSInputStream *inputStream))completion;

#pragma mark - Uploads
/*!
 *  Uploads the file at the source URL to given container.
 *
 *  @param sourcePath     The path to the local file to be uploaded.
 *  @param destContainer  The container which the file needs to be uploaded.
 *  @param progress       The Progress block which is called multiple times while the file is being uploaded.
 *  @param completion     The block to be called upon completion.
 *  @param operation      The operation to perform if the file already exists in the container.
 */
- (void)uploadFile:(NSString *)sourcePath
                to:(CFSContainer *)destContainer
          progress:(CFSFileTransferProgress)progress
        completion:(CFSFileTransferCompletion)completion
        whenExists:(CFSExistsOperation)operation;

#pragma mark - Helpers
/*!
 *  Get result values from recived data
 *
 *  @param data recived data from the server.
 *
 *  @return nsdictionary with result values.
 */
- (NSDictionary*)resultDictionaryFromResponseData:(NSData*)data;

#pragma mark - History
/*!
 *  Action history lists history of file, folder, and share actions.
 *
 *  @param startVersion version number to start listing historical actions from,
 *		default -10. It can be negative in order to get most recent actions.
 *  @param stopVersion version number to stop listing historical
 *		actions from (non-inclusive)
 *  @param completion The completion block to execute when history destails are retrieved.
 */
- (void)getActionHistoryWIthStartVersion:(NSInteger)startVersion
                             stopVersion:(NSInteger)stopVersion
                              completion:(void (^)(NSDictionary * history, CFSError *error))completion;

#pragma mark - Admin
/*!
 *  Creates a new end-user account for a Paid CloudFS account
 *
 *  @param username           username of the end-user
 *  @param password           password of the end-user
 *  @param email              email of the end-user
 *  @param firstName          first name of end user
 *  @param lastName           last name of end user
 *  @param completion         The completion block to execute when account creation task is done.
 */
-(void)createAccountWithUsername:(NSString *)username
                        password:(NSString *)password
                           email:(NSString *)email
                       firstName:(NSString *)firstName
                        lastName:(NSString *)lastName
                      completion:(void (^)(NSDictionary * userDetails, CFSError *error))completion;
/*!
 *  Delete user plans. WARNING!!! Deleting a plan could cause various issues in a production environment.
 *
 *  @param planId     id of the plan toi be deleted
 *  @param completion The completion block to execute when account creation task is done.
 */
- (void)deletePlan:(NSString *)planId
        completion:(void(^)(BOOL success, CFSError *error))completion;

/*!
 *  Creates a new user plan
 *
 *  @param name                 name of the plan
 *  @param limit                limit of the plan
 *  @param completion           The completion block to execute when plan creation task is done.
 */
- (void)createPlanWithName:(NSString *)name
                     limit:(NSString *)limit
                completion:(void (^)(CFSPlan *plan, CFSError *error))completion;

/*!
 *  List all the user plans
 *
 *  @param completion       The completion block to execute when plan creation task is done.
 */
- (void)listPlansWithCompletion:(void (^)(NSArray *plans, CFSError *error))completion;

- (void)updateUserWithId:(NSString *)userId
                userName:(NSString *)userName
               firstName:(NSString *)firstName
                lastName:(NSString *)lastName
                planCode:(NSString *)plancode
          WithCompletion:(void (^)(CFSUser *user, CFSError *error))completion;

/*!
 *  Set admin credetial for
 *
 *  @param adminClientId     admin id given to the premium end-user.
 *  @param adminClientSecret admin secret given to the Paid end-user.
 */
-(void)setAdminCredentialsWithAdminClientId:(NSString *)adminClientId
                          adminClientSecret:(NSString *)adminClientSecret;

#pragma mark - Versions

/*!
 *  List the previous versions of this file
 *
 *  @param startVersion Lowest version number to list
 *  @param endVersion   Last version of the file to list.
 *  @param limit        Limit on number of versions returned. Optional, defaults to 10.
 *  @param completion   The completion handler to call
 */
- (void)getVersionsOfFile:(NSString *)fileUrl
             startVersion:(NSNumber *)startVersion
               endVersion:(NSNumber *)endVersion
                    limit:(NSNumber *)limit
               completion:(void (^)(NSArray *items, CFSError *error))completion;

#pragma mark - Meta data
/*!
 *  Alter meta data with asynchronous call
 *
 *  @param path    path of the item.
 *  @param meta    meta data to be altered.
 *  @param type    type of the item.
 *  @param handler The completion handler to call.
 */
- (void)alterMetaDataAsyncWithPath:(NSString *)path
                              meta:(NSDictionary *)meta
                              type:(NSString *)type
                 completionHandler:(CFSRestAdapterDictionaryWithErrorCompletion)handler;

/*!
 *  Alter meta data with synchronous call
 *
 *  @param path  path of the item.
 *  @param meta  meta data to be altered.
 *  @param type  type of the item.
 *  @param error error to be handled, passed by reference
 *
 *  @return new meta data of the item.
 */
- (NSDictionary *)alterMetaDataSyncWithPath:(NSString *)path
                                       meta:(NSDictionary *)meta
                                       type:(NSString *)type error:(CFSError **)error;

/*!
 *  Get meta data of a item.
 *
 *  @param path    path of the item.
 *  @param type    type of the item.
 *  @param handler the completion handler to call.
 */
- (void)getMetaDataWithPath:(NSString *)path
                       type:(NSString *)type
          completionHandler:(CFSRestAdapterDictionaryWithErrorCompletion)handler;

@end