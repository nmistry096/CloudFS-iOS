//
//  CFSErrorUtil.m
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

#import "CFSErrorUtil.h"
#import "CFSError.h"

@implementation CFSErrorUtil

NSString *const CFSDataErrorCodeKey = @"errorCode";
NSString *const CFSDataErrorMessageKey = @"errorMessage";
NSString *const CFSSDKErrorDomain = @"CFSErrorDomain";
NSString *const CFSUnknownErrorMessage = @"Unknown Error";
const int CFSUnknownErrorCode = 9999;

+ (CFSError *)errorWithError:(NSError *)error
{
    CFSError *cfsError = nil;
    if (error) {
        cfsError = [[CFSError alloc] initWithDomain:error.domain
                                               code:error.code
                                           userInfo:error.userInfo];
        
        if ((error.userInfo)[@"NSLocalizedDescription"])
        {
            cfsError.message = (error.userInfo)[@"NSLocalizedDescription"];
        }
    }
    
    return cfsError;
}

+ (NSString *)errorDomain
{
    return CFSSDKErrorDomain;
}

+ (CFSError *)createErrorFrom:(NSData *)responseData
                     response:(NSURLResponse *)response
                        error:(NSError *)error
{
    NSInteger responseCode = 0;
    
    if (((NSHTTPURLResponse*)response) != nil) {
        responseCode = [((NSHTTPURLResponse*)response) statusCode];
    }
    
    return [CFSErrorUtil createErrorFrom:responseData
                              statusCode:responseCode
                                   error:error];
}

+ (CFSError *)createErrorFrom:(NSData *)responseData
                   statusCode:(NSInteger)code
                        error:(NSError *)error
{
    CFSError *cfsError;
    
    if (code != 200) {
        NSDictionary *errorDictionary;
        
        if (responseData != nil) {
            errorDictionary = [CFSErrorUtil errorDictionaryFromResponseData:responseData];
        }
        
        if (errorDictionary && errorDictionary.count == 2) {
            if (([errorDictionary[CFSDataErrorCodeKey] intValue] == CFSUnknownErrorCode) && error != nil) {
                cfsError = [CFSErrorUtil errorWithError:error];
            }
            else {
                int errorCode = [errorDictionary[CFSDataErrorCodeKey] intValue];
                cfsError = [[CFSError alloc] initWithDomain:[self errorDomain] code:errorCode userInfo:nil];
                cfsError.message = errorDictionary[CFSDataErrorMessageKey];
            }
        }
        else if (error != nil) {
            cfsError = [CFSErrorUtil errorWithError:error];
        }
    }
    else if (error != nil) {
        cfsError = [CFSErrorUtil errorWithError:error];
    }
    
    return cfsError;
}

+ (NSDictionary*)errorDictionaryFromResponseData:(NSData *)data
{
    NSError *err;
    NSMutableDictionary *dictionary;
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                       options:NSJSONReadingAllowFragments
                                                                         error:&err];
    dictionary = [[NSMutableDictionary alloc] init];
    if (responseDictionary != nil && responseDictionary[@"error_code"]) {
        dictionary[CFSDataErrorCodeKey] = responseDictionary[@"error_code"];
        dictionary[CFSDataErrorMessageKey] = responseDictionary[@"message"];
    }
    else if (responseDictionary != nil && responseDictionary[@"error"]) {
        dictionary[CFSDataErrorCodeKey] = responseDictionary[@"error"][@"code"];
        dictionary[CFSDataErrorMessageKey] = responseDictionary[@"error"][@"message"];
    }
    else {
        dictionary[CFSDataErrorCodeKey] = @(CFSUnknownErrorCode);
        dictionary[CFSDataErrorMessageKey] = CFSUnknownErrorMessage;
    }
    return dictionary;
}
@end
