//
//  CFSAssetStream.m
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

#import <AssetsLibrary/AssetsLibrary.h>

#import "CFSAssetStream.h"

@interface CFSAssetStream ()
{
    NSUInteger bufferOffset;
}

@property (strong) ALAssetsLibrary *assetLibrary;
@property (strong) ALAssetRepresentation *assetRep;

@end

@implementation CFSAssetStream

@synthesize streamStatus;

- (instancetype)initWithAssetRep:(ALAssetRepresentation *)representation fromAssetLibrary:(ALAssetsLibrary *)library
{
    self = [super init];
    if (self)
    {
        self.streamStatus = NSStreamStatusNotOpen;
        bufferOffset = 0;
        self.assetRep = representation;
        self.assetLibrary = library;
    }
    return self;
}

- (NSString *)filename
{
    return [self.assetRep filename];
}

- (long long)contentLength
{
    return [self.assetRep size];
}

- (void)open
{
    bufferOffset = 0;
    self.streamStatus = NSStreamStatusOpening;
    self.streamStatus = NSStreamStatusOpen;
}

- (void)close
{
    self.streamStatus = NSStreamStatusClosed;
}

- (BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)len
{
    return NO;
}

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
    self.streamStatus = NSStreamStatusReading;
    
    NSUInteger length = 0;
    
    NSError *error;
    length = [self.assetRep getBytes:buffer fromOffset:bufferOffset length:len error:&error];
    if (error)
    {
        NSLog(@"Read error: %@", [error localizedDescription]);
        self.streamStatus = NSStreamStatusError;
        return -1;
    }
    
    if (bufferOffset >= self.assetRep.size)
    {
        self.streamStatus = NSStreamStatusAtEnd;
        return 0;
    }

    bufferOffset += length;
    
    return length;
}

- (BOOL)hasBytesAvailable
{
    if (bufferOffset >= [self.assetRep size])
    {
        return NO;
    }
    return YES;
}

- (id)copyWithZone:(NSZone *)zone
{
    CFSAssetStream *assetStream = [[CFSAssetStream allocWithZone:zone] initWithAssetRep:self.assetRep fromAssetLibrary:self.assetLibrary];
    return assetStream;
}

#pragma mark - Undocumented CFReadStream Bridged Methods

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
}

- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
}

- (void)_scheduleInCFRunLoop:(__unused CFRunLoopRef)aRunLoop
                     forMode:(__unused CFStringRef)aMode
{
}

- (void)_unscheduleFromCFRunLoop:(__unused CFRunLoopRef)aRunLoop
                         forMode:(__unused CFStringRef)aMode
{
}

- (BOOL)_setCFClientFlags:(__unused CFOptionFlags)inFlags
                 callback:(__unused CFReadStreamClientCallBack)inCallback
                  context:(__unused CFStreamClientContext *)inContext {
    return NO;
}

@end
