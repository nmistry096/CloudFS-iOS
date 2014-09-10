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
#import "Credentials.h"
#import "Item.h"

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
NSString* const kAPIEndpointBatch = @"/batch";

NSString* const kCameraBackupEntrypointID = @"015199f04c044c5fa95fc69556cf723e";

NSString* const kHeaderContentType = @"Content-Type";
NSString* const kHeaderAuth = @"Authorization";
NSString* const kHeaderDate = @"Date";

NSString* const kHeaderContentTypeForm = @"application/x-www-form-urlencoded";
NSString* const kHeaderContentTypeJson = @"application/json";

NSString* const kHTTPMethodGET = @"GET";
NSString* const kHTTPMethodPOST = @"POST";
NSString* const kHTTPMethodDELETE = @"DELETE";

NSString* const kQueryParameterOperation = @"operation";
NSString* const kQueryParameterOperationMove = @"move";
NSString* const kQueryParameterOperationCreate = @"create";

NSString* const kDeleteRequestParameterCommit = @"commit";
NSString* const kDeleteRequestParameterForce = @"force";

NSString* const kRequestParameterTrue = @"true";
NSString* const kRequestParameterFalse = @"false";

NSString* const kBatchRequestJsonRequestsKey = @"requests";
NSString* const kBatchRequestJsonRelativeURLKey = @"relative_url";
NSString* const kBatchRequestJsonMethodKey = @"method";
NSString* const kBatchRequestJsonBody = @"body";

@interface BitcasaAPI ()
+ (NSString*)apiVersion;
+ (NSString*)authContentType;
+ (NSString*)contentType;
@end

@implementation NSURLRequest (Bitcasa)

- (id)initWithMethod:(NSString*)httpMethod endpoint:(NSString*)endpoint queryParameters:(NSArray*)queryParams formParameters:(id)formParams
{
    Credentials* baseCredentials = [Credentials sharedInstance];
    NSMutableString* urlStr = [NSMutableString stringWithFormat:@"%@%@%@", baseCredentials.serverURL, [BitcasaAPI apiVersion], endpoint];
    
    if (queryParams)
        [urlStr appendFormat:@"?%@", [NSString parameterStringWithArray:queryParams]];
    
    NSURL* profileRequestURL = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:profileRequestURL];
    
    [request setHTTPMethod:httpMethod];
    [request addValue:[NSString stringWithFormat:@"Bearer %@", baseCredentials.accessToken] forHTTPHeaderField:kHeaderAuth];
    
    NSData* formParamJsonData;
    NSString* contentTypeStr;
    if ([formParams isKindOfClass:[NSArray class]])
    {
        contentTypeStr = kHeaderContentTypeForm;
        NSString* formParameters = [NSString parameterStringWithArray:formParams];
        formParamJsonData = [formParameters dataUsingEncoding:NSUTF8StringEncoding];
    }
    else if ([formParams isKindOfClass:[NSDictionary class]])
    {
        contentTypeStr = kHeaderContentTypeJson;
        NSError* err;
        formParamJsonData = [NSJSONSerialization dataWithJSONObject:formParams options:0 error:&err];
        
        NSString* jsonStr = [[NSString alloc] initWithData:formParamJsonData encoding:NSUTF8StringEncoding];
        jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
        formParamJsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    }
    [request setValue:contentTypeStr forHTTPHeaderField:kHeaderContentType];
    [request setHTTPBody:formParamJsonData];
    
    return request;
}

- (id)initWithMethod:(NSString*)httpMethod endpoint:(NSString *)endpoint
{
    return [self initWithMethod:httpMethod endpoint:endpoint queryParameters:nil formParameters:nil];
}

@end


@implementation BitcasaAPI

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

