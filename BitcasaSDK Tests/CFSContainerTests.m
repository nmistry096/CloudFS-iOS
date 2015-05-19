//
//  CFSContainerTests.m
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
#import "CFSContainer.h"
#import "CFSRestAdapter.h"
#import "CFSFolder.h"
#import "CFSPlistReader.h"
#import "CFSBaseTests.h"
#import "CFSFileSystem.h"
#import "CFSFile.h"

@class CFSError, CFSContainer;

const int CONTAINER_TIME_DELAY = 60;

@interface CFSContainerTests : CFSBaseTests

@end

@implementation CFSContainerTests

- (void)setUp {
    [super setUp];
    [self createTestFolder];
}

- (void)tearDown {
    [super tearDown];
    [self deleteTestFolder];
}

/*!
 *  Tests Container list all items function
 */
- (void)testGetListItems
{
    CFSFolder *folder = [self getTestFolder];
    XCTestExpectation *listContainerItemsExpectation = [self expectationWithDescription:@"listContainerItems"];
    
    [folder createFolder:@"Folder" whenExists:CFSItemExistsOverwrite completion:^(CFSFolder *newDir, CFSError *error) {
        XCTAssertNotNil(newDir);
        
        [self uploadContents:@"Hello World"
                    fileName:@"Hello"
                    toFolder:folder
                  whenExists:CFSExistsOverwrite
                  completion:^(CFSFile *file, CFSError *error, int uploadedFileSize) {
            XCTAssertNotNil(file);
                      
            [folder listWithCompletion:^(NSArray *items, CFSError *error) {
                int folders = 0;
                int files = 0;
                BOOL foundFolder = NO;
                BOOL foundFile = NO;
                for (CFSItem *item in items) {
                    if ([item.type isEqualToString:CFSItemTypeFolder]) {
                        folders++;
                    } else if ([item.type isEqualToString:CFSItemTypeFile]) {
                        files++;
                    }
                    
                    if ([item.itemId isEqualToString:newDir.itemId]) {
                        foundFolder = YES;
                    } else if ([item.itemId isEqualToString:file.itemId]) {
                        foundFile = YES;
                    }
                }
                
                XCTAssertTrue(foundFolder, "Created folder not found");
                XCTAssertTrue(foundFile, "Uploaded file not found");
                XCTAssertNil(error, "Folder list items error should be nil");
                XCTAssert(items.count == 2, "Should have two items");
                XCTAssert(folders == 1, "Should have one folder");
                XCTAssert(files == 1, "Should havve one file");
                [listContainerItemsExpectation fulfill];
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:CONTAINER_TIME_DELAY handler:^(NSError *error) {
        // handler is called on _either_ success or failure
        if (error != nil) {
            XCTFail(@"timeout error: %@", error);
        }
    }];
}

@end
