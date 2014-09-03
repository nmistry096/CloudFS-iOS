//
//  Session.m
//  BitcasaSDK
//
//  Created by Olga on 8/21/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import "Session.h"
#import "BitcasaAPI.h"
#import "Configurations.h"
#import "User.h"
#import "Account.h"

@interface Session ()
{
    Configurations* configs;
}
@end

@implementation Session
@synthesize user;
@synthesize account;
@synthesize serverURL;

- (id)initWithServerURL:(NSString*)url clientId:(NSString*)clientId clientSecret:(NSString*)secret username:(NSString*)username andPassword:(NSString*)password
{
    self = [super init];
    if (self)
    {
        [[Configurations sharedInstance] setServerURL:url];
        NSString* token = [BitcasaAPI accessTokenWithEmail:username password:password appId:clientId secret:secret];
        [[Configurations sharedInstance] setAccessToken:token];
        
        [BitcasaAPI getProfileWithCompletion:^(NSDictionary* response)
        {
            self.user = [[User alloc] initWithDictionary:response];
            self.account = [[Account alloc] initWithDictionary:response];
        }];
    }
    return self;
}

@end
