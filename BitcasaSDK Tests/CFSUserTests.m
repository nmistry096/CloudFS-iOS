//
//  CFSUserTests.m
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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "CFSUser.h"

@interface CFSUserTests : XCTestCase

@end

@implementation CFSUserTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

/*!
 *  Tests the user initialize method
 */
- (void)testUserInitializer {
    
    NSString *email = @"user@123";
    NSString *firstName = @"firstName";
    NSString *lastName = @"lastName";
    NSString *userName = @"userName";
    NSString *accountState = @"A102";
    NSInteger lastlogin = 12121212;
    NSInteger createdAt = 13131313;
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    dictionary[@"email"] = email;
    dictionary[@"first_name"] = firstName;
    dictionary[@"last_name"] = lastName;
    dictionary[@"username"] = userName;
    dictionary[@"account_state"]  = [NSMutableDictionary dictionary];
    dictionary[@"account_state"][@"id"] = accountState;
    dictionary[@"last_login"] = [NSNumber numberWithLongLong:lastlogin];
    dictionary[@"created_at"] = [NSNumber numberWithLongLong:createdAt];
    
    CFSUser *user = [[CFSUser alloc] initWithDictionary:dictionary];
    
    XCTAssert([user.email isEqualToString:email], @"Should be equal");
    XCTAssert([user.firstName isEqualToString:firstName], @"Should be equal");
    XCTAssert([user.lastName isEqualToString:lastName], @"Should be equal");
    XCTAssert([user.userName isEqualToString:userName], @"Should be equal");
    XCTAssert(user.lastLogin == lastlogin, @"Should be equal");
    XCTAssert(user.createdAt == createdAt, @"Should be equal");
}
@end
