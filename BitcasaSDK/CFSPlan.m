//
//  CFSPlan.m
//  BitcasaSDK
//
//  Created by Gihan Deshapriya on 5/21/15.
//  Copyright (c) 2015 Bitcasa. All rights reserved.
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
