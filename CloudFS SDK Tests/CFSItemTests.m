//
//  CFSItemTests.m
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
#import "CFSItem.h"
#import "CFSFolder.h"
#import "CFSFile.h"
#import "CFSFilesystem.h"
#import "CFSBaseTests.h"
#import "CFSRestAdapter.h"
#import "CFSSession.h"

@interface CFSItemTests : CFSBaseTests

@end

@implementation CFSItemTests
__weak XCTestExpectation *_uploadItemsExpectation;
__weak XCTestExpectation *_setNameExpectation;
__weak XCTestExpectation *_applicationDataExpectation;
__weak XCTestExpectation *_changeAttributeExpectation;
__weak XCTestExpectation *_copyToDestinationExpectation;
__weak XCTestExpectation *_moveToDestinationExpectation;
__weak XCTestExpectation *_deleteItemExpectation;
__weak XCTestExpectation *_restoreItemExpectation;
__weak XCTestExpectation *_deleteTrashItemExpectation;

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
    [self deleteTestFolder];
}

/*!
 *  Get thge rest adapter from super clas.
 *
 *  @return return rest adapter.
 */
- (CFSRestAdapter *)retrieveRestAdaptor {

    return [CFSBaseTests getRestAdapter];
}

/*!
 *  Set up the pre requiest for test methods.
 *
 *  @param completion The completion handler to call afer completion of method.
 */
-(void)setUpPrerequisitesFolderWithCompletion:(void (^)(CFSFile *file, CFSFolder *folder, CFSError *error, int uploadedFileSize))completion
{
    CFSFolder *cfsFolder = [self getTestFolder];
    [cfsFolder createFolder:@"TestFolder" whenExists:CFSItemExistsRename completion:^(CFSFolder *newDir, CFSError *error) {
        [self uploadContents:@"Hello !"
                    fileName:@"file.txt"
                    toFolder:newDir
                  whenExists:CFSExistsOverwrite
                  completion:^(CFSFile *file, CFSError *error, int uploadedFileSize) {
            if (error != nil) {
                XCTFail(@"File Upload Fail: %@", error);
            }
                      
            completion(file,newDir,error,uploadedFileSize);
        }];
    }];

}

/*!
 *  Set up the pre requiest for test methods.
 *
 *  @param completion The completion handler to call afer completion of method.
 */
-(void)setUpPrerequisitesWithCompletion:(void (^)(CFSFile *file, CFSError *error, int uploadedFileSize))completion
{
    CFSFolder *cfsFolder = [self getTestFolder];
    [cfsFolder createFolder:@"TestFolder" whenExists:CFSItemExistsRename completion:^(CFSFolder *newDir, CFSError *error) {
        [self uploadContents:@"Hello !"
                    fileName:@"file.txt"
                    toFolder:newDir
                  whenExists:CFSExistsOverwrite completion:^(CFSFile *file, CFSError *error, int uploadedFileSize) {
            if (error != nil) {
                XCTFail(@"File Upload Fail: %@", error);
            }
                      
            completion(file,error,uploadedFileSize);
        }];
    }];
    
}

/*!
 *  Get the Trash item list.
 *
 *  @param completion The completion handler to call afer completion of method.
 */
