//
//  Configurations.h
//  BitcasaSDK
//
//  Created by Olga on 8/22/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Configurations : NSObject
+ (Configurations*)sharedInstance;
- (NSString*)accessToken;
- (NSString*)serverURL;

- (void)setServerURL:(NSString*)inServerURL;
- (void)setAccessToken:(NSString*)inAccessToken;
@end
