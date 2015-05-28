//
//  CFSUser.h
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

@class CFSPlan;

/*!
 *  User class maintains user profile information
 */
@interface CFSUser : NSObject

/*!
 * User email
 */
@property (nonatomic, strong, readonly) NSString *email;

/*!
 *  User first name
 */
@property (nonatomic, strong, readonly) NSString *firstName;

/*!
 *  User last name.
 */
@property (nonatomic, strong, readonly) NSString *lastName;

/*!
 *  User id
 */
@property (nonatomic, strong, readonly) NSString *userId;

/*!
 *  User's username, often an email.
 */
@property (nonatomic, strong, readonly) NSString *userName;

/*!
 *  Last login time.
 */
@property (nonatomic, readonly) int64_t lastLogin;

/*!
 *  Creation time.
 */
@property (nonatomic, readonly) int64_t createdAt;

#pragma mark - Initilization

- (instancetype)init NS_UNAVAILABLE;

/*!
 *  Initializes and returns a CFSUser instance
 *
 *  @param dictionary The dictionary containing the user details
 *
 *  @return returns a CFSUser instance
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;
@end
