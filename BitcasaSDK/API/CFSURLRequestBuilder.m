//
//  CFSURLRequestBuilder.m
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

#import <CommonCrypto/CommonHMAC.h>

#import "CFSURLRequestBuilder.h"
#import "NSString+CFSRestAdditions.h"
#import "CFSRestAdapter.h"
#import "CFSItem.h"
#import "CFSContainer.h"
#import "CFSInputStream.h"

NSString *const CFSRestHeaderContentTypeForm = @"application/x-www-form-urlencoded; charset=\"utf-8\"";
NSString *const CFSRestHeaderContentTypeJson = @"application/json";
NSString *const CFSRestHeaderContentTypeField = @"Content-Type";
NSString *const CFSRestHeaderAuthField = @"Authorization";
NSString *const CFSRestHeaderDateField = @"Date";

NSString *const CFSRestHTTPMethodGET = @"GET";
NSString *const CFSRestHTTPMethodPOST = @"POST";
NSString *const CFSRestHTTPMethodDELETE = @"DELETE";

@implementation CFSURLRequestBuilder

+ (NSURLRequest *)urlRequestForHttpMethod:(NSString *)httpMethod
                                serverUrl:(NSString *)serverUrl
                               apiVersion:(NSString *)version
                                 endpoint:(NSString *)endpoint
                          queryParameters:(NSDictionary *)queryParams
                           formParameters:(NSDictionary *)formParams
                              accessToken:(NSString *)token
{
    NSMutableURLRequest *urlRequest = [CFSURLRequestBuilder mutableUrlRequestForHttpMethod:httpMethod
                                                                                   serverUrl:serverUrl
                                                                                  apiVersion:version
                                                                                    endpoint:endpoint
                                                                             queryParameters:queryParams
                                                                              formParameters:formParams];
    
    [CFSURLRequestBuilder authorizeRequest:urlRequest accessToken:token];
    return urlRequest;
}

+ (NSURLRequest *)urlRequestWithMultipartForHttpMethod:(NSString *)httpMethod
                                             serverUrl:(NSString *)serverUrl
                                            apiVersion:(NSString *)version
                                              endpoint:(NSString *)endpoint
                                       queryParameters:(NSDictionary *)queryParams
                                           inputStream:(NSInputStream *)inputStream
                                           accessToken:(NSString *)token
{
    NSMutableURLRequest *urlRequest = ((NSMutableURLRequest *)[CFSURLRequestBuilder urlRequestForHttpMethod:httpMethod
                                                                                                    serverUrl:serverUrl
                                                                                                   apiVersion:version
                                                                                                     endpoint:endpoint
                                                                                              queryParameters:queryParams
                                                                                               formParameters:NULL
                                                                                                  accessToken:token]);
    
    
    [urlRequest setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", CFSMultipartFormDataBoundary]
      forHTTPHeaderField:CFSRestHeaderContentTypeField];
    [urlRequest setHTTPBodyStream:inputStream];
    return urlRequest;
}

+ (NSURLRequest *)urlRequestForHttpMethod:(NSString *)httpMethod
                                serverUrl:(NSString *)serverUrl
                               apiVersion:(NSString *)version
                                 endpoint:(NSString *)endpoint
                          queryParameters:(NSDictionary *)queryParams
                           formParameters:(NSDictionary *)formParams
{
    return  [CFSURLRequestBuilder mutableUrlRequestForHttpMethod:httpMethod
                                                         serverUrl:serverUrl
                                                        apiVersion:version
                                                          endpoint:endpoint
                                                   queryParameters:queryParams
                                                    formParameters:formParams];
}

+ (NSURLRequest *)urlRequestForHttpMethod:(NSString *)httpMethod
                                serverUrl:(NSString *)serverUrl
                               apiVersion:(NSString *)version
                                 endpoint:(NSString *)endpoint
{
    return [CFSURLRequestBuilder urlRequestForHttpMethod:httpMethod
                                                 serverUrl:serverUrl
                                                apiVersion:version
                                                  endpoint:endpoint
                                           queryParameters:nil
                                            formParameters:nil];
}

+ (NSURLRequest *)urlRequestForHttpMethod:(NSString *)httpMethod
                                  itemUrl:(NSString *)itemUrl
                                 endpoint:(NSString *)endpoint
                          queryParameters:(NSDictionary *)queryParams
                           formParameters:(NSDictionary *)formParams
                              accessToken:(NSString *)token
{
    NSURLRequest *request = [CFSURLRequestBuilder urlRequestForHttpMethod:httpMethod
                                                                  serverUrl:itemUrl
                                                                 apiVersion:@""
                                                                   endpoint:endpoint
                                                            queryParameters:queryParams
                                                             formParameters:formParams
                                                                accessToken:token];
    return request;
}

