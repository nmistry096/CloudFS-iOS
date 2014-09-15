//
//  Item.m
//  BitcasaSDK
//
//  Created by Olga on 8/21/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import "Item.h"
#import "BitcasaAPI.h"
#import "Container.h"

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

#pragma mark - copy
- (void)copyToDestinationContainer:(Container *)destContainer completion:(void (^)(Item *))completion
{
    [self copyToDestinationPath:destContainer.url completion:completion];
}

- (void)copyToDestinationPath:(NSString *)destPath completion:(void (^)(Item *))completion
{
    [BitcasaAPI copyItem:self to:destPath completion:completion];
}

#pragma mark - move
- (void)moveToDestinationContainer:(Container *)destContainer completion:(void (^)(Item * movedItem))completion
{
    [self moveToDestinationPath:destContainer.url completion:completion];
}

- (void)moveToDestinationPath:(NSString*)destPath completion:(void (^)(Item* movedItem))completion
{
    [BitcasaAPI moveItem:self to:destPath completion:completion];
}

#pragma mark - delete
- (void)deleteWithCompletion:(void (^)(BOOL))completion
{
    [BitcasaAPI deleteItem:self completion:completion];
}

#pragma mark - restore
- (void)restoreToContainer:(Container*)container completion:(void (^)(BOOL))completion
{
    [BitcasaAPI restoreItem:self to:container completion:completion];
}

- (NSString*)endpointPath
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}
@end
