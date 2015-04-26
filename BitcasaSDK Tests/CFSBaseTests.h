//
//  CFSBaseTests.h
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
