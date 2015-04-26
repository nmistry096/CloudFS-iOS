//
//  CFSUser.m
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

#import "CFSUser.h"

@implementation CFSUser

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _email = dictionary[@"email"];
        _firstName = dictionary[@"first_name"];
        _lastName = dictionary[@"last_name"];
        _userName = dictionary[@"username"];
        _userId = dictionary[@"account_state"][@"id"];
        _lastLogin = [dictionary[@"last_login"] longLongValue];
        _createdAt = [dictionary[@"created_at"] longLongValue];
    }
    
    return self;
}

@end
