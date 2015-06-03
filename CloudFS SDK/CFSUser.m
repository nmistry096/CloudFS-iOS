//
//  CFSUser.m
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
        _userId = dictionary[@"id"];
        _lastLogin = [dictionary[@"last_login"] longLongValue];
        _createdAt = [dictionary[@"created_at"] longLongValue];
    }
    
    return self;
}

@end
