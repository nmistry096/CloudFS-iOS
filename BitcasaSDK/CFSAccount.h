//
//  CFSAccount.h
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

/*!
 *  Account class defines properties of the end-user's CloudFS account
 */
@interface CFSAccount : NSObject

/*!
 *  Account id of this users' account.
 */
@property (nonatomic, strong, readonly) NSString *accountId;

/*!
 *  Current storage usage of the account.
 */
@property (nonatomic, readonly) int64_t storageUsage;

/*!
 *  Storage limit of the current account plan.
 */
@property (nonatomic, readonly) int64_t storageLimit;

/*!
 *  If CloudFS thinks you are currently over your storage quota.
 */
@property (assign, readonly) BOOL overStorageLimit;

/*!
 *  The state display name.
 */
@property (nonatomic, strong, readonly) NSString *stateDisplayName;

/*!
 *  Id of the current account state.
 */
@property (nonatomic, strong, readonly) NSString *stateId;

/*!
 *  Human readable name of the accounts' CloudFS plan
 */
@property (nonatomic, strong, readonly) NSString *planDisplayName;

/*!
 *  Id of the CloudFS plan.
 */
@property (nonatomic, strong, readonly) NSString *planId;

/*!
 *  Locale of the current session.
 */
@property (nonatomic, strong, readonly) NSString *sessionLocale;

/*!
 *  Locale of the account.
 */
@property (nonatomic, strong, readonly) NSString *accountLocale;

#pragma mark - Initilization

- (instancetype)init NS_UNAVAILABLE;

/*!
 *  Intializes and returns a CFSAccount instance
 *
 *  @param dictionary The dictionary containing the account details
 *
 *  @return Returns a instance of a CFSAccount
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;
@end
