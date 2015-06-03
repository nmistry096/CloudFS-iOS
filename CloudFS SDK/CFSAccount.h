//
//  CFSAccount.h
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
@class CFSPlan;

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
 *  Locale of the current session.
 */
@property (nonatomic, strong, readonly) NSString *sessionLocale;

/*!
 *  Locale of the account.
 */
@property (nonatomic, strong, readonly) NSString *accountLocale;

/*!
 *  Current plan of the user.
 */
@property (nonatomic, strong, readonly) CFSPlan *plan;

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
