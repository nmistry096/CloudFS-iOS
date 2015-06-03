//
//  CFSPlan.m
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

#import "CFSPlan.h"

@implementation CFSPlan


- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _displayName = dictionary[@"name"];
        _planId = dictionary[@"id"];
        if (dictionary[@"storage"]) {
            _limit = [dictionary[@"storage"] longLongValue];
        } else {
            _limit = [dictionary[@"limit"] longLongValue];
        }
    }
    
    return self;
}

@end
