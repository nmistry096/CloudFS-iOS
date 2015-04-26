//
//  NSString+CFSRestAdditions.h
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

@interface NSString (CFSRestAdditions)

- (NSString *)encode;
- (NSString *)uriEncode;

/*!
 *  Create a string with array parameters.
 *
 *  @param parameters Array with parameters.
 *
 *  @return string with parameters.
 */
+ (NSString *)parameterStringWithArray:(NSArray *)parameters;

/*!
 *  Sort a given dictionary and create string with keys and values.
 *
 *  @param parameters dictionary containing parameters.
 *
 *  @return string with parameters.
 */
+ (NSString *)sortedParameterStringWithDictionary:(NSDictionary *)parameters;

@end
