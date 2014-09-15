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

- (id)initRootContainer
{
    self = [super init];
    if (self)
    {
        [self setUrl:@"/"];
    }
    return self;
}

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
    [BitcasaAPI getContentsOfContainer:self completion:completion];
}

- (NSString*)endpointPath
{
    return [NSString stringWithFormat:@"%@%@", kAPIEndpointFolderAction, self.url];
}
@end
