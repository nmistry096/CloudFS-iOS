//
//  CFSBaseTests.h
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
#import <Foundation/Foundation.h>
#import "CFSRestAdapter.h"

@class CFSSession;
@interface CFSBaseTests : XCTestCase

extern NSString *BITCASA_TEST_FOLDER;

+ (CFSSession *)getSession;
+ (CFSRestAdapter *)getRestAdapter;
- (CFSFolder *)getTestFolder;
- (void)createTestFolder;
- (void)deleteTestFolder;

- (void)uploadContents:(NSString *)contents
              fileName:(NSString *)fileName
              toFolder:(CFSFolder *)folder
            whenExists:(CFSExistsOperation)operation
            completion:(void (^)(CFSFile *file, CFSError *error, int uploadedFileSize))completion;

@end
