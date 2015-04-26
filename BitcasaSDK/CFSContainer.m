//
//  CFSContainer.m
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

#import "CFSContainer.h"
#import "CFSRestAdapter.h"

@implementation CFSContainer

#pragma mark - list items

- (void)listWithCompletion:(void (^)(NSArray *items, CFSError *error))completion
{
   [_restAdapter listContentsOfContainer:self completion:completion];
}
@end
