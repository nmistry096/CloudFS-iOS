//
//  CFSFolderTests.m
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
#import "CFSFolder.h"
#import "CFSFile.h"
#import "CFSPlistReader.h"
#import "CFSBaseTests.h"

@class CFSError, CFSContainer;

const int FOLDER_TIME_DELAY = 60;
NSString *FOLDER_NAME = @"ABCD";
CFSFolder *folder;
int fileSize;

@interface CFSFolderTests : CFSBaseTests

@end

@implementation CFSFolderTests

NSString *_createdFolderName;
XCTestExpectation *_uploadItemsExpectation;

- (void)setUp {
    [super setUp];
    [self createTestFolder];
}

- (void)tearDown {
    [self deleteTestFolder];
    [super tearDown];
}

/*!
 *  Tests folder create function with reuse item operation
 */
- (void)CreateFolderReuse
{
    CFSFolder *cfsFolder = [self getTestFolder];
    XCTestExpectation *createFolderReuseExpectation = [self expectationWithDescription:@"createFolderReuse"];
    [cfsFolder createFolder:BITCASA_TEST_FOLDER whenExists:CFSItemExistsOverwrite completion:^(CFSFolder *newDir, CFSError *error) {
        [cfsFolder createFolder:BITCASA_TEST_FOLDER whenExists:CFSItemExistsReuse completion:^(CFSFolder *newDir, CFSError *error) {
           [createFolderReuseExpectation fulfill];
        }];
    }];
    [self waitForExpectationsWithTimeout:FOLDER_TIME_DELAY handler:nil];
}

/*!
 *  Tests folder create function with overwrite item operation
 */
- (void)testCreateFolderOverwrite
{
    CFSFolder *container = [self getTestFolder];
    XCTestExpectation *createFolderOverWriteExpectation = [self expectationWithDescription:@"createFolderOverWrite"];
    
    [container createFolder:FOLDER_NAME whenExists:CFSItemExistsOverwrite completion:^(CFSFolder *newDir, CFSError *error) {
        XCTAssertNil(error, "Error should be nil");
        
        [container createFolder:FOLDER_NAME whenExists:CFSItemExistsOverwrite completion:^(CFSFolder *newDir, CFSError *error) {
            XCTAssert([newDir.type isEqualToString:CFSItemTypeFolder], "Type should be folder");
            XCTAssertNil(error, "Error should be nil");
            XCTAssertNotNil(newDir, "Created Folder should not be nil");
            BOOL condition = [newDir.name isEqualToString:FOLDER_NAME];
            XCTAssert(condition, "Should have the expected folder name");
            NSString *itemId = newDir.itemId;
            
            [self folderItemsWithCompletion:container completion:^(NSArray *items, CFSError *error) {
                XCTAssertNil(error, "Error should be nil");
                CFSContainer *createdFolder;
                BOOL foundFolder = NO;
                int folderCount = 0;
                for (CFSItem *item in items) {
                    if ([item.itemId isEqualToString:itemId]) {
                        // Found created folder on cloud
                        createdFolder = (CFSContainer *)item;
                        foundFolder = YES;
                    }
                    
                    if ([item.type isEqualToString:CFSItemTypeFolder]) {
                        folderCount++;
                        XCTAssert([item.name isEqualToString:FOLDER_NAME], "Should have the desired folder name");
                    }
                }
                
                XCTAssert(items.count == 1, "Should have 1 item");
                XCTAssert(folderCount == 1, "Should have 1 folder");
                XCTAssert(foundFolder, @"Pass");
                [createFolderOverWriteExpectation fulfill];
            }];
        }];
    }];
   [self waitForExpectationsWithTimeout:FOLDER_TIME_DELAY handler:nil];
}

/*!
 *  Tests folder create function with rename item operation
 */
- (void)testCreateFolderRename
{
    CFSFolder *container = [self getTestFolder];
    XCTestExpectation *createFolderRenameExpectation = [self expectationWithDescription:@"createFolderRename"];
    
    [container createFolder:FOLDER_NAME whenExists:CFSItemExistsRename completion:^(CFSFolder *newDir, CFSError *error) {
    XCTAssertNil(error, "Error should be nil");
    XCTAssert([newDir.name isEqualToString:FOLDER_NAME], "Should have the desired folder name");
        
        [container createFolder:FOLDER_NAME whenExists:CFSItemExistsRename completion:^(CFSFolder *newDir, CFSError *error) {
            XCTAssertNil(error, "Error should be nil");
            XCTAssert([newDir.type isEqualToString:CFSItemTypeFolder], "Type should be folder");
            XCTAssertNotNil(newDir.name, "Created Folder should not be nil");
            NSString *renameFileSubString = [NSString stringWithFormat:@"%@ (", FOLDER_NAME];
            BOOL subStringFound = NO;
            subStringFound = !([newDir.name rangeOfString:renameFileSubString].location == NSNotFound);
            XCTAssert(subStringFound, "Should have the expected folder name");
            
            [self folderItemsWithCompletion:container completion:^(NSArray *items, CFSError *error) {
                XCTAssertNil(error, "Error should be nil");
                int folderCount = 0;
                for (CFSItem *item in items) {
                    if ([item.type isEqualToString:CFSItemTypeFolder]) {
                      folderCount++;
                    }
                }
                
                XCTAssert(items.count == 2, "Should have 2 items");
                XCTAssert(folderCount == 2, "Should have 2 folders");
                [createFolderRenameExpectation fulfill];
            }];
        }];
     }];
    [self waitForExpectationsWithTimeout:FOLDER_TIME_DELAY handler:nil];
}

