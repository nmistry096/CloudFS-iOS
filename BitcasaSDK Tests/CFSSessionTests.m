//
//  CFSSessionTests.m
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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <BitcasaSDK/CFSSession.h>
#import "CFSPlistReader.h"
#import "NSString+CFSRestAdditions.h"
#import "CFSRestAdapter.h"
#import "CFSBaseTests.h"
#import "CFSUser.h"
#import "CFSPlan.h"
#import "CFSAccount.h"
#import "CFSError.h"
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
 *  Tests Bitcasa create user.
 */
- (void)testCreateAccount
{
    CFSPlistReader *plistReader = [[CFSPlistReader alloc] initWithFileName:@"BitcasaConfig"];
    
    [[CFSBaseTests getSession] setAdminCredentialsWithAdminClientId:[plistReader appConfigValueForKey:@"CFS_ADMIN_ID"]
                                                  adminClientSecret:[plistReader appConfigValueForKey:@"CFS_ADMIN_SECRET"]];
    
    XCTestExpectation *createAccountExpectation = [self expectationWithDescription:@"authentication"];
    
    [[CFSBaseTests getSession] createAccountWithUsername:[self getRandomEmail]
                          password:@"user@123"
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
 *  Tests Bitcasa update user.
 */
- (void)testUpdateUser
{
    CFSPlistReader *plistReader = [[CFSPlistReader alloc] initWithFileName:@"BitcasaConfig"];
    
    [[CFSBaseTests getSession] setAdminCredentialsWithAdminClientId:[plistReader appConfigValueForKey:@"CFS_ADMIN_ID"]
                                                  adminClientSecret:[plistReader appConfigValueForKey:@"CFS_ADMIN_SECRET"]];
    
    XCTestExpectation *updateUserExpectation = [self expectationWithDescription:@"authentication"];
    
    [[CFSBaseTests getSession] createAccountWithUsername:[self getRandomEmail]
                                                password:@"user@123"
                                                   email:nil
                                               firstName:nil
                                                lastName:nil
                                      logInTocreatedUser:YES
                                          WithCompletion:^(CFSUser *user, CFSError *error) {
          XCTAssertNil(error, "create account error should be nil");
          XCTAssertNotNil(user, "user should not be nil");
          if (user) {
              [[CFSBaseTests getSession] listPlansWithCompletion:^(NSArray *plans, CFSError *error) {
                  CFSPlan *plan = plans[0];
                  XCTAssertNil(error, "create plan error should be nil");
                  XCTAssertNotNil(plan, "plan should not be nil");
                  CFSSession *ses = [CFSBaseTests getSession];
                  [[CFSBaseTests getSession] updateUserWithId:ses.account.accountId
                                                     userName:nil firstName:@"TestUserNameChanged"
                                                     lastName:@"TestUserLastNameChanged"
                                                     planCode:nil
                                               WithCompletion:^(CFSUser *updatedUser, CFSError *error) {
                      XCTAssertNil(error, "updatedAccount error should be nil");
                      XCTAssertNotNil(updatedUser, "user should not be nil");
                      [[CFSBaseTests getSession] authenticateWithUsername:updatedUser.userName
                                                              andPassword:@"user@123"
                                                               completion:^(NSString *token, BOOL success, CFSError *error) {
                          XCTAssertNil(error, "error should be nil");
                          XCTAssertNotNil(token, "token should not be nil");
                          [updateUserExpectation fulfill];
                      }];
                  }];
              }];
          } else {
              [updateUserExpectation fulfill];
          }
      }];
    [self waitForExpectationsWithTimeout:230 handler:^(NSError *error) {}];
}

/*!
 *  Tests Bitcasa create plan.
 */
- (void)testCreatePlan
{
    CFSPlistReader *plistReader = [[CFSPlistReader alloc] initWithFileName:@"BitcasaConfig"];
    
    [[CFSBaseTests getSession] setAdminCredentialsWithAdminClientId:[plistReader appConfigValueForKey:@"CFS_ADMIN_ID"]
                                                  adminClientSecret:[plistReader appConfigValueForKey:@"CFS_ADMIN_SECRET"]];
    
    XCTestExpectation *createPlanExpectation = [self expectationWithDescription:@"authentication"];
    
    [[CFSBaseTests getSession] createPlanWithName:[self getRandomEmail]
                                            limit:@"1024" completion:^(CFSPlan *plan, CFSError *error) {
        XCTAssertNil(error, "create plan error should be nil");
        XCTAssertNotNil(plan, "plan should not be nil");
        [[CFSBaseTests getRestAdapter]  deletePlan:plan.planId completion:^(BOOL success, CFSError *error) {
            XCTAssertNil(error, "delete plan error should be nil");
            [createPlanExpectation fulfill];
        }];
    }];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {}];
}

/*!
 *  Tests Bitcasa List plans.
 */
- (void)testListPlans
{
    CFSPlistReader *plistReader = [[CFSPlistReader alloc] initWithFileName:@"BitcasaConfig"];
    
    [[CFSBaseTests getSession] setAdminCredentialsWithAdminClientId:[plistReader appConfigValueForKey:@"CFS_ADMIN_ID"]
                                                  adminClientSecret:[plistReader appConfigValueForKey:@"CFS_ADMIN_SECRET"]];
    
    XCTestExpectation *listPlanExpectation = [self expectationWithDescription:@"authentication"];
    
    [[CFSBaseTests getSession] listPlansWithCompletion:^(NSArray *plans, CFSError *error) {
        XCTAssertNil(error, "list plans error should be nil");
        XCTAssertNotNil(plans, "list plans not be nil");
        [listPlanExpectation fulfill];
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
    if (![[CFSBaseTests getSession] isLinked]) {
        XCTAssertNil(user, "user should be nil");
    } else {
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
    if (![[CFSBaseTests getSession] isLinked]) {
        XCTAssertNil(account, "account should be nil");
    } else {
        XCTAssertNotNil(account, "account should not be nil");
    }
}

/*!
 *  Tests account of the current session
 */
- (void)testFileSystem
{
    CFSFilesystem *filesystem = [CFSBaseTests getSession].fileSystem;
    if (![[CFSBaseTests getSession] isLinked]) {
        XCTAssertNil(filesystem, "filesystem should be nil");
    } else {
        XCTAssertNotNil(filesystem, "filesystem should not be nil");
    }
}

- (NSString *)getRandomEmail
{
    NSTimeInterval  today = [[NSDate date] timeIntervalSince1970];
    NSString *intervalString = [NSString stringWithFormat:@"%f", today];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[intervalString doubleValue]];
    int r = arc4random_uniform(74);
    NSNumber *newR = [NSNumber numberWithInt:r];
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyyMMddhhmm"];
    NSString *strdate=[formatter stringFromDate:date];
    NSString *strdateNew = [strdate stringByAppendingString:newR.stringValue];
    NSString *email = [strdateNew stringByAppendingString:@"@cloudfstest.com"];
    return email;
}

@end
