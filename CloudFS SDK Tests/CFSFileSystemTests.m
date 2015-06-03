//
//  CFSFileSystemTests.m
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
#import "CFSPlistReader.h"
#import "CFSFileSystem.h"
#import "CFSBaseTests.h"
#import "CFSFile.h"
#import "CFSSession.h"

@interface CFSFileSystemTests : CFSBaseTests

@end

@implementation CFSFileSystemTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

/*!
 *  Test root folder
 */
- (void)testRoot
{
    XCTestExpectation *rootExpectation = [self expectationWithDescription:@"root"];
    
    [((CFSSession *)[CFSBaseTests getSession]).fileSystem rootWithCompletion:^(CFSFolder *root, CFSError *error) {
        XCTAssertNil(error, "error should be nil");
        XCTAssertNotNil(root, "Root should not be nil");
        [rootExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:20 handler:^(NSError *error) {}];
}

/*!
 *  Test getting an item
 */
- (void)testGetItem
{
    [self createTestFolder];
    XCTestExpectation *getItemExpectation = [self expectationWithDescription:@"getItem"];
    [self uploadContents:@"test stuff"
                fileName:@"getItemTest"
                toFolder:[self getTestFolder]
              whenExists:CFSExistsOverwrite
              completion:^(CFSFile *file, CFSError *error, int uploadedFileSize) {
        [((CFSSession *)[CFSBaseTests getSession]).fileSystem getItem:file.path completion:^(CFSItem *item, CFSError *error) {
            XCTAssertNil(error, "error should be nil");
            XCTAssertNotNil(item, "Root should not be nil");
            [getItemExpectation fulfill];
        }];
    }];
    [self waitForExpectationsWithTimeout:300 handler:^(NSError *error) {}];
}

/*!
 *  Test the list of trash
 */
- (void)testListTrash
{
    XCTestExpectation *listTrashExpectation = [self expectationWithDescription:@"listTrash"];
    [((CFSSession *)[CFSBaseTests getSession]).fileSystem listTrashWithCompletion:^(NSArray *items, CFSError *error) {
        XCTAssertNil(error, "error should be nil");
        XCTAssertNotNil(items, "Root should not be nil");
        [listTrashExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:40 handler:^(NSError *error) {}];
}

@end
