//
//  CFSAccount.m
//  BitcasaSDK
//
//  Bitcasa iOS SDK
//  Copyright (C) 2015 Bitcasa, Inc.
//  1200 Park Place, Suite 350
//  San Mateo, CA 94403
//
//  All rights reserved.
//
//  For support, please send email to sdks@bitcasa.com.
//

#import "CFSAccount.h"
#import "CFSPlan.h"

@interface CFSAccount ()
    @property (nonatomic, strong, readwrite) CFSPlan *plan;
@end

@implementation CFSAccount

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _accountId = dictionary[@"account_id"];
        _storageUsage = [dictionary[@"storage"][@"usage"] longLongValue];
        _overStorageLimit = [dictionary[@"storage"][@"otl"] boolValue];
        _stateDisplayName = dictionary[@"account_state"][@"display_name"];
        _stateId = dictionary[@"account_state"][@"id"];
        _sessionLocale = dictionary[@"session"][@"locale"];
        _accountLocale = dictionary[@"locale"];
        NSMutableDictionary *newDictionary = [NSMutableDictionary dictionary];
        newDictionary[@"name"] = dictionary[@"account_plan"][@"display_name"];
        newDictionary[@"id"] = dictionary[@"account_plan"][@"id"];
        newDictionary[@"storage"] = dictionary[@"storage"][@"limit"];
        self.plan = [[CFSPlan alloc] initWithDictionary:newDictionary];
    }
    
    return self;
}
@end
