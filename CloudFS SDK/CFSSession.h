//
//  CFSSession.h
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
@class CFSAccount;
@class CFSUser;
@class CFSFilesystem;
@class CFSRestAdapter;
@class CFSError;
@class CFSPlan;

/*!
 *  Establishes a session with the api server on behalf of an authenticated end-user
 */
@interface CFSSession : NSObject

/*!
 *  CFSFileSystem associated with this session.
 */
@property (nonatomic, strong) CFSFilesystem *fileSystem;

/*!
 *  History associated with file, folder, and share actions stored in the historical ledger for the specified versions.
 */
@property (nonatomic, strong) NSDictionary *history;

/*!
 *  CFSRestAdapter associated with this session.
 */
@property (nonatomic, strong) CFSRestAdapter *restAdapter;

/*!
 *  Intitalize session class with client details.
 *
 *  @param endPoint The service end point.
 *  @param clientId The client id.
 *  @param clientSecret   The client secret.
 *
 *  @return return self as a object.
 */
- (instancetype)initWithEndPoint:(NSString *)endPoint
               clientId:(NSString *)clientId
           clientSecret:(NSString *)clientSecret NS_DESIGNATED_INITIALIZER;

#pragma mark - Authenticate
/*!
 *  Authenticate user.
 *
 *  @param username   End-user's username.
 *  @param password   End-user's password.
 *  @param completion The completion block to execute when authentication results are retrieved.
 */
- (void)authenticateWithUsername:(NSString *)username
                     andPassword:(NSString *)password
                      completion:(void (^)(NSString* token, BOOL success , CFSError *error))completion;

/*!
 *  Unlink the authenticated user.
 */
- (void)unlink;

/*!
 *  Checks whether the user is authenticated.
 *
 *  @param completion The completion block to execute when authentication results are retrieved.
 */
- (void)isLinkedWithCompletion:(void (^)(BOOL response, CFSError *error))completion;

#pragma mark - History
/*!
 *  Action history lists history of file, folder, and share actions.
 *
 *  @param completion The completion block to execute when history destails are retrieved.
 */
- (void)actionHistoryWithCompletion:(void (^)(NSDictionary *history, CFSError *error))completion;

/*!
 *  Action history lists history of file, folder, and share actions.
 *
 *  @param startVersion Version number to start listing historical actions.
 *  @param stopVersion Version number to stop listing historical actions.
 *  @param completion The completion block to execute when history destails are retrieved.
 */
- (void)actionHistoryWithStartVersion:(NSInteger)startVersion
                      andStopVersion:(NSInteger)stopVersion
                          completion:(void (^)(NSDictionary *history, CFSError *error))completion;

#pragma mark - Admin tasks
/*!
 *  Credentials of Paid CloudFS User's admin account
 *
 *  @param adminClientId     Admin account clientid
 *  @param adminClientSecret Admin account secret
 */
- (void)setAdminCredentialsWithAdminClientId:(NSString *)adminClientId
                          adminClientSecret:(NSString *)adminClientSecret;

/*!
 *  Creates a new end-user account for a Paid CloudFS account
 *
 *  @param username           Username of the new CFSUser
 *  @param password           Password of the CFSUser
 *  @param email              Email of the CFSUser
 *  @param firstName          First name of CFSUser
 *  @param lastName           Last name of CFSUser
 *  @param logInTocreatedUser Log in to the created account
 *  @param completion         The completion block to execute when account creation task is done.
 */
- (void)createAccountWithUsername:(NSString *)username
                        password:(NSString *)password
                           email:(NSString *)email
                       firstName:(NSString *)firstName
                        lastName:(NSString *)lastName
              logInTocreatedUser:(BOOL)logInTocreatedUser
                  WithCompletion:(void (^)(CFSUser *user, CFSError *error))completion;

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

/*!
 *  Update end-user
 *
 *  @param userId     id of the end-user
 *  @param userName   new username to be changed
 *  @param firstName  new firstName to be changed
 *  @param lastName   new lastName to be changed
 *  @param plancode   new plancode to be changed
 *  @param completion The completion block to execute when plan creation task is done.
 */
- (void)updateUserWithId:(NSString *)userId
                userName:(NSString *)userName
               firstName:(NSString *)firstName
                lastName:(NSString *)lastName
                planCode:(NSString *)plancode
          WithCompletion:(void (^)(CFSUser *user, CFSError *error))completion;

/*!
 *  Get account for the session.
 *
 *  @param completion The completion block to execute when account is received
 */
- (void)accountWithCompletion:(void (^)(CFSAccount *account, CFSError *error))completion;

/*!
 *  Get user for the session.
 *
 *  @param completion The completion block to execute when account is received
 */
- (void)userWithCompletion:(void (^)(CFSUser *user, CFSError *error))completion;
@end