+ (NSString*)relativeURLWithEndpoint:(NSString*)endpoint andQueryParams:(NSArray*)queryParams
{
    NSMutableString* urlStr = [NSMutableString stringWithFormat:@"%@%@", [BitcasaAPI apiVersion], endpoint];
    
    if (queryParams)
        [urlStr appendFormat:@"?%@", [NSString parameterStringWithArray:queryParams]];
    
    return urlStr;
}

#pragma mark - access token
+ (NSString *)accessTokenWithEmail:(NSString *)email password:(NSString *)password
{
    Credentials* baseCredentials = [Credentials sharedInstance];
    
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
    NSData* secretData = [baseCredentials.appSecret dataUsingEncoding:NSUTF8StringEncoding];
    NSData* requestStrData = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData* signedRequestData = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, secretData.bytes, secretData.length, requestStrData.bytes, requestStrData.length, signedRequestData.mutableBytes);
    NSString* signedRequestStr = [signedRequestData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    // creating the HTTP request
    NSURL* tokenReqURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", baseCredentials.serverURL, [BitcasaAPI apiVersion], kAPIEndpointToken]];
    NSMutableURLRequest* tokenRequest = [NSMutableURLRequest requestWithURL:tokenReqURL];
    
    [tokenRequest setHTTPMethod:kHTTPMethodPOST];
    
    // setting HTTP request headers
    [tokenRequest addValue:[BitcasaAPI authContentType] forHTTPHeaderField:kHeaderContentType];
    [tokenRequest addValue:dateStr forHTTPHeaderField:kHeaderDate];
    NSString* authValue = [NSString stringWithFormat:@"BCS %@:%@", baseCredentials.appId,  signedRequestStr];
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

#pragma mark - Profile
+ (void)getProfileWithCompletion:(void(^)(NSDictionary* response))completion
{
    NSString *profileEndpoint = [NSString stringWithFormat:@"%@%@", kAPIEndpointUser, kAPIEndpointProfile];
    NSURLRequest* profileRequest = [[NSURLRequest alloc] initWithMethod:kHTTPMethodGET endpoint:profileEndpoint];
    
    [NSURLConnection sendAsynchronousRequest:profileRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         NSInteger responseStatusCode = [((NSHTTPURLResponse*)response) statusCode];
         if (responseStatusCode == 200)
         {
             NSDictionary* responseDict;
             if (data)
             {
                 NSError* err;
                 responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
             }
             if (completion)
                 completion(responseDict[@"result"]);
             return;
         }
         else if (responseStatusCode == 401)
         {
             //[[BCTransferManager sharedManager] reauthenticate];
         }
         if (completion)
             completion(nil);
     }];
}

#pragma mark - Directory contents
+ (void)getContentsOfDirectory:(NSString*)directoryPath completion:(void (^)(NSArray* response))completion
{
    // Expect directoryPath in form /folderID/subFolderID to any depth or nil for root
    // Ex. "/d2fe48a238844cf28750241b41516e50/8f41560133ad4a1c8a9ca005eede9730"
    NSString* dirReqEndpoint = [NSString stringWithFormat:@"%@%@", kAPIEndpointFolderAction, directoryPath];
    NSURLRequest* dirContentsRequest = [[NSURLRequest alloc] initWithMethod:kHTTPMethodGET endpoint:dirReqEndpoint];
    
    [NSURLConnection sendAsynchronousRequest:dirContentsRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         NSArray* responseArray;
         if (data)
         {
             NSError* err;
             responseArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
         }
         
         completion(responseArray);
     }];
}

