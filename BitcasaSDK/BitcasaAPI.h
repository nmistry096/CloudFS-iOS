//
//  BitcasaAPI.h
//  BitcasaSDK
//
//  Created by Olga on 8/21/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Item;
@class Container;
@interface BitcasaAPI : NSObject
+ (NSString *)accessTokenWithEmail:(NSString *)email password:(NSString *)password;

#pragma mark - Get profile
+ (void)getProfileWithCompletion:(void(^)(NSDictionary* response))completion;

#pragma mark - List directory contents
+ (void)getContentsOfDirectory:(NSString*)directoryPath completion:(void (^)(NSArray* response))completion;

#pragma mark - Move item(s)
+ (void)moveItem:(Item*)itemToMove to:(id)toItem completion:(void (^)(BOOL success))completion;
+ (void)moveItems:(NSArray*)itemsToMove to:(id)toItem completion:(void (^)(NSArray* success))completion;

#pragma mark - Delete item(s)
+ (void)deleteItem:(Item*)itemToDelete completion:(void (^)(BOOL success))completion;
+ (void)deleteItems:(NSArray*)items completion:(void (^)(NSArray* results))completion;

#pragma mark - Create new directory
+ (void)createFolderAtPath:(NSString*)path withName:(NSString*)name completion:(void (^)(NSURLResponse* response, NSData* data))completion;
@end
