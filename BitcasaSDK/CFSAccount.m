//
//  CFSAccount.m
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

#import "CFSAccount.h"

@implementation CFSAccount

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _accountId = dictionary[@"account_id"];
        _storageUsage = [dictionary[@"storage"][@"usage"] longLongValue];
        _storageLimit = [dictionary[@"storage"][@"limit"] longLongValue];
        _overStorageLimit = [dictionary[@"storage"][@"otl"] boolValue];
        _stateDisplayName = dictionary[@"account_state"][@"display_name"];
        _stateId = dictionary[@"account_state"][@"id"];
        _planDisplayName = dictionary[@"account_plan"][@"display_name"];
        _planId = dictionary[@"account_plan"][@"id"];
        _sessionLocale = dictionary[@"session"][@"locale"];
        _accountLocale = dictionary[@"locale"];
    }
    
    return self;
}
@end
