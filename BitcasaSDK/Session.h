//
//  Session.h
//  BitcasaSDK
//
//  Created by Olga on 8/21/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Account;
@class User;
@class Filesystem;

@interface Session : NSObject

@property (nonatomic, strong) User* user;
@property (nonatomic, strong) Account* account;
@property (nonatomic, strong) Filesystem* fs;
@property (nonatomic, strong) NSString* serverURL;

- (id)initWithServerURL:(NSString*)url clientId:(NSString*)clientId clientSecret:(NSString*)secret username:(NSString*)username andPassword:(NSString*)password;

@end
