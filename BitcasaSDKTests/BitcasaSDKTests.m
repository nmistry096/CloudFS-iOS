//
//  BitcasaSDKTests.m
//  BitcasaSDKTests
//
//  Created by Olga on 8/21/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Session.h"
#import "Credentials.h"
#import "BitcasaAPI.h"
#import "User.h"
#import "Account.h"
#import "Container.h"

@interface BitcasaSDKTests : XCTestCase

@end

@implementation BitcasaSDKTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    Session* session = [[Session alloc] initWithServerURL:@"https://w2krfscy4f.cloudfs.io"
                                                 clientId:@"aajNc4HKqv1cBR8y9g62YTrXyE6jn3zXJ_Nw8yXRQKU"
                                             clientSecret:@"yHTQD57owFI9kEJmKnjMDUyK-233Xx-dADxsf17MdaDd1zCCp2Vuiy8aGEj6GHFzeSxLntdJN51fPI2guTaGCw"];
    
    [session authenticateWithUsername:@"hchou@bitcasa.com"
                          andPassword:@"bitcasa543"];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAuth
{
    XCTAssertNotNil([Credentials sharedInstance].serverURL, @"");
    XCTAssertNotNil([Credentials sharedInstance].accessToken, @"");
}

- (void)testGetProfile
{
    __block BOOL terminateRunLoop = NO;
    [BitcasaAPI getProfileWithCompletion:^(NSDictionary* response)
    {
        terminateRunLoop = YES;
        
        User* user = [[User alloc] initWithDictionary:response];
        Account* account = [[Account alloc] initWithDictionary:response];
        
        XCTAssertNotNil(user);
        XCTAssertNotNil(account);
    }];
    
    // Run until 'terminateRunLoop' is flagged
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !terminateRunLoop){};
}

- (void)testGetListOfItems
{
    __block BOOL terminateRunLoop = NO;
    [BitcasaAPI getContentsOfContainer:nil completion:^(NSArray *items)
    {
        terminateRunLoop = YES;
        
        XCTAssertNotNil(items);
        XCTAssert(items.count == 18);
    }];
    
    // Run until 'terminateRunLoop' is flagged
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !terminateRunLoop){};
}

- (void)testCreateFolder
{
    __block BOOL terminateRunLoop = NO;
    
    Container* rootDir = [[Container alloc] initRootContainer];
    [rootDir createFolder:@"bf_jeans" completion:^(Container *newDir)
    {
        XCTAssertNotNil(newDir);
        
        [newDir deleteWithCompletion:^(BOOL success)
        {
            terminateRunLoop = YES;
            XCTAssertTrue(success);
        }];
    }];

    // Run until 'terminateRunLoop' is flagged
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !terminateRunLoop){};
}

- (void)testCopyItems
{
    __block BOOL terminateRunLoop = NO;
    
    Container* rootDir = [[Container alloc] initRootContainer];
    [rootDir createFolder:@"copied_items" completion:^(Container *newDir)
     {
         XCTAssertNotNil(newDir);
         
         [rootDir listItemsWithCompletion:^(NSArray *items)
         {
             XCTAssertNotNil(items);
             NSInteger randomIndex = arc4random()%items.count;
             [items[randomIndex] copyToDestinationContainer:newDir completion:^(Item *newItem)
             {
                 XCTAssertNotNil(newItem);
                 [newDir deleteWithCompletion:^(BOOL success)
                  {
                      terminateRunLoop = YES;
                      XCTAssertTrue(success);
                  }];
             }];
         }];
     }];
    
    // Run until 'terminateRunLoop' is flagged
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !terminateRunLoop){};
}

- (void)testMoveItems
{
    __block BOOL terminateRunLoop = NO;
    
    Container* rootDir = [[Container alloc] initRootContainer];
    [rootDir createFolder:@"moved_items" completion:^(Container *newDir)
     {
         XCTAssertNotNil(newDir);
         
         [rootDir listItemsWithCompletion:^(NSArray *items)
          {
              XCTAssertNotNil(items);
              NSInteger randomIndex = arc4random()%items.count;
              id item = items[randomIndex];
              [item moveToDestinationContainer:newDir completion:^(Item *movedItem)
              {
                  XCTAssertNotNil(movedItem);
                  
                  [movedItem moveToDestinationContainer:rootDir completion:^(Item *movedItem)
                  {
                      XCTAssertNotNil(movedItem);
                      [newDir deleteWithCompletion:^(BOOL success)
                       {
                           terminateRunLoop = YES;
                           XCTAssertTrue(success);
                       }];
                  }];

              }];
          }];
     }];

    // Run until 'terminateRunLoop' is flagged
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !terminateRunLoop){};
}

@end