-(void)getTrashItemListWithCompletion:(void (^)(NSArray* items))completion
{
    __weak XCTestExpectation *listTrashExpectation = [self expectationWithDescription:@"listTrash"];
    [((CFSSession *)[CFSBaseTests getSession]).fileSystem listTrashWithCompletion:^(NSArray *items, CFSError *error) {
        [completion items];
        [listTrashExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:120 handler:^(NSError *error) {}];
}

/*!
 *  Test set name for the item.
 */
- (void)testSetName {
    
    [self createTestFolder];
    _setNameExpectation = [self expectationWithDescription:@"setName"];
    __weak CFSItemTests *weakSelf = self;
    [self setUpPrerequisitesWithCompletion:^(CFSFile *file, CFSError *error, int uploadedFileSize) {
        [weakSelf setNameTestFile:file];
    }];
    [self waitForExpectationsWithTimeout:120 handler:nil];
}

/*!
 *  Test set application data.
 */
- (void)testSetApplicationData{
    
    [self createTestFolder];
    _applicationDataExpectation = [self expectationWithDescription:@"setApplicationData"];
    __weak CFSItemTests *weakSelf = self;
    [self setUpPrerequisitesWithCompletion:^(CFSFile *file, CFSError *error, int uploadedFileSize) {
        [weakSelf setApplicationDataTestFile:file];
    }];
    [self waitForExpectationsWithTimeout:120 handler:nil];
}

/*!
 *  Test change attributes of the item.
 */
- (void)testChangeAttributes{
    
    [self createTestFolder];
    _changeAttributeExpectation = [self expectationWithDescription:@"ChangeAttributes"];
    __weak CFSItemTests *weakSelf = self;
    [self setUpPrerequisitesWithCompletion:^(CFSFile *file, CFSError *error, int uploadedFileSize) {
        [weakSelf changeAttributesTestFile:file];
    }];
    [self waitForExpectationsWithTimeout:120 handler:nil];
}

/*!
 *  Test copy item.
 */
- (void)testCopyItemToDestination{
    
    [self createTestFolder];
    _copyToDestinationExpectation = [self expectationWithDescription:@"copy"];
    __weak CFSItemTests *weakSelf = self;
    [self setUpPrerequisitesWithCompletion:^(CFSFile *file, CFSError *error, int uploadedFileSize) {
        [weakSelf copyItemToDestinationTestFile:file];
    }];
    [self waitForExpectationsWithTimeout:120 handler:nil];
}

/*!
 *  Test move item.
 */
- (void)testMoveItemToDestination{
    
    [self createTestFolder];
    _moveToDestinationExpectation = [self expectationWithDescription:@"move"];
    __weak CFSItemTests *weakSelf = self;
    [self setUpPrerequisitesWithCompletion:^(CFSFile *file, CFSError *error, int uploadedFileSize) {
        [weakSelf moveItemToDestinationTestFile:file];
    }];
    [self waitForExpectationsWithTimeout:120 handler:nil];
}

/*!
 *  Test delete item
 */
- (void)testDeleteItem{
    
    [self createTestFolder];
    _deleteItemExpectation = [self expectationWithDescription:@"delete"];
    __weak CFSItemTests *weakSelf = self;
    [self setUpPrerequisitesWithCompletion:^(CFSFile *file, CFSError *error, int uploadedFileSize) {
        [weakSelf deleteItemTestFile:file];
    }];
    [self waitForExpectationsWithTimeout:120 handler:nil];
}

/*!
 *  Test Restore item
 */
- (void)testRestoreItem{
    
    [self createTestFolder];
    _restoreItemExpectation = [self expectationWithDescription:@"restore"];
    __weak CFSItemTests *weakSelf = self;
    [self setUpPrerequisitesWithCompletion:^(CFSFile *file, CFSError *error, int uploadedFileSize) {
        [weakSelf restoreItemTestFileWithPath:file];
    }];
    [self waitForExpectationsWithTimeout:120 handler:nil];
}

- (void)testRestoreMaintainValidityItem{
    
    [self createTestFolder];
    _restoreItemExpectation = [self expectationWithDescription:@"restore"];
    __weak CFSItemTests *weakSelf = self;
    [self setUpPrerequisitesWithCompletion:^(CFSFile *file, CFSError *error, int uploadedFileSize) {
        [weakSelf restoreItemTestWithValidationFail:file];
    }];
    [self waitForExpectationsWithTimeout:120 handler:nil];
}

- (void)testRestoreMaintainValidityItemReuse{
    
    [self createTestFolder];
    _restoreItemExpectation = [self expectationWithDescription:@"restore"];
    __weak CFSItemTests *weakSelf = self;
    [self setUpPrerequisitesWithCompletion:^(CFSFile *file, CFSError *error, int uploadedFileSize) {
        [weakSelf restoreItemTestWithValidationReuse:file];
    }];
    [self waitForExpectationsWithTimeout:120 handler:nil];
}

- (void)testRestoreMaintainValidityItemRecreate{
    
    [self createTestFolder];
    _restoreItemExpectation = [self expectationWithDescription:@"restore"];
    __weak CFSItemTests *weakSelf = self;
    [self setUpPrerequisitesWithCompletion:^(CFSFile *file, CFSError *error, int uploadedFileSize) {
        [weakSelf restoreItemTestWithValidationRecreate:file];
    }];
    [self waitForExpectationsWithTimeout:120 handler:nil];
}

- (void)testDeleteTrashItem{
    
    [self createTestFolder];
    _deleteTrashItemExpectation = [self expectationWithDescription:@"deletetrash"];
    __weak CFSItemTests *weakSelf = self;
    [self setUpPrerequisitesWithCompletion:^(CFSFile *file, CFSError *error, int uploadedFileSize) {
        [weakSelf deleteTrashItemTestFile:file];
    }];
    [self waitForExpectationsWithTimeout:120 handler:nil];
}

- (void)setApplicationDataTestFile:(CFSFile *)file  {
    NSMutableDictionary *dictionary  = [NSMutableDictionary dictionaryWithDictionary:file.applicationData];
    dictionary[@"Test"] = @"TestValue";
    XCTAssertTrue([file setApplicationData:dictionary], @"Response should be successful");
    [_applicationDataExpectation fulfill];
}

- (void)setApplicationDataTestFolder:(CFSFolder *)folder  {
    NSMutableDictionary *dictionary  = [NSMutableDictionary dictionaryWithDictionary:folder.applicationData];
    dictionary[@"Test"] = @"TestValue";
    XCTAssertTrue([folder setApplicationData:dictionary], @"Response should be successful");
    [_applicationDataExpectation fulfill];
}

- (void)setNameTestFile:(CFSFile *)file {
    XCTAssertTrue([file setName:@"hello_teddy"], @"Response should be TRUE");
    [_setNameExpectation fulfill];
}

- (void)setNameTestFolder:(CFSFolder *)folder {
    XCTAssertTrue([folder setName:@"hello_teddy"], @"Response should be TRUE");
    [_setNameExpectation fulfill];
}

- (void)copyItemToDestinationTestFile:(CFSFile *)file {
    CFSContainer *cfsContainer = [self getTestFolder];
    [file copyToDestinationContainer:cfsContainer whenExists:CFSExitsRename name:@"newName" completion:^(CFSItem *newItem, CFSError *error) {
        XCTAssertNotNil(newItem, @"Item should not be nil");
        [_copyToDestinationExpectation fulfill];
    }];
}

- (void)moveItemToDestinationTestFile:(CFSFile *)file {
    CFSContainer *cfsContainer = [self getTestFolder];
    [file moveToDestinationContainer:cfsContainer whenExists:CFSExitsRename completion:^(CFSItem *movedItem, CFSError *error) {
        NSString *expectedFilePath = [cfsContainer.path stringByAppendingPathComponent:file.itemId];
        XCTAssert([movedItem.path isEqualToString:expectedFilePath], "Should have the expected path");
        [_moveToDestinationExpectation fulfill];
    }];
}

- (void)changeAttributesTestFile:(CFSFile *)file {
    NSMutableDictionary *meta = [[NSMutableDictionary alloc] init];
    meta[@"name"] = @"duck";
    meta[@"extension"] = @"mkv";
    meta[@"version"] = [@(file.version) stringValue];
    meta[@"testAvoid"] = [NSDictionary dictionary];
    XCTAssertTrue([file changeAttributes:meta ifConflict:VersionExistsIgnore], @"Response should be TRUE");
    [_changeAttributeExpectation fulfill];
}

- (void)deleteItemTestFile:(CFSFile *)file {
    [file deleteWithCommit:YES force:NO completion:^(BOOL success, CFSError *error) {
        XCTAssertTrue(success, @"Response should be TRUE");
        [_deleteItemExpectation fulfill];
    }];
}

- (void)restoreItemTestFile:(CFSFile *)file {
    CFSContainer *cfsContainer = [self getTestFolder];
    [file deleteWithCommit:YES force:NO completion:^(BOOL success, CFSError *error) {
        [((CFSSession *)[CFSBaseTests getSession]).fileSystem listTrashWithCompletion:^(NSArray *items, CFSError *error) {
            CFSItem *item = (CFSItem *)items[items.count-1];
            [item restoreToContainer:cfsContainer
                       restoreMethod:RestoreOptionsFail
                     restoreArgument:item.path
                    maintainValidity:NO
                          completion:^(BOOL success, CFSError *error) {
                              XCTAssertTrue(success, @"Response should be TRUE");
                              [_restoreItemExpectation fulfill];
                          }];
        }];
    }];
}

- (void)deleteTrashItemTestFile:(CFSFile *)file {
    [file deleteWithCommit:NO force:NO completion:^(BOOL success, CFSError *error) {
        [((CFSSession *)[CFSBaseTests getSession]).fileSystem listTrashWithCompletion:^(NSArray *items, CFSError *error) {
            CFSItem *item = (CFSItem *)items[items.count-1];
            [item deleteWithCommit:nil force:nil completion:^(BOOL success, CFSError *error) {
                XCTAssertTrue(success, @"Response should be TRUE");
                [_deleteTrashItemExpectation fulfill];
            }];
        }];
   }];
}

- (void)restoreItemTestFileWithPath:(CFSFile *)file {
    CFSContainer *cfsContainer = [self getTestFolder];
    [file deleteWithCommit:NO force:NO completion:^(BOOL success, CFSError *error) {
        [((CFSSession *)[CFSBaseTests getSession]).fileSystem listTrashWithCompletion:^(NSArray *items, CFSError *error) {
            CFSItem *item = (CFSItem *)items[items.count-1];
            [item restoreToContainer:cfsContainer
                       restoreMethod:RestoreOptionsRescue
                     restoreArgument:item.path
                    maintainValidity:NO
                          completion:^(BOOL success, CFSError *error) {
                              XCTAssertTrue(success, @"Response should be TRUE");
                              [_restoreItemExpectation fulfill];
           }];
        }];
    }];
}

- (void)restoreItemTestWithValidationFail:(CFSFile *)file {
    CFSContainer *cfsContainer = [self getTestFolder];
    [file deleteWithCommit:NO force:NO completion:^(BOOL success, CFSError *error) {
        [file restoreToContainer:cfsContainer
                   restoreMethod:RestoreOptionsRescue
                 restoreArgument:file.path
                maintainValidity:YES
                      completion:^(BOOL success, CFSError *error) {
                          XCTAssertTrue(success, @"Response should be TRUE");
                          [_restoreItemExpectation fulfill];
        }];
    }];
}


- (void)restoreItemTestWithValidationReuse:(CFSFile *)file {
    CFSContainer *cfsContainer = [self getTestFolder];
    [file deleteWithCommit:NO force:NO completion:^(BOOL success, CFSError *error) {
        [file restoreToContainer:cfsContainer
                   restoreMethod:RestoreOptionsRescue
                 restoreArgument:file.path
                maintainValidity:YES
                      completion:^(BOOL success, CFSError *error) {
                          XCTAssertTrue(success, @"Response should be TRUE");
                          [_restoreItemExpectation fulfill];
                      }];
    }];
}

- (void)restoreItemTestWithValidationRecreate:(CFSFile *)file {
    CFSContainer *cfsContainer = [self getTestFolder];
    [file deleteWithCommit:NO force:NO completion:^(BOOL success, CFSError *error) {
        [file restoreToContainer:cfsContainer
                   restoreMethod:RestoreOptionsRecreate
                 restoreArgument:@"ppo/ooo"
                maintainValidity:YES
                      completion:^(BOOL success, CFSError *error) {
                          XCTAssertTrue(success, @"Response should be TRUE");
                          [_restoreItemExpectation fulfill];
                      }];
    }];
}

- (void)testInitializer
{
    NSMutableDictionary *dictionary =  [NSMutableDictionary dictionary];
    NSDictionary *applicationData = [NSDictionary dictionaryWithObject:@"TEST" forKey:@"TESTVALUE"];
    dictionary[@"name"] = @"testName";
    dictionary[@"id"] = @"jNQLSiK8RAqD_bum2Od4XQ";
    dictionary[@"type"] = @"file";
    dictionary[@"parent_id"] = @"";
    dictionary[@"application_data"] = applicationData;
    dictionary[@"is_mirrored"] = @"NO";
    dictionary[@"version"] = @"1235";
    
    CFSFile *file = [[CFSFile alloc] initWithDictionary:dictionary andParentPath:@"/" andRestAdapter:[CFSBaseTests getRestAdapter]];
    
    XCTAssert([file.name isEqualToString:@"testName"], "Should be Equal");
    XCTAssert([file.itemId isEqualToString:@"jNQLSiK8RAqD_bum2Od4XQ"], "Should be Equal");
    XCTAssert([file.type isEqualToString:@"file"], "Should be Equal");
    XCTAssert([file.parentId isEqualToString:@""], "Should be Equal");
    XCTAssert([file.applicationData isEqualToDictionary:applicationData], "Should be Equal");
    XCTAssert(file.isMirrored == NO, "Should be Equal");
    XCTAssert(file.version == @"1235".intValue, "Should be Equal");
}

@end
