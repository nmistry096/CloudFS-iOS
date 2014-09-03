//
//  BitcasaAPI.h
//  BitcasaSDK
//
//  Created by Olga on 8/21/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BitcasaAPI : NSObject
+ (NSString *)accessTokenWithEmail:(NSString *)email password:(NSString *)password appId:(NSString*)appId secret:(NSString*)secret;
+ (void)getProfileWithCompletion:(void(^)(NSDictionary* response))completion;
@end
