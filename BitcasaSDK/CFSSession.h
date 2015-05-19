//
//  CFSSession.h
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
@class CFSAccount;
@class CFSUser;
@class CFSFilesystem;
@class CFSRestAdapter;
@class CFSError;

/*!
 *  Establishes a session with the api server on behalf of an authenticated end-user
 */
@interface CFSSession : NSObject

/*!
 *  User Gets the bitcasa CFSUser associated with this session.
 */
@property (nonatomic, strong) CFSUser *user;

/*!
 *  End-user's account linked with this session.
 */
@property (nonatomic, strong) CFSAccount *account;

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
 *  @return True If the access code is valid, otherwise false.
 */
- (BOOL)isLinked;

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

@end

