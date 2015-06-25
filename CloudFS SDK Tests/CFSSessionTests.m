//
//  CFSSessionTests.m
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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <CloudFS SDK/CFSSession.h>
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
            XCTAssertNil(error, "Action history error should be nil.");
            XCTAssertNotNil(history, "History should not be nil.");
        [actionHistoryExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {}];
}

/*!
 *  Tests Bitcasa create user.
 */
- (void)testCreateAccount
{
    CFSPlistReader *plistReader = [[CFSPlistReader alloc] initWithFileName:@"CloudFSConfig"];
    
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
            XCTAssertNil(error, "Create account error should be nil.");
            XCTAssertNotNil(user, "User should not be nil.");
        [createAccountExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {}];
}

/*!
 *  Tests Bitcasa update user.
 */
- (void)testUpdateUser
{
    CFSPlistReader *plistReader = [[CFSPlistReader alloc] initWithFileName:@"CloudFSConfig"];
    
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
          XCTAssertNil(error, "Create account error should be nil.");
          XCTAssertNotNil(user, "User should not be nil.");
          if (user) {
              [[CFSBaseTests getSession] listPlansWithCompletion:^(NSArray *plans, CFSError *error) {
                  CFSPlan *plan = plans[0];
                  XCTAssertNil(error, "Create plan error should be nil.");
                  XCTAssertNotNil(plan, "Plan should not be nil.");
                  CFSSession *ses = [CFSBaseTests getSession];
                  [ses accountWithCompletion:^(CFSAccount *account, CFSError *error) {
                      [[CFSBaseTests getSession] updateUserWithId:account.accountId
                                                         userName:nil firstName:@"TestUserNameChanged"
                                                         lastName:@"TestUserLastNameChanged"
                                                         planCode:nil
                                                   WithCompletion:^(CFSUser *updatedUser, CFSError *error) {
                          XCTAssertNil(error, "UpdatedAccount error should be nil.");
                          XCTAssertNotNil(updatedUser, "User should not be nil.");
                          [[CFSBaseTests getSession] authenticateWithUsername:updatedUser.userName
                                                                  andPassword:@"user@123"
                                                                   completion:^(NSString *token, BOOL success, CFSError *error) {
                              XCTAssertNil(error, "Error should be nil.");
                              XCTAssertNotNil(token, "Token should not be nil.");
                              [[CFSBaseTests getSession] unlink];
                              [updateUserExpectation fulfill];
                          }];
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
    CFSPlistReader *plistReader = [[CFSPlistReader alloc] initWithFileName:@"CloudFSConfig"];
    
    [[CFSBaseTests getSession] setAdminCredentialsWithAdminClientId:[plistReader appConfigValueForKey:@"CFS_ADMIN_ID"]
                                                  adminClientSecret:[plistReader appConfigValueForKey:@"CFS_ADMIN_SECRET"]];
    
    XCTestExpectation *createPlanExpectation = [self expectationWithDescription:@"authentication"];
    
    [[CFSBaseTests getSession] createPlanWithName:[self getRandomEmail]
                                            limit:@"1024" completion:^(CFSPlan *plan, CFSError *error) {
        XCTAssertNil(error, "Create plan error should be nil.");
        XCTAssertNotNil(plan, "Plan should not be nil.");
        [[CFSBaseTests getRestAdapter]  deletePlan:plan.planId completion:^(BOOL success, CFSError *error) {
            XCTAssertNil(error, "Delete plan error should be nil.");
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
    CFSPlistReader *plistReader = [[CFSPlistReader alloc] initWithFileName:@"CloudFSConfig"];
    
    [[CFSBaseTests getSession] setAdminCredentialsWithAdminClientId:[plistReader appConfigValueForKey:@"CFS_ADMIN_ID"]
                                                  adminClientSecret:[plistReader appConfigValueForKey:@"CFS_ADMIN_SECRET"]];
    
    XCTestExpectation *listPlanExpectation = [self expectationWithDescription:@"authentication"];
    
    [[CFSBaseTests getSession] listPlansWithCompletion:^(NSArray *plans, CFSError *error) {
        XCTAssertNil(error, "List plans error should be nil.");
        XCTAssertNotNil(plans, "List plans not be nil.");
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
    XCTestExpectation *isLinkedExpectation = [self expectationWithDescription:@"isLinked"];
    [[CFSBaseTests getSession] isLinkedWithCompletion:^(BOOL response, CFSError *error) {
        XCTAssertTrue(!response, "Session should be unlinked.");
        [isLinkedExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {}];
}

- (void)testIsLinkedTrue
{
    XCTestExpectation *isLinkedExpectation = [self expectationWithDescription:@"isLinked"];
    [[CFSBaseTests getSession] isLinkedWithCompletion:^(BOOL ping, CFSError *error) {
        XCTAssertFalse(!ping, "Session should be unlinked.");
        [isLinkedExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:300 handler:^(NSError *error) {}];
}

/*!
 *  Unlink session from server
 */
- (void)testUnlink
{
    [[CFSBaseTests getSession] unlink];
    XCTestExpectation *isLinkedExpectation = [self expectationWithDescription:@"isLinked"];
    [[CFSBaseTests getSession] isLinkedWithCompletion:^(BOOL ping, CFSError *error) {
        XCTAssertTrue(!ping, "Session should be unlinked.");
        [isLinkedExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {}];
}

/*!
 *  Tests user of the current session
 */
- (void)testUser
{
    XCTestExpectation *testUserExpectation = [self expectationWithDescription:@"user"];
    [[CFSBaseTests getSession] userWithCompletion:^(CFSUser *user, CFSError *error) {
        XCTAssertNotNil(user, "User should not be nil.");
        [testUserExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {}];
}

/*!
 *  Tests account of the current session
 */
- (void)testAccount
{
    XCTestExpectation *testAccountExpectation = [self expectationWithDescription:@"user"];
    
    [[CFSBaseTests getSession] accountWithCompletion:^(CFSAccount *account, CFSError *error) {
        XCTAssertNotNil(account, "Account should not be nil.");
        [testAccountExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {}];
}

/*!
 *  Tests account of the current session
 */
- (void)testFileSystem
{
    CFSFilesystem *filesystem = [CFSBaseTests getSession].fileSystem;
    XCTAssertNotNil(filesystem, "Filesystem should not be nil.");
    [[CFSBaseTests getSession] unlink];
    XCTAssertNil(filesystem, "Filesystem should be nil.");
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
