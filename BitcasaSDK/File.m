//
//  File.m
//  BitcasaSDK
//
//  Created by Olga on 8/21/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import "File.h"

NSString* const kAPIEndpointFileAction = @"/files";

@implementation File

@dynamic mime;
@dynamic extension;
@dynamic size;

- (NSString*)endpointPath
{
    return [NSString stringWithFormat:@"%@%@", kAPIEndpointFileAction, self.url];
}

@end
