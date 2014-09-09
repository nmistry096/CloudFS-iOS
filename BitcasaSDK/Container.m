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

- (void) createFolder:(NSString*)name completion:(void (^)(Container* newDir))completion
{
    [BitcasaAPI createFolderAtPath:self.url withName:name completion:^(NSURLResponse *response, NSData *data)
    {
        
    }];
}

@end
