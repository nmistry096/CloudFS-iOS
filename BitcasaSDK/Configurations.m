//
//  Configurations.m
//  BitcasaSDK
//
//  Created by Olga on 8/22/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import "Configurations.h"

@interface Configurations ()
{
    NSString* accessToken;
    NSString* serverURL;
}
@end

static NSString* const kServerURLKey = @"server url key";
static NSString* const kAccessTokenKey = @"access token key";

@implementation Configurations
static Configurations *sharedInstance;

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sharedInstance = [[Configurations alloc] initWithUserDefaults];
    });
}

+ (Configurations*)sharedInstance
{
    return sharedInstance;
}

- (id)initWithUserDefaults
{
    self = [super init];
    if (self)
    {
        serverURL = [[NSUserDefaults standardUserDefaults] objectForKey:kServerURLKey];
        accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenKey];
    }
    return self;
}

- (NSString*)serverURL
{
    return serverURL;
}

- (NSString*)accessToken
{
    return accessToken;
}

- (void)setServerURL:(NSString*)inServerURL
{
    [[NSUserDefaults standardUserDefaults] setObject:inServerURL forKey:kServerURLKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAccessToken:(NSString*)inAccessToken
{
    [[NSUserDefaults standardUserDefaults] setObject:inAccessToken forKey:kAccessTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
