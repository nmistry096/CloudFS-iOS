//
//  Item.h
//  BitcasaSDK
//
//  Created by Olga on 8/21/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Container;
@interface Item : NSManagedObject

@property (nonatomic, retain) NSString * url;
@property (nonatomic) int64_t version;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) NSDate* dateContentLastModified;
@property (nonatomic) NSDate* dateCreated;

- (id)initWithDictionary:(NSDictionary*)dict;

#pragma mark - copy
- (void)copyToDestinationPath:(NSString*)destPath completion:(void (^)(Item* newItem))completion;
- (void)copyToDestinationContainer:(Container *)destContainer completion:(void (^)(Item* newItem))completion;

#pragma mark - move
- (void)moveToDestinationPath:(NSString*)destPath completion:(void (^)(Item* movedItem))compeltion;
- (void)moveToDestinationContainer:(Container *)destContainer completion:(void (^)(Item * movedItem))compeltion;

#pragma mark - delete
- (void)deleteWithCompletion:(void (^)(BOOL success))completion;

#pragma mark - restore
- (void)restoreToContainer:(Container*)container completion:(void (^)(BOOL))completion;

- (NSString*)endpointPath;

@end
