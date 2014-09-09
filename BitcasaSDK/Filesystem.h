//
//  Filesystem.h
//  BitcasaSDK
//
//  Created by Olga on 8/21/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Container;
@interface Filesystem : NSObject

#pragma mark - list
- (void)listItemsInContainer:(Container*)container completion:(void (^)(NSArray* items))completion;
- (void)listItemsAtPath:(NSString*)path completion:(void (^)(NSArray* items))completion;

#pragma mark - delete
- (void)deleteItems:(NSArray*)items completion:(void (^)(BOOL success))completion;
- (void)deleteItemsAtPaths:(NSArray*)paths completion:(void (^)(BOOL success))completion;

#pragma mark - move
- (void)moveItems:(NSArray*)items toContainer:(Container*)destination completion:(void (^)(BOOL success))completion;
- (void)moveItemsAtPaths:(NSArray*)paths toPath:(NSString*)destination completion:(void (^)(BOOL success))completion;

@end
