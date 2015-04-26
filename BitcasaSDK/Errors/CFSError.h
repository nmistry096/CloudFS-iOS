//
//  CFSError.h
//  BitcasaSDK
//
//  Bitcasa iOS SDK
//  Copyright (C) 2015 Bitcasa, Inc.
//  215 Castro Street, 2nd Floor
//  Mountain View, CA 94041
//
//  All rights reserved.
//
//  For support, please send email to support@bitcasa.com.
//

#import <Foundation/Foundation.h>

@interface CFSError : NSError

/*!
 *  The error message
 */
@property (nonatomic, strong) NSString *message;

#pragma mark - Initilization

- (instancetype)init NS_UNAVAILABLE;

@end
