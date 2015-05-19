//
//  CFSShareTests.m
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
#import "CFSRestAdapter.h"
#import "CFSFilesystem.h"
#import "CFSPlistReader.h"
#import "CFSFile.h"
#import "CFSFolder.h"
#import "CFSShare.h"
#import "CFSError.h"
#import "CFSBaseTests.h"
#import "CFSSession.h"

const int SHARE_TIME_DELAY = 60;
NSString *SHARE_PASSWORD = @"123456";

NSString *fileName = @"FileName";
NSString *fileExtension = @".txt";

@interface CFSShareTests : CFSBaseTests

@end

@implementation CFSShareTests

XCTestExpectation *_uploadItemsExpectation;

- (void)setUp {
    [super setUp];
    [self createTestFolder];
}

- (void)tearDown {
    [self deleteTestFolder];
    [super tearDown];
}

#pragma mark - Share create delete test

/*!
 *  Tests create, delete share and list share functions
 */
- (void)testCreateShareAndDeleteShare
{
    XCTestExpectation *testCreateShare = [self expectationWithDescription:@"createShare"];
    CFSFilesystem *fileSystem = ((CFSSession *)[CFSBaseTests getSession]).fileSystem;
    
    [self uploadContents:@"Hello World" fileName:fileName toFolder:[self getTestFolder] whenExists:CFSExistsOverwrite completion:^(CFSFile *file, CFSError *error, int uploadedFileSize) {
        
        XCTAssertNil(error, "Error should be nil");
        XCTAssert(file.path.length > 0, "File path should not be zero");
        
        CFSFile *file2 = file;
        
        [self uploadContents:@"Hello World" fileName:@"Hello World2" toFolder:[self getTestFolder] whenExists:CFSExistsOverwrite completion:^(CFSFile *file, CFSError *error, int uploadedFileSize) {
        
            XCTAssertNil(error, "Error should be nil");
            XCTAssert(file.path.length > 0, "File path should not be zero");
            
            [fileSystem createShare:@[file2.path, file.path] password:SHARE_PASSWORD completion:^(CFSShare *share, CFSError *error) {
                CFSShare *createdShare = share;
                XCTAssertNil(error, "Error should be nil");
                
                [fileSystem listSharesWithCompletion:^(NSArray *items, CFSError *error) {
                    XCTAssertNil(error, "Error should be nil");
                    __block BOOL foundShare = NO;
                    for (CFSShare *share in items) {
                        if ([share.shareKey isEqualToString:createdShare.shareKey]) {
                            foundShare = YES;
                        }
                    }
                    
                    XCTAssert(foundShare, "The created share should have been there");
                    [createdShare deleteWithcompletion:^(BOOL success, CFSError *error) {
                         XCTAssertNil(error, "Error should be nil");
                         [fileSystem listSharesWithCompletion:^(NSArray *items, CFSError *error) {
                             XCTAssertNil(error, "Error should be nil");
                             foundShare = NO;
                             for (CFSShare *share in items) {
                                 if ([share.shareKey isEqualToString:createdShare.shareKey]) {
                                     foundShare = YES;
                                 }
                             }
                             XCTAssert(!foundShare, "The Created Share should have been deleted");
                             [testCreateShare fulfill];
                         }];
                    }];
                }];
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:SHARE_TIME_DELAY handler:nil];
}

#pragma mark - Retrieve Share Tests

/*!
 *  Tests receive share with correct password
 */
- (void)testRetrieveShare
{
    XCTestExpectation *testUnlockShare = [self expectationWithDescription:@"unlockShare"];
    CFSFilesystem *fileSystem = ((CFSSession *)[CFSBaseTests getSession]).fileSystem;
    
    [self uploadContents:@"Hello World" fileName:fileName toFolder:[self getTestFolder] whenExists:CFSExistsOverwrite completion:^(CFSFile *file, CFSError *error, int uploadedFileSize) {
        XCTAssertNil(error, "Error should be nil");
        XCTAssert(file.path.length > 0, "File path should not be zero");
        
        [fileSystem createShare:@[file.path] password:SHARE_PASSWORD completion:^(CFSShare *share, CFSError *error) {
            CFSShare *createdShare = share;
            
            [fileSystem retrieveShare:share.shareKey password:SHARE_PASSWORD completion:^(CFSShare *share, CFSError *error) {
                XCTAssertNil(error, "Error should be nil");
                XCTAssert([share.shareKey isEqualToString:createdShare.shareKey], "Unlocked share should have the same share key");
               
                [createdShare deleteWithcompletion:^(BOOL success, CFSError *error) {
                    [testUnlockShare fulfill];
                }];
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:SHARE_TIME_DELAY handler:nil];
}

/*!
 *  Tests receive share with incorrect password
 */
- (void)testRetrieveShareWrongPassword
{
    XCTestExpectation *testUnlockShare = [self expectationWithDescription:@"unlockShare"];
    CFSFilesystem *fileSystem = ((CFSSession *)[CFSBaseTests getSession]).fileSystem;

    [self uploadContents:@"Hello World" fileName:fileName toFolder:[self getTestFolder] whenExists:CFSExistsOverwrite completion:^(CFSFile *file, CFSError *error, int uploadedFileSize) {
        XCTAssertNil(error, "Error should be nil");
        XCTAssert(file.path.length > 0, "File path should not be zero");
        
        [fileSystem createShare:@[file.path] password:SHARE_PASSWORD completion:^(CFSShare *share, CFSError *error) {
            CFSShare *createdShare = share;
           
            [fileSystem retrieveShare:share.shareKey password:@"wrongPassword" completion:^(CFSShare *share, CFSError *error) {
                XCTAssert(error.code == 4001, "The error object should have the expected error code");
                [createdShare deleteWithcompletion:^(BOOL success, CFSError *error) {
                    [testUnlockShare fulfill];
                }];
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:SHARE_TIME_DELAY handler:nil];
}

#pragma mark - Share change attributes tests

/*!
 *  Tests change share attributes
 */
- (void)testChangeShareAttributes
{
    XCTestExpectation *testchangeAttributesShare = [self expectationWithDescription:@"testChangeAttributes"];
    CFSFilesystem *fileSystem = ((CFSSession *)[CFSBaseTests getSession]).fileSystem;

    [self uploadContents:@"Hello World" fileName:fileName toFolder:[self getTestFolder] whenExists:CFSExistsOverwrite completion:^(CFSFile *file, CFSError *error, int uploadedFileSize) {
        XCTAssertNil(error, "Error should be nil");
        XCTAssert(file.path.length > 0, "File path should not be zero");
        
        [fileSystem createShare:@[file.path] password:SHARE_PASSWORD completion:^(CFSShare *share, CFSError *error) {
                CFSShare *createdShare = share;
                NSDictionary *values = @{ @"name" : @"newName"};
            
                [share changeAttributes:values password:SHARE_PASSWORD completion:^(BOOL success, CFSError *error) {
                XCTAssertNil(error, "Error should be nil");
                XCTAssert([createdShare.name isEqualToString:@"newName"], "Share name should have the expected name");
                
                [createdShare deleteWithcompletion:^(BOOL success, CFSError *error) {
                    [testchangeAttributesShare fulfill];
                }];
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:SHARE_TIME_DELAY handler:nil];
}

/*!
 *  Tests change share attributes with wrong password
 */
- (void)ChangeShareAttributesWithWrongPassword
{
    XCTestExpectation *testchangeAttributesShare = [self expectationWithDescription:@"testChangeAttributes"];
    CFSFilesystem *fileSystem = ((CFSSession *)[CFSBaseTests getSession]).fileSystem;

    [self uploadContents:@"Hello World" fileName:fileName toFolder:[self getTestFolder] whenExists:CFSExistsOverwrite completion:^(CFSFile *file, CFSError *error, int uploadedFileSize) {
        XCTAssertNil(error, "Error should be nil");
        XCTAssert(file.path.length > 0, "File path should not be zero");
        
        [fileSystem createShare:@[file.path] password:SHARE_PASSWORD completion:^(CFSShare *share, CFSError *error) {
            CFSShare *createdShare = share;
            NSDictionary *values = @{ @"name" : @"newName"};
            
            [share changeAttributes:values password:@"wrong" completion:^(BOOL success, CFSError *error) {

                [createdShare deleteWithcompletion:^(BOOL success, CFSError *error) {
                    [testchangeAttributesShare fulfill];
                }];
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:SHARE_TIME_DELAY handler:nil];
}

/*!
 *  Tests set share name
 */
- (void)testSetShareNameAsync
{
    XCTestExpectation *testShareSetName = [self expectationWithDescription:@"testShareSetName"];
    CFSFilesystem *fileSystem = ((CFSSession *)[CFSBaseTests getSession]).fileSystem;
    
    [self uploadContents:@"Hello World" fileName:fileName toFolder:[self getTestFolder] whenExists:CFSExistsOverwrite completion:^(CFSFile *file, CFSError *error, int uploadedFileSize) {
        XCTAssertNil(error, "Error should be nil");
        XCTAssert(file.path.length > 0, "File path should not be zero");
        
        [fileSystem createShare:@[file.path] password:SHARE_PASSWORD completion:^(CFSShare *share, CFSError *error) {
            XCTAssert(error == nil, "Error should be nil");
            BOOL success = [share setName:@"EEEEE" usingCurrentPassword:SHARE_PASSWORD];
            XCTAssert(success, "Share set name should return TRUE");
            [testShareSetName fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:SHARE_TIME_DELAY handler:nil];
}

/*!
 *  Tests set share password
 */
- (void)testSetSharePassword
{
    XCTestExpectation *testSharePassword = [self expectationWithDescription:@"testSharePassword"];
    CFSFilesystem *fileSystem = ((CFSSession *)[CFSBaseTests getSession]).fileSystem;

    [self uploadContents:@"Hello World" fileName:fileName toFolder:[self getTestFolder] whenExists:CFSExistsOverwrite completion:^(CFSFile *file, CFSError *error, int uploadedFileSize) {
        XCTAssertNil(error, "Error should be nil");
        XCTAssert(file.path.length > 0, "File path should not be zero");
        
        [fileSystem createShare:@[file.path] password:@"123456" completion:^(CFSShare *share, CFSError *error) {
            NSString *shareKey = share.shareKey;
            
            [share setPasswordTo:@"KKKKKK" from:@"123456" completion:^(BOOL success, CFSError *error) {
                XCTAssertNil(error, "Error should be nil");
                
                [fileSystem retrieveShare:shareKey password:@"KKKKKK" completion:^(CFSShare *share, CFSError *error) {
                    XCTAssert([share.shareKey isEqualToString:shareKey], "Should have the same share key");
                    XCTAssert(error == nil, "Share should unlock with newly set password");
                    [testSharePassword fulfill];
                }];
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:SHARE_TIME_DELAY handler:nil];
}

#pragma mark - Receive share tests

/*!
 *  Tests receive share with rename exists operation
 */
- (void)testReceiveShareExistsRename
{
    XCTestExpectation *testreceiveShare = [self expectationWithDescription:@"testReceiveShare"];
    CFSFilesystem *fileSystem = ((CFSSession *)[CFSBaseTests getSession]).fileSystem;
    CFSFolder *folder = [self getTestFolder];
    
    [self uploadContents:@"Hello World" fileName:fileName toFolder:folder whenExists:CFSExistsOverwrite completion:^(CFSFile *file, CFSError *error, int uploadedFileSize) {
        XCTAssertNil(error, "Error should be nil");
        XCTAssert(file.path.length > 0, "File path should not be zero");
        
        [fileSystem createShare:@[file.path] password:SHARE_PASSWORD completion:^(CFSShare *share, CFSError *error) {
            [folder listWithCompletion:^(NSArray *items, CFSError *error) {
                XCTAssertNil(error, "Error should be nil");
                NSUInteger count = items.count;
                
                [share receiveShare:folder.path whenExists:CFSExitsRename completion:^(NSArray *items, CFSError *error) {
                    XCTAssertNil(error, "Error should be nil");
                    NSString *renameFileSubString = [NSString stringWithFormat:@"%@ (", fileName];
                    BOOL subStringFound = NO;
                    if (((CFSItem *)items[0]).name) {
                    subStringFound = !([((CFSItem *)items[0]).name rangeOfString:renameFileSubString].location == NSNotFound);
                    }
                    
                    XCTAssert(subStringFound, "Share item should have renamed");
                    
                    [folder listWithCompletion:^(NSArray *items, CFSError *error) {
                        XCTAssert((items.count == count + 1), "Share item not created in folder");
                        
                        [share deleteWithcompletion:^(BOOL success, CFSError *error) {
                            [testreceiveShare fulfill];
                        }];
                    }];
                }];
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:SHARE_TIME_DELAY handler:nil];
}

/*!
 *  Tests receive share with overwrite exists operation
 */
- (void)testReceiveShareExistsOverwrite
{
    XCTestExpectation *testreceiveShare = [self expectationWithDescription:@"testReceiveShare"];
    CFSFolder *folder = [self getTestFolder];
    
    [self uploadContents:@"Hello World"
                fileName:[NSString stringWithFormat:@"%@%@", fileName, fileExtension]
                toFolder:folder whenExists:CFSExistsOverwrite completion:^(CFSFile *file, CFSError *error, int uploadedFileSize) {
        XCTAssertNil(error, "Error should be nil");
        XCTAssert(file.path.length > 0, "File path should not be zero");
        
        CFSFilesystem *fileSystem = ((CFSSession *)[CFSBaseTests getSession]).fileSystem;
        [fileSystem createShare:@[file.path] password:SHARE_PASSWORD completion:^(CFSShare *share, CFSError *error) {
            XCTAssertNil(error, "Error should be nil");
            
            [folder listWithCompletion:^(NSArray *items, CFSError *error) {
                NSUInteger count = items.count;
                
                [share receiveShare:folder.path whenExists:CFSExistsOverwrite completion:^(NSArray *items, CFSError *error) {
                    XCTAssertNil(error, "Error should be nil");
                    
                    [folder listWithCompletion:^(NSArray *items, CFSError *error) {
                        XCTAssert(count == items.count, "Folder count mismatch");
                        NSString *fileNameToCheck = [NSString stringWithFormat:@"%@%@", fileName, fileExtension];
                        XCTAssert([((CFSItem *)items[0]).name isEqualToString:fileNameToCheck], "Should have same name");
                        
                        [share deleteWithcompletion:^(BOOL success, CFSError *error) {
                            [testreceiveShare fulfill];
                        }];
                    }];
                }];
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:SHARE_TIME_DELAY handler:nil];
}

/*!
 *  Tests receive share with exists fail operation
 */
- (void)testReceiveShareExistsFail
{
    XCTestExpectation *testreceiveShare = [self expectationWithDescription:@"testReceiveShare"];
    CFSFilesystem *fileSystem = ((CFSSession *)[CFSBaseTests getSession]).fileSystem;
    CFSFolder *folder = [self getTestFolder];
    
    [self uploadContents:@"Hello World"
                fileName:fileName
                toFolder:folder
              whenExists:CFSExistsOverwrite completion:^(CFSFile *file, CFSError *error, int uploadedFileSize) {
        XCTAssertNil(error, "Error should be nil");
        XCTAssert(file.path.length > 0, "File path should not be zero");
        
        [fileSystem createShare:@[file.path] password:SHARE_PASSWORD completion:^(CFSShare *share, CFSError *error) {
            
            [folder listWithCompletion:^(NSArray *items, CFSError *error) {
                NSUInteger count = items.count;
                
                [share receiveShare:folder.path whenExists:CFSExistsFail completion:^(NSArray *items, CFSError *error) {
                    XCTAssert(error.code == 2042, "The error object should have the expected error code");
                    
                    [folder listWithCompletion:^(NSArray *items, CFSError *error) {
                        XCTAssert(count == items.count, "Folder count mismatch");
                        
                        [share deleteWithcompletion:^(BOOL success, CFSError *error) {
                            [testreceiveShare fulfill];
                        }];
                    }];
                }];
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:SHARE_TIME_DELAY handler:nil];
}

#pragma mark - List share items tests

/*!
 *  Tests share item
 */
- (void)testShareItem
{
    XCTestExpectation *testShareItem = [self expectationWithDescription:@"testShareItem"];
    CFSFilesystem *fileSystem = ((CFSSession *)[CFSBaseTests getSession]).fileSystem;
    
    [self uploadContents:@"Hello World"
                fileName:fileName
                toFolder:[self getTestFolder]
              whenExists:CFSExistsOverwrite completion:^(CFSFile *file, CFSError *error, int uploadedFileSize) {
        XCTAssertNil(error, "Error should be nil");
        XCTAssert(file.path.length > 0, "File path should not be zero");
        
        [fileSystem createShare:@[file.path] password:@"123456" completion:^(CFSShare *share, CFSError *error) {
            XCTAssertNil(error, "Error should be nil");
            
            [share listWithCompletion:^(NSArray *items, CFSError *error) {
                XCTAssert(error == nil, "Error should be nil");
                XCTAssert([((CFSItem *)items[0]).itemId isEqualToString:file.itemId], "Item ids should be the same");
                [testShareItem fulfill];
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:SHARE_TIME_DELAY handler:nil];
}
@end
