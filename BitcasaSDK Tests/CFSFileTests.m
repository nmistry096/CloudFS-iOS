//
//  CFSFileTests.m
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
#import "CFSFolder.h"
#import "CFSFile.h"
#import "CFSPlistReader.h"
#import "CFSBaseTests.h"
#import "CFSFilesystem.h"
#import "CFSSession.h"

@interface CFSFileTests : CFSBaseTests

@end

const int FILE_TIME_DELAY = 20;

CFSFolder *folder;

@implementation CFSFileTests

- (void)setUp {
    [super setUp];
    [self createTestFolder];
}

- (void)tearDown {
    [super tearDown];
    [self deleteTestFolder];
}

/*!
 *  Tests file versions
 */
- (void)testFileVersions {
    XCTestExpectation *fileVersionsExpectation = [self expectationWithDescription:@"fileVersions"];
    
    [self uploadContents:@"Hello World"
                fileName:@"FileName"
                toFolder:[self getTestFolder]
              whenExists:CFSExistsOverwrite
              completion:^(CFSFile *file, CFSError *error, int uploadedFileSize) {
                  
        NSMutableDictionary *meta = [[NSMutableDictionary alloc] init];
        meta[@"name"] = @"NewName";
        meta[@"extension"] = @"mkv";
        meta[@"version"] = [@(file.version) stringValue];
        
        [file changeAttributes:meta ifConflict:VersionExistsIgnore];
        
        [file versionsWithStartVersion:@(file.version-1)
                        endVersion:@(file.version)
                             limit:@(2)
                    withCompletion:^(NSArray *items, CFSError *error) {
            XCTAssert(items.count > 0, @"Items count should not be zero");
            XCTAssert(error == nil, @"Error should be nil");
            [fileVersionsExpectation fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:FILE_TIME_DELAY handler:nil];
}

/*!
 *  Tests file set mime function
 */
- (void)testSetFileMime
{
    XCTestExpectation *changeMimeExpectation = [self expectationWithDescription:@"changeMime"];
    
    [self uploadContents:@"Hello World"
                fileName:@"FileName"
                toFolder:[self getTestFolder]
              whenExists:CFSExistsOverwrite completion:^(CFSFile *file, CFSError *error, int uploadedFileSize) {
        BOOL success = [file setMime:@"MIME"];
        XCTAssertNotNil(file);
        XCTAssertNil(error);
        XCTAssert(success, "Success Should be true");
        XCTAssert([file.mime isEqualToString:@"MIME"], "Should have new MIME value");
        [changeMimeExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:FILE_TIME_DELAY handler:nil];
}

- (void)testDownload
{
    NSString *fileName = @"bitcasa-logo-test";
    NSString *type = @"png";
    
    __block CFSFile *uploadedFile = nil;
    
    XCTestExpectation *uploadFileExpectation = [self expectationWithDescription:@"uploadFileExpectation"];
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:fileName ofType:type];
    unsigned long long localFileSize = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil].fileSize;
    
    __block CFSError *uploadError = nil;
    [[self getTestFolder] upload:path
              progress:^(NSInteger uploadId, NSString *path, int64_t completedBytes, int64_t totalBytes) {
                  // Progress
              }
            completion:^(NSInteger uploadId, NSString *path, CFSFile *cfsFile, CFSError *error) {
                uploadedFile = cfsFile;
                uploadError = error;
                [uploadFileExpectation fulfill];
            }
            whenExists:CFSExistsOverwrite];
    
    [self waitForExpectationsWithTimeout:600 handler:^(NSError *error) {
        NSAssert(uploadError == nil, uploadError.message);
    }];
    
    
    XCTestExpectation *downloadFileExpectation = [self expectationWithDescription:@"downloadFileExpectation"];
    
    __block NSString *downloadedPath;
    [uploadedFile download:NSTemporaryDirectory()
                  progress:^(NSInteger transferId, NSString *path, int64_t completedBytes, int64_t totalBytes) {
                    // Progress
                } completion:^(NSInteger transferId, NSString *path, CFSFile *file, CFSError *error) {
                    downloadedPath = path;
                    [downloadFileExpectation fulfill];
                }];
    
    [self waitForExpectationsWithTimeout:600 handler:^(NSError *error) {}];
    
    unsigned long long downloadedFileSize = [[NSFileManager defaultManager] attributesOfItemAtPath:downloadedPath error:nil].fileSize;
    XCTAssertTrue(downloadedFileSize == localFileSize);
}

- (void)testDownloadUrl
{
    __block NSString *fileDownloadUrl = nil;
    XCTestExpectation *getDownloadUrl = [self expectationWithDescription:@"getDownloadUrl"];
    
    [((CFSSession *)[CFSBaseTests getSession]).fileSystem rootWithCompletion:^(CFSFolder *root, CFSError *error) {
        
        [self uploadContents:@"Hello World"
                    fileName:@"FileName"
                    toFolder:root
                  whenExists:CFSExistsOverwrite
                  completion:^(CFSFile *file, CFSError *error, int uploadedFileSize) {
                      [file downloadUrlWithCompletion:^(NSString *downloadUrl) {
                          fileDownloadUrl = downloadUrl;
                          [getDownloadUrl fulfill];
                      }];
                      
                  }
         ];
        
    }];
    
    [self waitForExpectationsWithTimeout:600 handler:^(NSError *error) {}];
    
    XCTAssertNotNil(fileDownloadUrl);
}

- (void)testRead
{
    __block NSInputStream *fileInputStream;
    XCTestExpectation *getInputStream = [self expectationWithDescription:@"getInputStream"];
    
    [((CFSSession *)[CFSBaseTests getSession]).fileSystem rootWithCompletion:^(CFSFolder *root, CFSError *error) {
        [self uploadContents:@"Hello World"
                    fileName:@"FileName"
                    toFolder:root
                  whenExists:CFSExistsOverwrite
                  completion:^(CFSFile *file, CFSError *error, int uploadedFileSize) {
                      [file readWithCompletion:^(NSInputStream *inputStream) {
                          fileInputStream = inputStream;
                          [getInputStream fulfill];
                      }];
                  }];
    }];
    
    [self waitForExpectationsWithTimeout:600 handler:^(NSError *error) {}];
    XCTAssertNotNil(fileInputStream);
}

@end