/*!
 *  This is a convienience method that retrieves all the items
 *
 *  @param completion The completion handler to call after the operation is over
 *  @param folder The folder whose items needs to be listed
 */
- (void)folderItemsWithCompletion:(CFSFolder *)folder completion:(void (^)(NSArray *items, CFSError *error))completion {
    [folder listWithCompletion:^(NSArray *items, CFSError *error) {
        completion(items, error);
    }];
}

/*!
 *  Tests folder create function with fail operation
 */
- (void)testCreateFolderFailOperation
{
    CFSFolder *container = [self getTestFolder];
    XCTestExpectation *createFolderFailExpectation = [self expectationWithDescription:@"createFolderFail"];
    
    [container createFolder:FOLDER_NAME whenExists:CFSItemExistsFail completion:^(CFSFolder *newDir, CFSError *error) {
        XCTAssertNil(error, "Error should be nil");
        XCTAssert([newDir.name isEqualToString:FOLDER_NAME], "Should have the desired folder name");
        
        [container createFolder:FOLDER_NAME whenExists:CFSItemExistsFail completion:^(CFSFolder *newDir, CFSError *error) {
            XCTAssert(error.code == 2042, "Should have expected error code");
            XCTAssertNil(newDir, "Created Folder should be nil");
            
            [self folderItemsWithCompletion:container completion:^(NSArray *items, CFSError *error) {
                XCTAssertNil(error, "Error should be nil");
                CFSFolder *folder = (CFSFolder *)items[0];
                XCTAssert([folder.name isEqualToString:FOLDER_NAME], "Should have the desired folder name");
                XCTAssert(items.count == 1, "Should have 1 folder");
               [createFolderFailExpectation fulfill];
            }];
        }];
    }];
    [self waitForExpectationsWithTimeout:FOLDER_TIME_DELAY handler:nil];
}

/*!
 *  Tests folder create function with default operation which is fail
 */
- (void)testCreateFolderDefaultOperation
{
    CFSFolder *container = [self getTestFolder];
    XCTestExpectation *createFolderFailExpectation = [self expectationWithDescription:@"createFolderFail"];
    
    [container createFolder:FOLDER_NAME whenExists:CFSItemExistsDefault completion:^(CFSFolder *newDir, CFSError *error) {
        XCTAssertNil(error, "Error should be nil");
        XCTAssert([newDir.name isEqualToString:FOLDER_NAME], "Should have the desired folder name");
        
        [container createFolder:FOLDER_NAME whenExists:CFSItemExistsDefault completion:^(CFSFolder *newDir, CFSError *error) {
            XCTAssert(error.code == 2042, "Should have expected error code");
            XCTAssertNil(newDir, "Created Folder should be nil");
            
            [self folderItemsWithCompletion:container completion:^(NSArray *items, CFSError *error) {
                XCTAssertNil(error, "Error should be nil");
                CFSFolder *folder = (CFSFolder *)items[0];
                XCTAssert([folder.name isEqualToString:FOLDER_NAME], "Should have the desired folder name");
                XCTAssert(items.count == 1, "Should have 1 folder");
                [createFolderFailExpectation fulfill];
            }];
        }];
    }];
    [self waitForExpectationsWithTimeout:FOLDER_TIME_DELAY handler:nil];
}

/*!
 *  Tests file upload function
 */
- (void)testFileUpload
{
    NSString *fileName = @"bitcasa-logo-test";
    NSString *type = @"png";
    
    __block CFSFile *file = nil;
    __block CFSError *cfsError = nil;
    
    XCTestExpectation *uploadFileExpectation = [self expectationWithDescription:@"testUploadFile"];
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:fileName ofType:type];
    
    CFSFolder *testFolder = [self getTestFolder];
    
    [testFolder upload:path
              progress:^(NSInteger uploadId, NSString *path, int64_t completedBytes, int64_t totalBytes) {
                  NSLog(@"Test %lld", completedBytes);
              }
            completion:^(NSInteger uploadId, NSString *path, CFSFile *cfsFile, CFSError *error) {
                file = cfsFile;
                cfsError = error;
                [uploadFileExpectation fulfill];
            }
            whenExists:CFSExistsOverwrite];
    
    [self waitForExpectationsWithTimeout:FOLDER_TIME_DELAY handler:^(NSError *error) {}];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:url.path error:nil];
    NSString *fileNamePath = [NSString stringWithFormat:@"%@.%@", fileName, type];
    XCTAssertTrue(file.size == [attributes[NSFileSize] intValue]);
    XCTAssertTrue([file.extension isEqualToString:type]);
    XCTAssertTrue([file.name isEqualToString:fileNamePath]);
    XCTAssertNil(cfsError);
}
@end
