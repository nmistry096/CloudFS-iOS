//
//  BitcasaAPI.m
//  BitcasaSDK
//
//  Created by Olga on 8/21/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import "BitcasaAPI.h"
#import "NSString+API.h"
#import "Session.h"
#import "Configurations.h"

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

NSString* const kAPIEndpointToken = @"/oauth2/token";
NSString* const kAPIEndpointFolderAction = @"/folders";
NSString* const kAPIEndpointFileAction = @"/files";
NSString* const kAPIEndpointMetafolders = @"/metafolders";
NSString* const kAPIEndpointUser = @"/user";
NSString* const kAPIEndpointProfile = @"/profile/";
NSString* const kAPIEndpointAccount = @"/account";
NSString* const kAPIEndpointMsg = @"/msg/";
NSString* const kAPIEndpointSessions = @"/sessions/";
NSString* const kAPIEndpointCurrentSession = @"current/";
NSString* const kAPIEndpointThumbnail = @"/thumbnail/";
NSString* const kAPIEndpointShares = @"/shares/";
NSString* const kAPIEndpointEntrypoint = @"/filesystem/entrypoints/";
NSString* const kAPIEndpointTranscode = @"/transcode";
NSString* const kAPIEndpointVideo = @"/video";
NSString* const kAPIEndpointAudio = @"/audio";

NSString* const kCameraBackupEntrypointID = @"015199f04c044c5fa95fc69556cf723e";

NSString* const kHeaderContentType = @"Content-Type";
NSString* const kHeaderAuth = @"Authorization";
NSString* const kHeaderDate = @"Date";

NSString* const kHTTPMethodGET = @"GET";
NSString* const kHTTPMethodPOST = @"POST";
NSString* const kHTTPMethodDELETE = @"DELETE";

NSString* const kQueryParameterOperation = @"operation";

@implementation BitcasaAPI

+ (NSString*)baseURL
{
    return [[Configurations sharedInstance] serverURL];
}

+ (NSString*)apiVersion
{
    return @"/v2";
}

+ (NSString*)authContentType
{
    return @"application/x-www-form-urlencoded; charset=\"utf-8\"";
}

+ (NSString*)contentType
{
    return @"application/x-www-form-urlencoded";
}

#pragma mark - access token
+ (NSString *)accessTokenWithEmail:(NSString *)email password:(NSString *)password appId:(NSString*)appId secret:(NSString*)secret
{
    // formatting the request string (to be signed)
    NSMutableString* requestString = [NSMutableString stringWithString:kHTTPMethodPOST];
    [requestString appendString:[NSString stringWithFormat:@"&%@%@", [BitcasaAPI apiVersion], kAPIEndpointToken]];
    
    NSArray* parameters = @[@{@"grant_type": @"password"}, @{@"password" : password}, @{@"username" : email}];
    [requestString appendString:[NSString stringWithFormat:@"&%@", [NSString parameterStringWithArray:parameters]]];
    [requestString appendString:[NSString stringWithFormat:@"&%@:%@", kHeaderContentType, [[BitcasaAPI authContentType] encode]]];
    
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEE', 'd' 'MMM' 'yyyy' 'hh':'mm':'ss' 'z"];
    NSString* dateStr = [df stringFromDate:[NSDate date]];
    [requestString appendString:[NSString stringWithFormat:@"&%@:%@", kHeaderDate, [dateStr encode]]];
    
    // generating the signed request string
    NSData* secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData* requestStrData = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData* signedRequestData = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, secretData.bytes, secretData.length, requestStrData.bytes, requestStrData.length, signedRequestData.mutableBytes);
    NSString* signedRequestStr = [signedRequestData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    // creating the HTTP request
    NSString* baseURL = [BitcasaAPI baseURL];
    NSURL* tokenReqURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", baseURL, [BitcasaAPI apiVersion], kAPIEndpointToken]];
    NSMutableURLRequest* tokenRequest = [NSMutableURLRequest requestWithURL:tokenReqURL];
    
    [tokenRequest setHTTPMethod:kHTTPMethodPOST];
    
    // setting HTTP request headers
    [tokenRequest addValue:[BitcasaAPI authContentType] forHTTPHeaderField:kHeaderContentType];
    [tokenRequest addValue:dateStr forHTTPHeaderField:kHeaderDate];
    NSString* authValue = [NSString stringWithFormat:@"BCS %@:%@", appId,  signedRequestStr];
    [tokenRequest addValue:authValue forHTTPHeaderField:kHeaderAuth];
    
    // setting HTTP request parameters
    NSString* formParameters = [NSString parameterStringWithArray:parameters];
    [tokenRequest setHTTPBody:[formParameters dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError* err;
    NSHTTPURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:tokenRequest returningResponse:&response error:&err];
    if ([response statusCode] != 200)
        return nil;
    
    if (data)
    {
        NSError *jsonError = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (json[@"access_token"])
            return json[@"access_token"];
    }
    
    return nil;
}


@end
