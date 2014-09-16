//
//  Folder.m
//  BitcasaSDK
//
//  Created by Olga on 8/21/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import "Folder.h"
#import "BitcasaAPI.h"

@implementation Folder

- (void)uploadContentsOfFile:(NSString*)path delegate:(id <TransferDelegate>)delegate
{
    [BitcasaAPI uploadFile:path to:self delegate:delegate];
}

@end
