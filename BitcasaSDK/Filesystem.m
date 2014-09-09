//
//  Filesystem.m
//  BitcasaSDK
//
//  Created by Olga on 8/21/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import "Filesystem.h"
#import "Container.h"
#import "Item.h"
#import "BitcasaAPI.h"

@implementation Filesystem

#pragma mark - list
- (void)listItemsInContainer:(Container*)container completion:(void (^)(NSArray* items))completion
{
    [self listItemsAtPath:container.url completion:completion];
}

- (void)listItemsAtPath:(NSString*)path completion:(void (^)(NSArray* items))completion
{
    [BitcasaAPI getContentsOfDirectory:path completion:^(NSArray* response)
     {
         NSMutableArray* itemArray = [NSMutableArray array];
         for (NSDictionary* itemDict in response)
         {
             Item* item = [[Item alloc] initWithDictionary:itemDict];
             [itemArray addObject:item];
         }
         completion(itemArray);
     }];
}

#pragma mark - delete
- (void)deleteItems:(NSArray*)items completion:(void (^)(BOOL success))completion
{
    [BitcasaAPI deleteItems:items completion:^(NSURLResponse *response, NSData *data)
    {
        completion(YES);
    }];
}

- (void)deleteItemsAtPaths:(NSArray*)paths completion:(void (^)(BOOL success))completion
{
    [self deleteItems:paths completion:completion];
}

#pragma mark - move
- (void)moveItems:(NSArray*)items toContainer:(id)destination completion:(void (^)(BOOL success))completion
{
    [self moveItemsAtPaths:items toPath:destination completion:completion];
}

- (void)moveItemsAtPaths:(NSArray*)paths toPath:(NSString*)destination completion:(void (^)(BOOL success))completion
{
    [BitcasaAPI moveItems:paths to:destination completion:^(NSURLResponse *response, NSData *data)
    {
        completion(YES);
    }];
}



@end
