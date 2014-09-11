//
//  Container.m
//  BitcasaSDK
//
//  Created by Olga on 8/21/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import "Container.h"
#import "BitcasaAPI.h"

@implementation Container

@dynamic itemCount;

#pragma mark - create folder
- (void) createFolder:(NSString*)name completion:(void (^)(Container* newDir))completion
{
    [BitcasaAPI createFolderAtPath:self.url withName:name completion:^(NSDictionary* newContainerDict)
    {
        Container* newDir = [[Container alloc] initWithDictionary:newContainerDict];
        completion(newDir);
    }];
}

#pragma mark - list items
- (void) listItemsWithCompletion:(void (^)(NSArray* items))completion
{
    [BitcasaAPI getContentsOfContainer:self completion:^(NSArray *response)
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
@end
