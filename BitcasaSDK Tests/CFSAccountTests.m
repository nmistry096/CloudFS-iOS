//
//  CFSAccountTests.m
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
#import "CFSACcount.h"

@interface CFSAccountTests : XCTestCase

@end

@implementation CFSAccountTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}


/*!
 *  Tests account initialize method
 */
- (void)testAccountInitializer
{
    NSString *accountId = @"2713b0a6-2599-4772-b1f0-d49614fec8c1";
    NSInteger storageUsage = 90836;
    NSInteger storageLimit = 1010101;
    NSNumber *storageOtl = [NSNumber numberWithBool:YES];
    NSString *accountStateDisplayName = @"Active";
    NSString *accountStageId = @"AS003";
    NSString *accountPlanDisplayName = @"CloudFS End User";
    NSString *accountPlanId = @"3a4e6a87-1dad-4ea8-b846-2c4501b1a771";
    NSString *sessionLocale = @"en_us";
    NSString *locale = @"en_us";
    
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
    mutableDictionary[@"account_id"] = accountId;
    mutableDictionary[@"storage"] = [NSMutableDictionary dictionary];
    mutableDictionary[@"storage"][@"usage"] = [NSNumber numberWithLong:storageUsage];
    mutableDictionary[@"storage"][@"limit"] = [NSNumber numberWithLong:storageLimit];
    mutableDictionary[@"storage"][@"otl"] = [NSNumber numberWithBool:YES];
    mutableDictionary[@"account_state"] = [NSMutableDictionary dictionary];
    mutableDictionary[@"account_state"][@"display_name"] = accountStateDisplayName;
    mutableDictionary[@"account_state"][@"id"] = accountStageId;
    mutableDictionary[@"account_plan"] = [NSMutableDictionary dictionary];
    mutableDictionary[@"account_plan"][@"display_name"] = accountPlanDisplayName;
    mutableDictionary[@"account_plan"][@"id"] = accountPlanId;
    mutableDictionary[@"session"] = [NSMutableDictionary dictionary];
    mutableDictionary[@"session"][@"locale"] = sessionLocale;
    mutableDictionary[@"locale"] = locale;
    
    CFSAccount *account = [[CFSAccount alloc] initWithDictionary:mutableDictionary];
    
    XCTAssert([account.accountId isEqualToString:accountId], "Should be Equal");
    XCTAssert(account.storageUsage == storageUsage, "Should be Equal");
    XCTAssert(account.storageLimit ==  storageLimit, "Should be Equal");
    XCTAssert(account.overStorageLimit == storageOtl.boolValue, "Should be Equal");
    XCTAssert([account.stateDisplayName isEqualToString:accountStateDisplayName], "Should be Equal");
    XCTAssert([account.planDisplayName isEqualToString:accountPlanDisplayName], "Should be Equal");
    XCTAssert([account.planId isEqualToString:accountPlanId], "Should be Equal");
    XCTAssert([account.sessionLocale isEqualToString:sessionLocale], "Should be Equal");
    XCTAssert([account.accountLocale isEqualToString:locale], "Should be Equal");
}

@end
