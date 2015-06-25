//
//  CFSBaseTests.m
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
#import "CFSBaseTests.h"
#import "CFSPlistReader.h"
#import "CFSRestAdapter.h"
#import "CFSFolder.h"
#import "CFSFileSystem.h"
#import "CFSUser.h"
#import "CFSSession.h"

static CFSSession *session;
int WAIT_TIME = 30;
@implementation CFSBaseTests

    CFSFolder *_testFolder;

    NSString *BITCASA_TEST_FOLDER = @"BitCasaTest";
    void (^_completionCallBackHandler)(CFSFile *file, CFSError *error, int uploadedFileSize);

+ (CFSSession *)getSession
{
    return session;
}

+ (CFSRestAdapter *)getRestAdapter
{
    return session.restAdapter;
}

- (CFSFolder *)getTestFolder
{
    return _testFolder;
}

- (void)setUp {
    [super setUp];
    if (!session) {
        [self setUpInitalValues];
    } else {
        [session isLinkedWithCompletion:^(BOOL ping, CFSError *error) {
            if(!ping) {
                [self authenticate];
            }
        }];
    }
}

- (void)tearDown {
    [super tearDown];
}

- (void)setUpInitalValues
{
    CFSPlistReader *plistReader = [[CFSPlistReader alloc] initWithFileName:@"CloudFSConfig"];
    NSString *serverUrl = [plistReader appConfigValueForKey:@"CFS_API_SERVER_URL"];
    NSString *appId = [plistReader appConfigValueForKey:@"CFS_CLIENT_ID"];
    NSString *appSecret = [plistReader appConfigValueForKey:@"CFS_SECRET"];
    session = [[CFSSession alloc] initWithEndPoint:serverUrl clientId:appId clientSecret:appSecret];
    [self authenticate];
}

- (void)authenticate
{
    CFSPlistReader *plistReader = [[CFSPlistReader alloc] initWithFileName:@"CloudFSConfig"];
    
    NSString *email = [plistReader appConfigValueForKey:@"CFS_USER_EMAIL"];
    NSString *password = [plistReader appConfigValueForKey:@"CFS_USER_PASSWORD"];
    
    XCTestExpectation *authenticationExpectation = [self expectationWithDescription:@"authentication"];
    [session  authenticateWithUsername:email andPassword:password completion:^(NSString* token, BOOL success, CFSError *error)
     {
         if (error) {
             XCTAssert(success, "Authentication error shold be nil");
         }
         else if (!success) {
             XCTAssert(success, "Authentication unsuccessful");
         }
            [authenticationExpectation fulfill];
     }];
    
    [self waitForExpectationsWithTimeout:WAIT_TIME handler:^(NSError *error) {}];
}

- (void)uploadContents:(NSString *)contents
              fileName:(NSString *)fileName
              toFolder:(CFSFolder *)folder
            whenExists:(CFSExistsOperation)operation
            completion:(void (^)(CFSFile *file, CFSError *error, int uploadedFileSize))completion
{
    _completionCallBackHandler = completion;
    NSString *folderName = @"temp";
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *localFolder = [documentsURL URLByAppendingPathComponent:folderName isDirectory:YES];
    [[NSFileManager defaultManager] createDirectoryAtURL:localFolder withIntermediateDirectories:YES attributes:nil error:NULL];
    NSURL *tempFileURL = [localFolder URLByAppendingPathComponent:fileName];
    NSError *eerror = nil;
    [contents writeToURL:tempFileURL atomically:NO encoding:NSUTF8StringEncoding error:&eerror];    
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:tempFileURL.path error:nil];
    int fileSize = [attributes[NSFileSize] intValue];
    
    [folder upload:tempFileURL.path
          progress:^(NSInteger uploadId, NSString *path, int64_t completedBytes, int64_t totalBytes) {
              }
        completion:^(NSInteger uploadId, NSString *path, CFSFile *cfsFile, CFSError *error) {
                _completionCallBackHandler(cfsFile, error, fileSize);
                NSFileManager *fileManager = [NSFileManager defaultManager];
                [fileManager removeItemAtPath:tempFileURL.path error:nil];
            }
            whenExists:operation];
}

- (void)createTestFolder
{
    __weak XCTestExpectation *createFolderOverWriteExpectation = [self expectationWithDescription:@"createFolderOverWrite"];
    
    [session.fileSystem rootWithCompletion:^(CFSFolder *root, CFSError *error) {
        
        [root createFolder:BITCASA_TEST_FOLDER whenExists:CFSItemExistsOverwrite completion:^(CFSFolder *newDir, CFSError *error) {
            _testFolder = newDir;
            [createFolderOverWriteExpectation fulfill];
        }];
    }];
    [self waitForExpectationsWithTimeout:WAIT_TIME handler:^(NSError *error) {}];
}

- (void)deleteTestFolder
{
    __weak XCTestExpectation *deleteRootFolder = [self expectationWithDescription:@"deleteRootFolder"];
    CFSFolder *rootTestFolder = [self getTestFolder];
    
    [rootTestFolder deleteWithCommit:YES force:YES completion:^(BOOL success, CFSError *error) {
        [deleteRootFolder fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:WAIT_TIME handler:^(NSError *error) {}];
}

@end
