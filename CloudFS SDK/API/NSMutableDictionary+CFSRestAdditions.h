//
//  NSMutableDictionary+CFSRestAdditions.h
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

@interface NSMutableDictionary (CFSRestAdditions)

- (NSString *)sortedParameterString;

@end
