//
//  CFSPlan.h
//  BitcasaSDK
//
//  Created by Gihan Deshapriya on 5/21/15.
//  Copyright (c) 2015 Bitcasa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CFSPlan : NSObject

/*!
 *  Display name of the plan.
 */
@property (nonatomic, strong) NSString *displayName;

/*!
 *  Id of the plan.
 */
@property (nonatomic, strong) NSString *planId;

/*!
 *  Limit of the plan
 */
@property (nonatomic) int64_t limit;

#pragma mark - Initilization

- (instancetype)init NS_UNAVAILABLE;

/*!
 *  Intializes and returns a CFSPlan instance
 *
 *  @param dictionary The dictionary containing the plan details
 *
 *  @return Returns a instance of a CFSPlan
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

@end
