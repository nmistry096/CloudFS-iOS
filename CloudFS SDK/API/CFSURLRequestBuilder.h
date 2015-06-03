//
//  CFSURLRequestBuilder.h
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

@class CFSItem;
@class CFSContainer;

/*!
 *  Helper class to build NSURLRequest for given parameters.
 */
@interface CFSURLRequestBuilder : NSObject

extern NSString *const CFSRestHTTPMethodGET;
extern NSString *const CFSRestHTTPMethodPOST;
extern NSString *const CFSRestHTTPMethodDELETE;

/*!
 *  Initializes an NSURLRequest with given parameters.
 *
 *  @param httpMethod  The HTTP Method. Use defined CFSRestHTTPMethod constants.
 *  @param serverUrl   The Server URL.
 *  @param endpoint    The REST Endpoint which is appended to server url.
 *  @param version  The version of the REST API to communicate with.
 *  @param queryParams The query parameters to send along with the request.
 *  @param formParams  The form parameters to add to the body. This has to be either an NSArray or NSDictionary.
 *
 *  @return Returns an initalized NSURLRequest.
 */
+ (NSURLRequest *)urlRequestForHttpMethod:(NSString *)httpMethod
                                serverUrl:(NSString *)serverUrl
                               apiVersion:(NSString *)version
                                 endpoint:(NSString *)endpoint
                          queryParameters:(NSDictionary *)queryParams
                           formParameters:(NSObject *)formParams;

/*!
 *  Initializes an NSURLRequest with given parameters.
 *
 *  @param httpMethod  The HTTP Method. Use defined CFSRestHTTPMethod constants.
 *  @param serverUrl   The Server URL.
 *  @param version  The version of the REST API to communicate with.
 *  @param endpoint    The REST Endpoint which is appended to server url.
 *  @param queryParams The query parameters to send along with the request.
 *  @param formParams  The form parameters to add to the body. This has to be either an NSArray or NSDictionary.
 *  @param token The access token to add to the header.
 *
 *  @return Returns an initalized NSURLRequest.
 */
+ (NSURLRequest *)urlRequestForHttpMethod:(NSString *)httpMethod
                                serverUrl:(NSString *)serverUrl
                               apiVersion:(NSString *)version
                                 endpoint:(NSString *)endpoint
                          queryParameters:(NSDictionary *)queryParams
                           formParameters:(NSObject *)formParams
                              accessToken:(NSString *)token;

/*!
 *  Initializes an NSURLRequest for a multi-part operation with given parameters.
 *
 *  @param httpMethod  The HTTP Method. Use defined CFSRestHTTPMethod constants. This can be either a 'POST' or 'PUT' in this case.
 *  @param serverUrl   The Server URL.
 *  @param version  The version of the REST API to communicate with.
 *  @param endpoint    The REST Endpoint which is appended to server url.
 *  @param queryParams The query parameters to send along with the request.
 *  @param inputStream The input stream containing the data to be sent.
 *  @param token The access token to add to the header.
 *
 *  @return Returns an initalized NSURLRequest.
 */
+ (NSURLRequest *)urlRequestWithMultipartForHttpMethod:(NSString *)httpMethod
                                             serverUrl:(NSString *)serverUrl
                                            apiVersion:(NSString *)version
                                              endpoint:(NSString *)endpoint
                                       queryParameters:(NSDictionary *)queryParams
                                           inputStream:(NSInputStream *)inputStream
                                           accessToken:(NSString *)token;

/*!
 *  Initializes an NSURLRequest with given parameters.
 *
 *  @param httpMethod  The HTTP Method. Use defined CFSRestHTTPMethod constants.
 *  @param itemUrl     The direct URL to the item.
 *  @param endpoint    The REST Endpoint which is appended to item url.
 *  @param queryParams The query parameters to send along with the request.
 *  @param formParams  The form parameters to add to the body. This has to be either an NSArray or NSDictionary.
 *  @param token The access token to add to the header.
 *
 *  @return Returns an initalized NSURLRequest.
 */
+ (NSURLRequest *)urlRequestForHttpMethod:(NSString *)httpMethod
                                  itemUrl:(NSString *)itemUrl
                                 endpoint:(NSString *)endpoint
                          queryParameters:(NSDictionary *)queryParams
                           formParameters:(id)formParams
                              accessToken:(NSString *)token;

/*!
 *  Initializes an NSURLRequest with given parameters.
 *
 *  @param httpMethod   The HTTP Method. Use defined CFSRestHTTPMethod constants.
 *  @param serverUrl    The Server URL.
 *  @param version   The version of the REST API to communicate with.
 *  @param endpoint     The REST Endpoint which is appended to server url.
 *  @param queryParams  The query parameters to send along with the request.
 *  @param formParams   The form parameters to add to the body. This has to be either an NSArray or NSDictionary.
 *  @param clientId     The Client ID.
 *  @param clientSecret The Client Secret.
 *
 *  @return Returns an initalized NSURLRequest.
 */
+ (NSURLRequest *)signedUrlRequestForHttpMethod:(NSString *)httpMethod
                                      serverUrl:(NSString *)serverUrl
                                     apiVersion:(NSString *)version
                                       endpoint:(NSString *)endpoint
                                queryParameters:(NSDictionary *)queryParams
                                 formParameters:(NSDictionary *)formParams
                                       clientId:(NSString *)clientId
                                   clientSecret:(NSString *)clientSecret;

/*!
 *  Initializes an NSURLRequest with given parameters.
 *
 *  @param httpMethod   The HTTP Method. Use defined CFSRestHTTPMethod constants.
 *  @param serverUrl    The Server URL.
 *  @param version   The version of the REST API to communicate with.
 *  @param endpoint     The REST Endpoint which is appended to server url.
 *
 *  @return Returns an initalized NSURLRequest.
 */
+ (NSURLRequest *)urlRequestForHttpMethod:(NSString *)httpMethod
                                serverUrl:(NSString *)serverUrl
                               apiVersion:(NSString *)version
                                 endpoint:(NSString *)endpoint;
@end
