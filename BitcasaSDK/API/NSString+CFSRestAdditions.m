//
//  NSString+CFSRestAdditions.m
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

#import "NSString+CFSRestAdditions.h"

@implementation NSString (CFSRestAdditions)

- (NSString *)encode
{
    NSMutableCharacterSet *urlSafeCharacters = [NSMutableCharacterSet characterSetWithCharactersInString:@".-*_"];
   [urlSafeCharacters formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
    NSString *encodedStr = [self stringByAddingPercentEncodingWithAllowedCharacters:urlSafeCharacters];
    return [encodedStr stringByReplacingOccurrencesOfString:@"%20" withString:@"+"];
}

- (NSString *)uriEncode
{
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
}

+ (NSString *)parameterStringWithArray:(NSArray *)parameters
{
    NSMutableString *allParams = [NSMutableString string];
    
    [parameters enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         NSDictionary *oneParam = (NSDictionary *)obj;
         NSString *paramValue = [[oneParam allValues] firstObject];
         paramValue = [paramValue encode];
         [allParams appendString:[NSString stringWithFormat:@"%@=%@&", [[oneParam allKeys] firstObject], paramValue]];
     }];
    
    [allParams deleteCharactersInRange:NSMakeRange(allParams.length-1, 1)];
    return allParams;
}

+ (NSString *)sortedParameterStringWithDictionary:(NSDictionary *)parameters
{
    NSMutableString *allParams = [NSMutableString string];
    NSArray *sortedKeys = [[parameters allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    [sortedKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([parameters[obj] isKindOfClass:[NSString class]]) {
            NSString *paramValue = parameters[obj];
            paramValue = [paramValue encode];
            [allParams appendString:[NSString stringWithFormat:@"%@=%@&", obj, paramValue]];
        }
    }];
    [allParams deleteCharactersInRange:NSMakeRange(allParams.length-1, 1)];
    return allParams;
}

@end
