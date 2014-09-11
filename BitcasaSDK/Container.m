//
//  Container.m
//  BitcasaSDK
//
//  Created by Olga on 8/21/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import "Container.h"
#import "BitcasaAPI.h"

NSString* const kAPIEndpointFolderAction = @"/folders";

@implementation Container

@dynamic itemCount;

#pragma mark - create folder
- (void) createFolder:(NSString*)name completion:(void (^)(Container* newDir))completion
{
    [BitcasaAPI createFolderInContainer:self withName:name completion:^(NSDictionary* newContainerDict)
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

- (NSString*)endpointPath
{
    return [NSString stringWithFormat:@"%@%@", kAPIEndpointFolderAction, self.url];
}
@end
