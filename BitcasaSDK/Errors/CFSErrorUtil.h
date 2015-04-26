//
//  CFSErrorUtil.h
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

@class CFSError;

/*!
 *  Contains set of utility methods to create CFSError based on system NSError and network status codes.
 *  Created CFSError object contains error messages returned by the server calls if the CFSError is generated
 *  for a network response.
 */
@interface CFSErrorUtil : NSObject

#pragma mark - Initilization

- (instancetype)init NS_UNAVAILABLE;

/*!
 *  Creates CFSError instance from the NSError provided
 *
 *  @param code The NSError instance
 *
 *  @return Returns a CFSError instance
 */
+ (CFSError *)errorWithError:(NSError *)error;

/*!
 *  Creates a CFSError based on the response and error instance
 *
 *  @param responseData The network response data
 *  @param response The network response
 *  @param error    The error instance
 *
 *  @return Returns a CFSError instance
 */
+ (CFSError *)createErrorFrom:(NSData *)responseData
                     response:(NSURLResponse *)response
                        error:(NSError *)error;

/*!
 *  Creates a CFSError based on the response status code and error instance.
 *
 *  @param responseData The network response data.
 *  @param code         The status code of the response.
 *  @param error        The error instance.
 *
 *  @return Returns a CFSError instance
 */
+ (CFSError *)createErrorFrom:(NSData *)responseData
                   statusCode:(NSInteger)code
                        error:(NSError *)error;

@end
