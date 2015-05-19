//
//  CFSContainer.h
//  BitcasaSDK
//
//  Bitcasa iOS SDK
//  Copyright (C) 2015 Bitcasa, Inc.
//  1200 Park Place, Suite 350
//  San Mateo, CA 94403
//
//  All rights reserved.
//
//  For support, please send email to sdks@bitcasa.com.
//

#import <Foundation/Foundation.h>
#import "CFSItem.h"

@class CFSRestAdapter;
@class CFSError;

/*!
 *  Base class for CFSFolder
 */
@interface CFSContainer : CFSItem

#pragma mark - Initilization

- (instancetype)init NS_UNAVAILABLE;

#pragma mark - list items

/*!
 *  Retrieves the item list at this items path.
 *
 *  @param completion The completion handler to call afer completion of method
 */
- (void)listWithCompletion:(void (^)(NSArray *items, CFSError *error))completion;

@end
