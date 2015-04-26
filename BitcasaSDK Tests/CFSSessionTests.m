//
//  CFSSessionTests.m
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
#import <BitcasaSDK/CFSSession.h>
#import "CFSPlistReader.h"
#import "NSString+CFSRestAdditions.h"
#import "CFSRestAdapter.h"
#import "CFSBaseTests.h"

@interface CFSSessionTests :CFSBaseTests

@end

@implementation CFSSessionTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

/*!
 *  Tests action history.
 */
- (void)testActionHistory {
    
    XCTestExpectation *actionHistoryExpectation = [self expectationWithDescription:@"history"];
    [[CFSBaseTests getSession] actionHistoryWithCompletion:^(NSDictionary *history, CFSError *error) {
            XCTAssertNil(error, "action history error should be nil");
            XCTAssertNotNil(history, "history should not be nil");
        [actionHistoryExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {}];
}

/*!
 *  Tests Bitcasa authentication.
 */
- (void)testCreateAccount
{
    CFSPlistReader *plistReader = [[CFSPlistReader alloc] initWithFileName:@"BitcasaConfigForAdmin"];
    
    [[CFSBaseTests getSession] setAdminCredentialsWithAdminClientId:[plistReader appConfigValueForKey:@"CFS_ADMIN_ID"]
                                                  adminClientSecret:[plistReader appConfigValueForKey:@"CFS_ADMIN_SECRET"]];
    
    XCTestExpectation *createAccountExpectation = [self expectationWithDescription:@"authentication"];
    
    [[CFSBaseTests getSession] createAccountWithUsername:[self getRandomEmail]
                          password:@"test123"
                             email:nil
                         firstName:nil
                          lastName:nil
                logInTocreatedUser:NO
                    WithCompletion:^(CFSUser *user, CFSError *error) {
            XCTAssertNil(error, "create account error should be nil");
            XCTAssertNotNil(user, "user should not be nil");
        [createAccountExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {}];
}

/*!
 *  Tests if session is linked to the server.
 */
- (void)testIsLinked
{
    [[CFSBaseTests getSession] unlink];
    XCTAssertTrue(![[CFSBaseTests getSession] isLinked], "Session should be unlinked.");
}

/*!
 *  Unlink session from server
 */
- (void)testUnlink
{
    [[CFSBaseTests getSession] unlink];
    XCTAssertTrue(![[CFSBaseTests getSession] isLinked], "Session should be unlinked.");
}

/*!
 *  Tests user of the current session
 */
- (void)testUser
{
    CFSUser *user = [CFSBaseTests getSession].user;
    if(![[CFSBaseTests getSession] isLinked]){
        XCTAssertNil(user, "user should be nil");
    }
    else{
        CFSUser *user = [CFSBaseTests getSession].user;
        XCTAssertNotNil(user, "user should not be nil");
    }
}

/*!
 *  Tests account of the current session
 */
- (void)testAccount
{
    CFSAccount *account = [CFSBaseTests getSession].account;
    if(![[CFSBaseTests getSession] isLinked]){
        XCTAssertNil(account, "account should be nil");
    }
    else{
        XCTAssertNotNil(account, "account should not be nil");
    }
}

/*!
 *  Tests account of the current session
 */
- (void)testFileSystem
{
    CFSFilesystem *filesystem = [CFSBaseTests getSession].fileSystem;
    if(![[CFSBaseTests getSession] isLinked]){
        XCTAssertNil(filesystem, "filesystem should be nil");
    }
    else{
        XCTAssertNotNil(filesystem, "filesystem should not be nil");
    }
}

- (NSString *)getRandomEmail
{
    NSTimeInterval  today = [[NSDate date] timeIntervalSince1970];
    NSString *intervalString = [NSString stringWithFormat:@"%f", today];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[intervalString doubleValue]];
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyyMMddhhmm"];
    NSString *strdate=[formatter stringFromDate:date];
    NSString *email = [strdate stringByAppendingString:@"@cloudfstest.com"];
    return email;
}

@end
