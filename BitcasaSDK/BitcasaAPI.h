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
+ (void)getContentsOfDirectory:(NSString*)directoryPath completion:(void (^)(NSArray* response))completion;

- (void)createFolderAtPath:(NSString*)path withName:(NSString*)name completion:(void (^)(NSURLResponse* response, NSData* data))completion;

+ (void)moveItems:(NSArray*)items to:(id)toItem completion:(void (^)(NSURLResponse* response, NSData* data))completion;
+ (void)deleteItems:(NSArray*)items completion:(void (^)(NSURLResponse* response, NSData* data))completion;
@end
