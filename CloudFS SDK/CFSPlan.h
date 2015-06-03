//
//  CFSPlan.h
//  CloudFS SDK
//
//  CloudFS iOS SDK
//  Copyright (C) 2015 Bitcasa, Inc.
//  1200 Park Place, Suite 350
//  San Mateo, CA 94403
//
//  All rights reserved.
//
//  For support, please send email to sdks@bitcasa.com.
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
