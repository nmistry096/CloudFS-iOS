//
//  Item.h
//  BitcasaSDK
//
//  Created by Olga on 8/21/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Item : NSManagedObject

@property (nonatomic, retain) NSString * url;
@property (nonatomic) int64_t version;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) NSTimeInterval dateContentLastModified;
@property (nonatomic) NSTimeInterval dateCreated;

@end
