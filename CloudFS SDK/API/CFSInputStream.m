//
//  CFSInputStream.m
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

#import "CFSInputStream.h"
#import <MobileCoreServices/MobileCoreServices.h>

NSString const *CFSMultipartFormDataBoundary = @"AaB03x";

@implementation CFSInputStream
@synthesize streamStatus;

+ (CFSInputStream *)inputStreamWithFilename:(NSString *)filename inputStream:(NSInputStream *)inputStream whenExists:(NSString *)operation
{
    CFSInputStream *stream = [[CFSInputStream alloc] init];
    stream.filename = filename;
    stream.inputStream = inputStream;
    stream.exists = operation;
    return stream;
}

- (NSString *)bodyInitialBoundary
{
    return [NSMutableString stringWithFormat:@"\r\n--%@\r\n", CFSMultipartFormDataBoundary];
}

- (NSString *)bodyFormData
{
    NSString *exists;
    if (!self.exists) {
        exists = @"rename";
    } else {
        exists = self.exists;
    }
    
    NSMutableString* formString = [NSMutableString string];
    [formString appendFormat:@"Content-Disposition: form-data; name=\"exists\"\r\n"];
    [formString appendFormat:@"Content-type: text/plain; charset=UTF-8\r\n\r\n%@\r\n", exists];
    [formString appendFormat:@"--%@\r\n", CFSMultipartFormDataBoundary];
    [formString appendFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", self.filename];
    [formString appendFormat:@"Content-Transfer-Encoding: binary\r\n\r\n"];
    return formString;
}

- (NSString*)fileMIMEType:(NSString*)file
{
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[file pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    return (__bridge NSString*)MIMEType;
}

- (NSString *)bodyEndBoundary
{
    return [NSString stringWithFormat:@"\r\n--%@--\r\n", CFSMultipartFormDataBoundary];
}

- (void)open
{
    savedData = [NSMutableData data];
    
    self.streamStatus = NSStreamStatusOpening;
    
    [self.inputStream open];
    
    self.streamStatus = NSStreamStatusOpen;
}

- (void)close
{
    [self.inputStream close];
    
    self.streamStatus = NSStreamStatusClosed;
}

- (BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)len
{
    return NO;
}

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
    self.streamStatus = NSStreamStatusReading;
    NSMutableData *totalData = [NSMutableData dataWithCapacity:len];
    NSUInteger remainingLength = len;
    
    if (_inputStreamState == CFSInputStreamStateStart) {
        NSData *data = [[self bodyInitialBoundary] dataUsingEncoding:NSUTF8StringEncoding];
        NSUInteger dataLength = MIN(([data length] - offset), remainingLength);
        data = [data subdataWithRange:NSMakeRange(offset, dataLength)];
        
        [totalData appendData:data];
        offset += [data length];
        remainingLength -= [data length];
        
        if (offset >= [data length]) {
            offset = 0;
            _inputStreamState = CFSInputStreamStateHeader;
        }
    }
    
    if (_inputStreamState == CFSInputStreamStateHeader) {
        NSData *data = [[self bodyFormData] dataUsingEncoding:NSUTF8StringEncoding];
        NSUInteger dataLength = MIN(([data length] - offset), remainingLength);
        data = [data subdataWithRange:NSMakeRange(offset, dataLength)];
        
        [totalData appendData:data];
        offset += [data length];
        remainingLength -= [data length];
        
        if (offset >= [data length]) {
            offset = 0;
            _inputStreamState = CFSInputStreamStateAvailable;
        }
    }
    
    if (_inputStreamState == CFSInputStreamStateAvailable) {
        uint8_t databuf[remainingLength];
        NSUInteger dataLength = [self.inputStream read:databuf maxLength:remainingLength];
        
        NSData *data = [NSData dataWithBytes:databuf length:dataLength];
        remainingLength -= [data length];
        
        [totalData appendData:data];
        
        if (![self.inputStream hasBytesAvailable]) {
            _inputStreamState = CFSInputStreamStateClosing;
        }
    }
    
    if (_inputStreamState == CFSInputStreamStateClosing) {
        NSData *data = [[self bodyEndBoundary] dataUsingEncoding:NSUTF8StringEncoding];
        NSUInteger dataLength = MIN(([data length] - offset), remainingLength);
        data = [data subdataWithRange:NSMakeRange(offset, dataLength)];
        
        [totalData appendData:data];
        offset += [data length];
        
        if (offset >= [data length]) {
            _inputStreamState = CFSInputStreamStateEnd;
            self.streamStatus = NSStreamStatusAtEnd;
        }
    }
    
    [totalData getBytes:buffer length:MIN(len, [totalData length])];
    
    return [totalData length];
}

- (BOOL)hasBytesAvailable
{
    if (_inputStreamState == CFSInputStreamStateEnd) {
        return NO;
    }
    return YES;
}

- (id)copyWithZone:(NSZone *)zone
{
    CFSInputStream *stream = [[CFSInputStream alloc] init];
    stream.inputStream = [self.inputStream copy];
    stream.filename = [self.filename copy];
    
    return stream;
}

- (void)_scheduleInCFRunLoop:(__unused CFRunLoopRef)aRunLoop forMode:(__unused CFStringRef)aMode
{
}

- (void)_unscheduleFromCFRunLoop:(__unused CFRunLoopRef)aRunLoop forMode:(__unused CFStringRef)aMode
{
}

- (BOOL)_setCFClientFlags:(__unused CFOptionFlags)inFlags callback:(__unused CFReadStreamClientCallBack)inCallback context:(__unused CFStreamClientContext *)inContext
{
    return NO;
}

@end
