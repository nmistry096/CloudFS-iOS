//
//  CFSPlistReader.m
//  CloudFS SDK
//
//  CloudFS iOS SDK
//  Copyright (C) 2015 Bitcasa, Inc.
//  1200 Park Place, Suite 350
//  San Mateo, CA 94403
//
//  All rights reserved.
//
//  For support, please send email to sdks@bitcasa.com.
//

#import "CFSPlistReader.h"

@implementation CFSPlistReader
{
    NSString *_fileName;
}

- (instancetype)initWithFileName:(NSString *)fileName
{
    if (self = [super init]) {
        _fileName = fileName;
    }
    
    return self;
}

- (id)appConfigValueForKey:(NSString *)key
{
    if (key.length > 0) {
        return [NSDictionary dictionaryWithContentsOfFile:[[NSBundle bundleForClass:[self class]]
                                                           pathForResource:_fileName
                                                           ofType:@"plist"]][key];
    }
    
    return nil;
}

@end
