//
//  NSMutableDictionary+CFSRestAdditions.m
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

#import "NSMutableDictionary+CFSRestAdditions.h"
#import "NSString+CFSRestAdditions.h"

@implementation NSMutableDictionary (CFSRestAdditions)

- (NSString *)sortedParameterString
{
    NSMutableString *parametersString = [NSMutableString string];
    NSArray *sortedKeys = [[self allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    for (NSString *key in sortedKeys) {
        [parametersString appendString:[NSString stringWithFormat:@"%@=%@&", [key encode], [(NSString *)self[key] encode]]];
    }
    
    [parametersString deleteCharactersInRange:NSMakeRange(parametersString.length-1, 1)];
    return parametersString;
}

@end
