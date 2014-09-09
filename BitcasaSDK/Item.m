//
//  Item.m
//  BitcasaSDK
//
//  Created by Olga on 8/21/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import "Item.h"


@implementation Item

@dynamic url;
@dynamic version;
@dynamic name;
@dynamic dateContentLastModified;
@dynamic dateCreated;

- (id)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self)
    {
        self.name = dict[@"name"];
        self.dateContentLastModified = [NSDate dateWithTimeIntervalSince1970:[dict[@"date_content_last_modified"] doubleValue]];
        self.dateCreated = [NSDate dateWithTimeIntervalSince1970:[dict[@"date_created"] doubleValue]];
        self.version = [dict[@"version"] integerValue];
    }
    return self;
}

@end