+ (NSURLRequest *)signedUrlRequestForHttpMethod:(NSString *)httpMethod
                                      serverUrl:(NSString *)serverUrl
                                     apiVersion:(NSString *)version
                                       endpoint:(NSString *)endpoint
                                queryParameters:(NSDictionary *)queryParams
                                 formParameters:(NSDictionary *)formParams
                                       clientId:(NSString *)clientId
                                   clientSecret:(NSString *)clientSecret
{
    NSMutableURLRequest *urlRequest = [CFSURLRequestBuilder mutableUrlRequestForHttpMethod:httpMethod
                                                                                   serverUrl:serverUrl
                                                                                  apiVersion:(NSString *)version
                                                                                    endpoint:endpoint
                                                                             queryParameters:queryParams
                                                                              formParameters:formParams];
    [urlRequest setHTTPShouldHandleCookies:NO];

    NSMutableString *requestString = [NSMutableString stringWithString:httpMethod];
    [requestString appendString:[NSString stringWithFormat:@"&%@%@", version, endpoint]];

    [requestString appendString:[NSString stringWithFormat:@"&%@", [self parameterStringWithCollection:formParams]]];
    [requestString appendString:[NSString stringWithFormat:@"&%@:%@", CFSRestHeaderContentTypeField, [CFSRestHeaderContentTypeForm encode]]];

    NSDateFormatter *dateFormatter = [CFSURLRequestBuilder getDateFormatter];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    [requestString appendString:[NSString stringWithFormat:@"&%@:%@", CFSRestHeaderDateField, [dateString encode]]];

    NSString *signedRequestStr = [CFSURLRequestBuilder generateSignedRequestString:requestString
                                                                        clientSecret:clientSecret];

    [urlRequest addValue:dateString forHTTPHeaderField:CFSRestHeaderDateField];
    NSString *authValue = [NSString stringWithFormat:@"BCS %@:%@", clientId, signedRequestStr];
    [urlRequest addValue:authValue forHTTPHeaderField:CFSRestHeaderAuthField];
    
    return urlRequest;
}

#pragma mark - Private Methods
+ (NSMutableURLRequest *)mutableUrlRequestForHttpMethod:(NSString *)httpMethod
                                              serverUrl:(NSString *)serverUrl
                                             apiVersion:(NSString *)version
                                               endpoint:(NSString *)endpoint
                                        queryParameters:(NSDictionary *)queryParams
                                         formParameters:(NSDictionary *)formParams
{
    NSMutableString *urlStr = [NSMutableString stringWithFormat:@"%@%@%@", serverUrl, version, endpoint];
    
    if (queryParams && queryParams.count > 0) {
        [urlStr appendFormat:@"?%@", [self parameterStringWithCollection:queryParams]];
    }
    
    NSURL *requestURL = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    
    [request setHTTPMethod:httpMethod];
    
    NSData *formParamJsonData;
    NSString *contentTypeStr = CFSRestHeaderContentTypeForm;
    if (formParams && formParams.count > 0) {
        NSString *jsonStr = [self parameterStringWithCollection:formParams];
        jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
        formParamJsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    [request setValue:contentTypeStr forHTTPHeaderField:CFSRestHeaderContentTypeField];
    [request setHTTPBody:formParamJsonData];
    
    return request;
}

+ (void)authorizeRequest:(NSMutableURLRequest *)request
             accessToken:(NSString *)token
{
    [request addValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:CFSRestHeaderAuthField];
}

+ (NSDateFormatter *)getDateFormatter
{
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    NSLocale* locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [df setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [df setDateFormat:@"EEE', 'd' 'MMM' 'yyyy' 'HH':'mm':'ss' 'zzz"];
    [df setLocale:locale];
    return df;
}

+ (NSString *)generateSignedRequestString:(NSString *)requestString clientSecret:(NSString *)secret
{
    NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData *requestStrData = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *signedRequestData = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, secretData.bytes, secretData.length, requestStrData.bytes, requestStrData.length, signedRequestData.mutableBytes);
    NSString* signedRequestStr = [signedRequestData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    return signedRequestStr;
}

+ (NSString *)parameterStringWithCollection:(id)collection
{
    if ([collection isKindOfClass:[NSArray class]]) {
        return [NSString parameterStringWithArray:collection];
    }
    else if([collection isKindOfClass:[NSDictionary class]]) {
        return [NSString sortedParameterStringWithDictionary:collection];
    }
    return nil;
}

@end