#pragma mark - Move item(s)
+ (void)moveItems:(NSArray*)items to:(id)toItem completion:(void (^)(NSURLResponse* response, NSData* data))completion
{
    NSMutableArray* requests = [NSMutableArray array];
    for (id item in items)
    {
        NSString* moveEndpoint;
        if ([item isKindOfClass:[Item class]])
            moveEndpoint = ((Item*)item).url;
        else
            moveEndpoint = item;
        NSArray* moveQueryParams = @[@{kQueryParameterOperation : kQueryParameterOperationMove}];
        NSString* moveRelativeURL = [BitcasaAPI relativeURLWithEndpoint:moveEndpoint andQueryParams:moveQueryParams];
        
        NSString* destURL;
        if ([toItem isKindOfClass:[Item class]])
            destURL = ((Item*)toItem).url;
        else
            destURL = toItem;
        NSDictionary* moveFormParams = @{@"to": destURL, @"name": moveEndpoint};
        
        [requests addObject:@{kBatchRequestJsonRelativeURLKey:moveRelativeURL, kBatchRequestJsonMethodKey:kHTTPMethodPOST, kBatchRequestJsonBody:moveFormParams}];
    }
    
    NSDictionary* formParamDict = @{kBatchRequestJsonRequestsKey: requests};
    
    NSURLRequest* batchMoveRequest = [[NSURLRequest alloc] initWithMethod:kHTTPMethodPOST endpoint:kAPIEndpointBatch queryParameters:nil formParameters:formParamDict];
    
    [NSURLConnection sendAsynchronousRequest:batchMoveRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         completion(response, data);
     }];
}

#pragma mark - Delete item(s)
+ (NSArray*)deleteQueryParamsForNode:(Item*)item deletePermanently:(BOOL)permanently
{
    NSMutableArray* deleteQueryParams = [NSMutableArray arrayWithArray:@[@{kDeleteRequestParameterCommit : permanently ? kRequestParameterTrue : kRequestParameterFalse}]];
    if (NO) // add item is container check
        [deleteQueryParams addObject:@{kDeleteRequestParameterForce : kRequestParameterTrue}];
    
    return deleteQueryParams;
}

+ (void)deleteItems:(NSArray*)items completion:(void (^)(NSURLResponse* response, NSData* data))completion
{
    NSMutableArray* requests = [NSMutableArray array];
    for (id item in items)
    {
        NSString* deleteEndpoint;
        if ([item isKindOfClass:[Item class]])
            deleteEndpoint = ((Item*)item).url;
        else
            deleteEndpoint = (NSString*)item;
        
        NSArray* deleteQueryParams = [self deleteQueryParamsForNode:item deletePermanently:NO];
        NSString* relativeURL = [BitcasaAPI relativeURLWithEndpoint:deleteEndpoint andQueryParams:deleteQueryParams];
        
        [requests addObject:@{kBatchRequestJsonRelativeURLKey:relativeURL, kBatchRequestJsonMethodKey:kHTTPMethodDELETE, kBatchRequestJsonBody:[NSNull null]}];
    }
    
    NSDictionary* formParamDict = @{kBatchRequestJsonRequestsKey: requests};
    
    NSURLRequest* batchDeleteRequest = [[NSURLRequest alloc] initWithMethod:kHTTPMethodPOST endpoint:kAPIEndpointBatch queryParameters:nil formParameters:formParamDict];
    
    [NSURLConnection sendAsynchronousRequest:batchDeleteRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         completion(response, data);
     }];
}

#pragma mark - Make new directory
+ (void)createFolderAtPath:(NSString*)path withName:(NSString*)name completion:(void (^)(NSURLResponse* response, NSData* data))completion
{
    NSString* createFolderEndpoint = [NSString stringWithFormat:@"%@%@", kAPIEndpointFolderAction, path];
    NSArray* createFolderQueryParams = @[@{kQueryParameterOperation : kQueryParameterOperationCreate}];
    NSMutableArray* createFolderFormParams = [NSMutableArray arrayWithObjects:@{@"name": name}, @{@"exists":@"rename"}, nil];
    
    NSURLRequest* createFolderRequest = [[NSURLRequest alloc] initWithMethod:kHTTPMethodPOST endpoint:createFolderEndpoint queryParameters:createFolderQueryParams formParameters:createFolderFormParams];
    
    [NSURLConnection sendAsynchronousRequest:createFolderRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         completion(response, data);
     }];
}
@end
