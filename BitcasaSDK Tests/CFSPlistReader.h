//
//  CFSPlistReader.h
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

@interface CFSPlistReader : NSObject

/*!
 *  Initialization with Plist File name.
 *  @param fileName The Plist File name
 *  @return CFSPlistReader type object
 */

- (instancetype)initWithFileName:(NSString *)fileName NS_DESIGNATED_INITIALIZER;

/*!
 *  Get App config plist value for key.
 *  @param key The Plist key.
 *  @return Value The value of the key
 */

- (id)appConfigValueForKey:(NSString *)key;

@end
