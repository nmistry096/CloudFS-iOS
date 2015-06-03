//
//  NSMutableDictionary+CFSRestAdditions.m
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
