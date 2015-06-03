//
//  CFSInputStream.h
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

extern NSString const *CFSMultipartFormDataBoundary;

typedef NS_ENUM(NSUInteger, CFSInputStreamState) {
    CFSInputStreamStateStart,
    CFSInputStreamStateHeader,
    CFSInputStreamStateAvailable,
    CFSInputStreamStateClosing,
    CFSInputStreamStateEnd
};

@interface CFSInputStream : NSInputStream
{
    NSUInteger offset;
    NSMutableData *savedData;
}

@property (assign, nonatomic) NSUInteger length;

@property (assign) CFSInputStreamState inputStreamState;

@property (strong) NSString *filename;

@property (strong) NSInputStream *inputStream;
@property (assign) NSStreamStatus streamStatus;
@property (assign) NSString *exists;

+ (CFSInputStream *)inputStreamWithFilename:(NSString *)filename inputStream:(NSInputStream *)inputStream whenExists:(NSString *)operation;
- (NSString *)bodyInitialBoundary;
- (NSString *)bodyFormData;
- (NSString *)bodyEndBoundary;

@end
