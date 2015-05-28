//
//  CFSRestAdapter.m
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

#import "CFSRestAdapter.h"
#import "NSString+CFSRestAdditions.h"
#import "NSMutableDictionary+CFSRestAdditions.h"
#import "CFSURLRequestBuilder.h"
#import "CFSSession.h"
#import "CFSItem.h"
#import "CFSContainer.h"
#import "CFSUser.h"
#import "CFSTransferManager.h"
#import "CFSInputStream.h"
#import "CFSAssetStream.h"
#import "CFSFolder.h"
#import "CFSFile.h"
#import "CFSShare.h"
#import "CFSAccount.h"
#import "CFSErrorUtil.h"
#import "CFSPlan.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import "NSMutableDictionary+CFSRestAdditions.h"

@class CFSError;

NSString *const CFSAPIEndpointToken = @"/oauth2/token";
NSString *const CFSAPIEndpointMetafolders = @"/metafolders";
NSString *const CFSAPIEndpointUser = @"/user";
NSString *const CFSAPIEndpointProfile = @"/profile/";
NSString *const CFSAPIEndpointAccount = @"/account";
NSString *const CFSAPIEndpointSessions = @"/sessions/";
NSString *const CFSAPIEndpointCurrentSession = @"current/";
NSString *const CFSAPIEndpointShares = @"/shares/";
NSString *const CFSAPIEndpointTrash = @"/trash/";
NSString *const CFSAPIEndpointHistory = @"/history";
NSString *const CFSAPIEndpointMeta = @"/meta";
NSString *const CFSAPIEndpointAdminCustomers = @"/admin/cloudfs/customers/";
NSString *const CFSAPIEndpointCustomers = @"/admin/customers/";
NSString *const CFSAPIEndpointFilesystemAction = @"/filesystem/root";
NSString *const CFSAPIEndpointPlan = @"plan/";

NSString *const CFSHeaderContentType = @"Content-Type";
NSString *const CFSHeaderAuth = @"Authorization";
NSString *const CFSHeaderDate = @"Date";
NSString *const CFSHeaderLocation = @"Location";

NSString *const CFSHeaderContentTypeForm = @"application/x-www-form-urlencoded";
NSString *const CFSHeaderContentTypeJson = @"application/json";
NSString *const CFSRestHeaderContentType = @"Content-Type";
NSString *const CFSRestHeaderAuth = @"Authorization";

NSString *const CFSHTTPMethodGET = @"GET";
NSString *const CFSHTTPMethodPOST = @"POST";
NSString *const CFSHTTPMethodDELETE = @"DELETE";

NSString *const CFSDeleteRequestParameterCommit = @"commit";
NSString *const CFSDeleteRequestParameterForce = @"force";

NSString *const CFSTrashRequestParameterRestore = @"restore";
NSString *const CFSTrashRequestParameterRescuePath = @"rescue-path";
NSString *const CFSTrashRecreateParameterRescuePath = @"recreate-path";

NSString *const CFSAuthenticateAccessToken =  @"access_token";
NSString *const CFSAuthenticateGrantType =  @"grant_type";
NSString *const CFSAuthenticatePassword =  @"password";
NSString *const CFSAuthenticateUsername =  @"username";

NSString *const CFSRequestParameterTrue = @"true";
NSString *const CFSRequestParameterFalse = @"false";

NSString *const CFSBatchRequestJsonRequestsKey = @"requests";
NSString *const CFSBatchRequestJsonRelativeURLKey = @"relative_url";
NSString *const CFSBatchRequestJsonMethodKey = @"method";
NSString *const CFSBatchRequestJsonBody = @"body";

NSString *const CFSShareResponseResultShareKey = @"share_key";
NSString *const CFSShareResponseResultUrl = @"url";
NSString *const CFSShareResponseResultShortUrl = @"short_url";
NSString *const CFSShareResponseResultDateCreated = @"date_created";

NSString *const CFSFormParameterCreateAccountUserKey = @"username";
NSString *const CFSFormParameterCreateAccountPasswordKey = @"password";
NSString *const CFSFormParameterCreateAccountEmailKey = @"email";
NSString *const CFSFormParameterCreateAccountFirstNameKey = @"first_name";
NSString *const CFSFormParameterCreateAccountLastNameKey = @"last_name";
NSString *const CFSFormParameterPathKey = @"path";
NSString *const CFSFormParameterPasswordKey = @"password";
NSString *const CFSFormParameterCurrentPasswordKey = @"current_password";
NSString *const CFSFormParameterNameKey = @"name";
NSString *const CFSFormParameterOldPasswordKey = @"oldPassword";
NSString *const CFSFormParameterExistsKey = @"exists";
NSString *const CFSFormParameterToKey = @"to";
NSString *const CFSFormParameterRescueKey = @"rescue";
NSString *const CFSFormParameterRecreateKey = @"recreate";
NSString *const CFSFormParameterPlanName = @"name";
NSString *const CFSFormParameterPlanLimit = @"limit";
NSString *const CFSFormParameterPlanCode = @"plan_code";

NSString *const CFSQueryParameterStartVersionKey = @"start-version";
NSString *const CFSQueryParameterEndVersionKey = @"end-version";
NSString *const CFSQueryParameterLimitKey = @"limit";

NSString *const CFSRestApiVersion = @"/v2";
NSString *const CFSRestApiEndpointFolders = @"/folders";
NSString *const CFSRestApiEndpointFiles = @"/files";
NSString *const CFSRestQueryParameterOperation = @"operation";
NSString *const CFSRestAPIEndpointShares = @"/shares/";
NSString *const CFSRestAPIEndpointInfo = @"/info";
NSString *const CFSRestAPIEndpointUnlock = @"/unlock";
NSString *const CFSRestAPIEndpointMeta = @"/meta";
NSString *const CFSRestApiEndPointVersions  = @"/versions";

NSString *const CFSQueryParameterOperation = @"operation";
NSString *const CFSQueryParameterOperationMove = @"move";
NSString *const CFSQueryParameterOperationCopy = @"copy";
NSString *const CFSQueryParameterOperationCreate = @"create";
NSString *const CFSQueryParameterHistoryStart = @"start";
NSString *const CFSQueryParameterHistoryStop = @"stop";

NSString *const CFSItemTypeFile = @"file";
NSString *const CFSItemTypeFolder = @"folder";
NSString *const CFSItemTypeFileSystem = @"filesystem";

NSString *const CFSAssertShareZeroLengthMessage = @"Share key length should not be 0";
NSString *const CFSAssertPathZeroLengthMessage = @"Path length should not be 0";
NSString *const CFSAssertVersionZeroLengthMessage = @"Version length should not be 0";
NSString *const CFSAssertTypeZeroLengthMessage = @"Type length should not be 0";
NSString *const CFSAssertPasswordZeroLengthMessage = @"Password length should not be 0";
NSString *const CFSAssertNameZeroLengthMessage = @"Name length should not be 0";
NSString *const CFSAssertFolderWrongTypeMessage = @"Folder reference should not be NSNull";
NSString *const CFSAssertTypeWrongMessage = @"Not a valid type";

NSString *const CFSOperationExistsFail = @"fail";
NSString *const CFSOperationExistsRename = @"rename";
NSString *const CFSOperationExistsOverwrite = @"overwrite";
NSString *const CFSOperationExistsReuse = @"reuse";

NSString *const CFSItemStateIsTrash = @"isTrash";
NSString *const CFSItemStateIsOldVersion = @"isOldVersion";
NSString *const CFSItemStateIsShare= @"isShare";
NSString *const CFSItemShareKey= @"shareKey";

NSString *const CFSResponseStorageKey= @"storage";
NSString *const CFSResponseLimitKey= @"limit";
NSString *const CFSResponseUsageKey= @"usage";
NSString *const CFSResponseLimitHeaderKey= @"X-BCS-Account-Storage-Limit";
NSString *const CFSResponseUsageHeaderKey= @"X-BCS-Account-Storage-Usage";

@interface CFSRestAdapter ()

@property (nonatomic, copy) NSString *serverUrl;
@property (nonatomic, copy) NSString *clientId;
@property (nonatomic, copy) NSString *secret;
@property (nonatomic, copy) NSString *adminId;
@property (nonatomic, copy) NSString *adminSecret;
@property (nonatomic, strong) CFSTransferManager *transferManager;

@end

@implementation CFSRestAdapter

+ (NSString *)authContentType
{
    return @"application/x-www-form-urlencoded; charset=\"utf-8\"";
}

#pragma mark - Initilization
- (instancetype)initWithServerUrl:(NSString *)serverUrl
                        clientId:(NSString *)clientId
                    clientSecret:(NSString *)secret
{
    return [self initWithServerUrl:serverUrl
                          clientId:clientId
                      clientSecret:secret
                       accessToken:nil];
}

- (instancetype)initWithServerUrl:(NSString *)serverUrl
                        clientId:(NSString *)clientId
                    clientSecret:(NSString *)secret
                     accessToken:(NSString *)token
{
    self = [super init];
    if (self) {
        self.accessToken = token;
        self.serverUrl = serverUrl;
        self.clientId = clientId;
        self.secret = secret;
        self.transferManager = [[CFSTransferManager alloc] initWithRestAdapter:self];
    }
    
    return self;
}

#pragma mark - Authentication
- (void)authenticateWithEmail:(NSString *)email
                     password:(NSString *)password
            completionHandler:(CFSRestAdapterTokenCompletion)handler
{
    NSDictionary *parameters = @{CFSAuthenticateGrantType: CFSAuthenticatePassword,
                                 CFSAuthenticatePassword: password,
                                 CFSAuthenticateUsername: email};
    NSURLRequest *request = [CFSURLRequestBuilder signedUrlRequestForHttpMethod:CFSRestHTTPMethodPOST
                                                                        serverUrl:self.serverUrl
                                                                       apiVersion:CFSRestApiVersion
                                                                         endpoint:CFSAPIEndpointToken
                                                                  queryParameters:nil
                                                                   formParameters:parameters
                                                                         clientId:self.clientId
                                                                     clientSecret:self.secret];
    __weak CFSRestAdapter *weakSelf = self;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
       CFSError *error = nil;
       NSString *accessToken = nil;
       if ([self isResponeSucessful:response data:data]) {
           NSError *jsonError = nil;
           NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&jsonError];
           accessToken = jsonDictionary[CFSAuthenticateAccessToken];
       } else {
           error = [CFSErrorUtil createErrorFrom:data response:response error:connectionError];
       }
                               
       weakSelf.accessToken = accessToken;
       handler(accessToken, error);
    }];
}

#pragma mark - Get profile
- (void)getProfileWithCompletion:(void(^)(NSDictionary *response , CFSError *error))completion
{
    NSString *profileEndpoint = [NSString stringWithFormat:@"%@%@", CFSAPIEndpointUser, CFSAPIEndpointProfile];
    NSURLRequest *profileRequest = [CFSURLRequestBuilder urlRequestForHttpMethod:CFSRestHTTPMethodGET
                                                                         serverUrl:self.serverUrl
                                                                        apiVersion:CFSRestApiVersion
                                                                          endpoint:profileEndpoint
                                    queryParameters:nil formParameters:nil accessToken:self.accessToken];
    [NSURLConnection sendAsynchronousRequest:profileRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         NSDictionary *resultDictionary = nil;
        CFSError *error = nil;
         if ([self isResponeSucessful:response data:data]) {
            resultDictionary = [self resultDictionaryFromResponseData:data];
         } else {
            error = [CFSErrorUtil createErrorFrom:data response:response error:connectionError];
         }
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            if (httpResponse.allHeaderFields[CFSResponseLimitHeaderKey]) {
                resultDictionary[CFSResponseStorageKey][CFSResponseLimitKey] = httpResponse.allHeaderFields[@"X-BCS-Account-Storage-Limit"];
            }
            if (httpResponse.allHeaderFields[CFSResponseUsageHeaderKey]) {
                resultDictionary[CFSResponseStorageKey][CFSResponseUsageKey] = httpResponse.allHeaderFields[@"X-BCS-Account-Storage-Usage"];
            }
        }
         completion(resultDictionary, error);
     }];
}

- (void)listContentsOfPath:(NSString *)path
                completion:(void (^)(NSArray *items, CFSError *error))completion
{
    [self getMetaDataWithPath:path type:CFSItemTypeFolder completionHandler:^(NSDictionary *dictionary, CFSError *error) {
        CFSFolder *folder = [[CFSFolder alloc] initWithDictionary:dictionary andParentPath:[self getParentPathFromPath:path] andRestAdapter:self];
        [self listContentsOfContainer:folder completion:completion];
    }];
}

- (NSString *)getParentPathFromPath:(NSString *)path
{
    NSString * parentPath = nil;
    if ([path containsString:@"/"]) {
        NSMutableArray *subStrings =[NSMutableArray arrayWithArray:[path componentsSeparatedByString:@"/"]];
        [subStrings removeLastObject];
        if (subStrings.count>1) {
            parentPath = [[subStrings valueForKey:@"description"] componentsJoinedByString:@"/"];
        } else if (subStrings.count == 1) {
            parentPath = @"/";
        } else {
            parentPath = @"";
        }
    } else {
        parentPath =@"";
    }
    return parentPath;
}

#pragma mark - List directory contents
- (void)listContentsOfContainer:(CFSContainer *)container
                     completion:(void (^)(NSArray *items, CFSError *error))completion
{    
    NSParameterAssert(container);
    
    NSString *dirReqEndpoint = [NSString stringWithFormat:@"%@%@", CFSRestApiEndpointFolders, container.path];    
    NSURLRequest *dirContentsRequest = [CFSURLRequestBuilder urlRequestForHttpMethod:CFSRestHTTPMethodGET
                                                                             serverUrl:self.serverUrl
                                                                            apiVersion:CFSRestApiVersion
                                                                              endpoint:dirReqEndpoint
                                                                       queryParameters:nil
                                                                        formParameters:nil
                                                                           accessToken:self.accessToken];
    [NSURLConnection sendAsynchronousRequest:dirContentsRequest
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         CFSError *error = nil;
         NSArray *items = nil;
         if ([self isResponeSucessful:response data:data]) {
             items = [self parseListAtContainter:container response:response data:data error:connectionError];
         } else {
             error = [CFSErrorUtil createErrorFrom:data response:response error:connectionError];
         }
         
         completion(items, error);
     }];
}

- (void)getContentsOfTrashWithPath:(NSString *)path completion:(void (^)(NSArray* items, CFSError *error))completion;
{
    
    NSString *trashEndPoint = nil;
    if (path) {
        trashEndPoint = [NSString stringWithFormat:@"%@%@", CFSAPIEndpointTrash, path];
    } else {
        trashEndPoint = CFSAPIEndpointTrash;
    }
    
        
    NSURLRequest *trashContentsRequest = [CFSURLRequestBuilder urlRequestForHttpMethod:CFSRestHTTPMethodGET
                                                                               serverUrl:self.serverUrl
                                                                              apiVersion:CFSRestApiVersion
                                                                                endpoint:trashEndPoint
                                                                         queryParameters:nil
                                                                          formParameters:nil
                                                                             accessToken:self.accessToken];
    [NSURLConnection sendAsynchronousRequest:trashContentsRequest queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        CFSError *error = nil;
        NSArray *itemArray  =nil;
        if ([self isResponeSucessful:response data:data]) {
            NSArray *itemsDictArray = [self itemDictsFromResponseData:data];
            itemArray = [self getItemsArrayFrom:itemsDictArray withParentPath:path withState:CFSItemStateIsTrash];
        } else {
            error = [CFSErrorUtil createErrorFrom:data response:response error:connectionError];
        }
        
        completion(itemArray,error);
    }];
}

- (void)setAdminCredentialsWithAdminClientId:(NSString *)adminClientId
                          adminClientSecret:(NSString *)adminClientSecret
{
    self.adminId = adminClientId;
    self.adminSecret = adminClientSecret;
}

#pragma mark - Move item(s)
- (void)moveItem:(CFSItem *)itemToMove
              to:(CFSContainer *)destination
      whenExists:(CFSExistsOperation)operation
      completion:(void (^)(CFSItem *movedItem, CFSError *error))completion
{
    NSString *exists = [self existsOperationToString:operation];
    if (!exists) {
        exists = CFSOperationExistsRename;
    }
    
    NSString *endpointPath;
    if ([itemToMove isKindOfClass:[CFSContainer class]] || [itemToMove isKindOfClass:[CFSFolder class]]) {
        endpointPath = [NSString stringWithFormat:@"%@%@", CFSRestApiEndpointFolders, itemToMove.path];
    } else if ([itemToMove isKindOfClass:[CFSFile class]]) {
        endpointPath = [NSString stringWithFormat:@"%@%@", CFSRestApiEndpointFiles, itemToMove.path];
    }
    
    NSDictionary *queryParams = @{CFSRestQueryParameterOperation: CFSQueryParameterOperationMove};
    NSString *toItemPath = destination.path;
    NSDictionary *moveFormParams = @{CFSFormParameterToKey: toItemPath, CFSFormParameterNameKey: itemToMove.name, CFSFormParameterExistsKey: exists};
    NSURLRequest *moveRequest = [CFSURLRequestBuilder urlRequestForHttpMethod:CFSRestHTTPMethodPOST
                                                                      serverUrl:self.serverUrl
                                                                     apiVersion:CFSRestApiVersion
                                                                       endpoint:endpointPath
                                                                queryParameters:queryParams
                                                                 formParameters:moveFormParams
                                                                    accessToken:self.accessToken];
    [NSURLConnection sendAsynchronousRequest:moveRequest
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         CFSItem *newItem = nil;
         CFSError *error = nil;
         NSDictionary* responseMeta = [self metaDictFromResponseData:data];
         if ([self isResponeSucessful:response data:data]) {
             if ([itemToMove isKindOfClass:[CFSContainer class]]) {
                 newItem = [[CFSContainer alloc] initWithDictionary:responseMeta andParentContainer:destination andRestAdapter:self];
             } else {
                 newItem = [[CFSFile alloc] initWithDictionary:responseMeta andParentContainer:destination andRestAdapter:self];
             }
         } else {
             error = [CFSErrorUtil createErrorFrom:data response:response error:connectionError];
         }

         completion(newItem, error);
     }];
}

#pragma mark - Copy item(s)
- (void)copyItem:(CFSItem*)itemToCopy
              to:(CFSContainer*)destination
      whenExists:(CFSExistsOperation)operation
            name:(NSString *)name
      completion:(void (^)(CFSItem* newItem, CFSError *error))completion
{
    NSString *exists = [self existsOperationToString:operation];
    if (!exists) {
        exists = CFSOperationExistsRename;
    }
    
    if (!name || name.length == 0)
    {
        name = itemToCopy.name;
    }
    
    NSString *endpointPath;
    if ([itemToCopy isKindOfClass:[CFSContainer class]] || [itemToCopy isKindOfClass:[CFSFolder class]]) {
        endpointPath = [NSString stringWithFormat:@"%@%@", CFSRestApiEndpointFolders, itemToCopy.path];
    } else if ([itemToCopy isKindOfClass:[CFSFile class]]) {
        endpointPath = [NSString stringWithFormat:@"%@%@", CFSRestApiEndpointFiles, itemToCopy.path];
    }
    
    NSDictionary *queryParams = @{CFSRestQueryParameterOperation : CFSQueryParameterOperationCopy};
    NSString *toItemPath = destination.path;
    NSDictionary *copyFormParams = @{CFSFormParameterToKey: toItemPath, CFSFormParameterNameKey: name, CFSFormParameterExistsKey: exists};
    NSURLRequest *copyRequest = [CFSURLRequestBuilder urlRequestForHttpMethod:CFSRestHTTPMethodPOST
                                                                    serverUrl:self.serverUrl
                                                                   apiVersion:CFSRestApiVersion
                                                                     endpoint:endpointPath
                                                              queryParameters:queryParams
                                                               formParameters:copyFormParams
                                                                  accessToken:self.accessToken];
    [NSURLConnection sendAsynchronousRequest:copyRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        CFSItem* newItem = nil;
        CFSError* error = nil;
        if ([self isResponeSucessful:response data:data]) {
            if ([itemToCopy isKindOfClass:[CFSContainer class]]) {
                newItem = [[CFSContainer alloc] initWithDictionary:[self metaDictFromResponseData:data] andParentContainer:destination andRestAdapter:self];
            } else {
                newItem = [[CFSFile alloc] initWithDictionary:[self metaDictFromResponseData:data] andParentContainer:destination andRestAdapter:self];
            }
        } else {
            error = [CFSErrorUtil createErrorFrom:data response:response error:connectionError];
        }
        completion(newItem, error);
    }];
}

#pragma mark - Delete item(s)
- (void)deleteItem:(CFSItem *)itemToDelete
            commit:(BOOL)commit
             force:(BOOL)force
        completion:(void (^)(BOOL success, CFSError *error))completion

{
    
    NSMutableDictionary* deleteQueryParams = [NSMutableDictionary dictionary];
    NSString *deleteEndpoint;
    if (itemToDelete.isTrash) {
        deleteEndpoint = [NSString stringWithFormat:@"%@%@", CFSAPIEndpointTrash, itemToDelete.path];
    } else {
        if ([itemToDelete isKindOfClass:[CFSContainer class]] || [itemToDelete isKindOfClass:[CFSFolder class]]) {
            deleteEndpoint = [NSString stringWithFormat:@"%@%@", CFSRestApiEndpointFolders, itemToDelete.path];
        } else if ([itemToDelete isKindOfClass:[CFSFile class]]) {
            deleteEndpoint = [NSString stringWithFormat:@"%@%@", CFSRestApiEndpointFiles, itemToDelete.path];
        }
        
        NSString *commitValue = (commit) ? @"true" : @"false";
        NSString *forceValue = (force) ? @"true" : @"false";
        [deleteQueryParams setValue:commitValue forKey:CFSDeleteRequestParameterCommit];
        if ([itemToDelete isKindOfClass:[CFSContainer class]]){
            [deleteQueryParams setValue:forceValue forKey:CFSDeleteRequestParameterForce];
        }
    }
    
    NSURLRequest* deleteRequest = [CFSURLRequestBuilder urlRequestForHttpMethod:CFSRestHTTPMethodDELETE
                                                                        serverUrl:self.serverUrl
                                                                       apiVersion:CFSRestApiVersion
                                                                         endpoint:deleteEndpoint
                                                                  queryParameters:deleteQueryParams
                                                                   formParameters:nil
                                                                      accessToken:self.accessToken];
    [NSURLConnection sendAsynchronousRequest:deleteRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         CFSError *error = nil;
         if (![self isResponeSucessful:response data:data]) {
             error = [CFSErrorUtil createErrorFrom:data response:response error:connectionError];
         }

         completion([self isResponeSucessful:response data:data], error);
     }];
}

#pragma mark - Restore item
- (void)restoreItem:(CFSItem *)itemToRestore
      restoreMethod:(RestoreOptions)option
    restoreArgument:(NSString *)restoreArgument
                 to:(CFSContainer*)toItem
         completion:(void (^)(BOOL success, CFSError *error))completion
{
    NSString *restoreEndpoint = [NSString stringWithFormat:@"%@%@", CFSAPIEndpointTrash, itemToRestore.path];
    NSDictionary *formParams;
    if (option == RestoreOptionsFail) {
    } else if (option == RestoreOptionsRecreate) {
        formParams = @{ CFSTrashRequestParameterRestore : CFSFormParameterRecreateKey, CFSTrashRecreateParameterRescuePath : restoreArgument};
    } else if (option == RestoreOptionsRescue) {
        NSString *path = nil;
        if(!toItem.isTrash)
        {
            path = toItem.path;
        }
        formParams = @{CFSTrashRequestParameterRestore : CFSFormParameterRescueKey, CFSTrashRequestParameterRescuePath : path};
    }
    
    NSURLRequest *restoreRequest = [CFSURLRequestBuilder urlRequestForHttpMethod:CFSRestHTTPMethodPOST
                                                                       serverUrl:self.serverUrl
                                                                      apiVersion:CFSRestApiVersion
                                                                        endpoint:restoreEndpoint
                                                                 queryParameters:nil
                                                                  formParameters:formParams
                                                                     accessToken:self.accessToken];
    [NSURLConnection sendAsynchronousRequest:restoreRequest
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)  {
                               CFSError *error = nil;
                               if (![self isResponeSucessful:response data:data]) {
                                   error = [CFSErrorUtil createErrorFrom:data response:response error:connectionError];
                               }
                               
                               completion([self isResponeSucessful:response data:data], error);
                           }];
}

#pragma mark - Shares
- (void)listSharesWithCompletion:(void (^)(NSArray *shares, CFSError *error))completion
{
    NSURLRequest *listShares = [CFSURLRequestBuilder urlRequestForHttpMethod:CFSRestHTTPMethodGET
                                                                     serverUrl:self.serverUrl
                                                                    apiVersion:CFSRestApiVersion
                                                                      endpoint:CFSRestAPIEndpointShares
                                                               queryParameters:nil
                                                                formParameters:nil
                                                                   accessToken:self.accessToken];
    [NSURLConnection sendAsynchronousRequest:listShares
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSArray *shares = nil;
        CFSError *error = nil;
        if ([self isResponeSucessful:response data:data]) {
            shares = [self parseListOfSharesWithResponse:response data:data error:connectionError];
        } else {
            error = [CFSErrorUtil createErrorFrom:data response:response error:connectionError];
        }
                               
        completion(shares, error);
     }];
}

- (void)receiveShare:(NSString *)shareKey
           path:(NSString *)path
          whenExists:(CFSExistsOperation)operation
          completion:(void (^)(NSArray *items, CFSError *error))completion
{
    NSAssert(shareKey.length != 0, CFSAssertShareZeroLengthMessage);
    NSAssert(path.length != 0, CFSAssertPathZeroLengthMessage);
    
    NSString *exists = [self existsOperationToString:operation];
    if (!exists) {
        exists = CFSOperationExistsRename;
    }
    
    NSString *receiveShareEndPoint = [NSString stringWithFormat:@"%@%@/", CFSRestAPIEndpointShares, shareKey];
    NSMutableDictionary *formParameters = [NSMutableDictionary dictionary];
    [formParameters setValue:path forKey:@"path"];
    [formParameters setValue:exists forKey:@"exists"];
    NSURLRequest *receiveShare = [CFSURLRequestBuilder urlRequestForHttpMethod:CFSRestHTTPMethodPOST
                                                                   serverUrl:self.serverUrl
                                                                  apiVersion:CFSRestApiVersion
                                                                    endpoint:receiveShareEndPoint
                                                             queryParameters:nil
                                                              formParameters:formParameters
                                                                accessToken:self.accessToken];
    [NSURLConnection sendAsynchronousRequest:receiveShare
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSArray *items = nil;
        CFSError *error = nil;
        if ([self isResponeSucessful:response data:data]) {
            items = [self getShareItemsArrayFrom:(NSArray *)[self resultDictionaryFromResponseData:data] withParentPath:path withShareKey:shareKey];
        } else {
            error = [CFSErrorUtil createErrorFrom:data response:response error:connectionError];
        }
                               
        completion(items, error);
    }];
}

- (void)browseShare:(NSString *)shareKey
          container:(CFSContainer *)container
         completion:(void (^)(NSArray *items, CFSError *error))completion
{
    NSAssert(shareKey.length != 0, CFSAssertShareZeroLengthMessage);
    NSAssert(![container isEqual:[NSNull null]], CFSAssertFolderWrongTypeMessage);
    
    NSString *browseShareEndPoint;
    if (container && ![container.path isEqualToString:@"/"]) {
       browseShareEndPoint = [[NSString alloc] initWithFormat:@"%@%@%@%@", CFSRestAPIEndpointShares, shareKey, container.path, CFSRestAPIEndpointMeta];
    } else {
        browseShareEndPoint = [[NSString alloc] initWithFormat:@"%@%@%@", CFSRestAPIEndpointShares, shareKey, CFSRestAPIEndpointMeta];
    }
    
    NSURLRequest *browseShare = [CFSURLRequestBuilder urlRequestForHttpMethod:CFSRestHTTPMethodGET
                                                                      serverUrl:self.serverUrl
                                                                     apiVersion:CFSRestApiVersion
                                                                       endpoint:browseShareEndPoint
                                                                queryParameters:nil formParameters:nil
                                                                    accessToken:self.accessToken];
    [NSURLConnection sendAsynchronousRequest:browseShare
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSArray *items = nil;
        CFSError *error = nil;
        if ([self isResponeSucessful:response data:data]) {
            NSDictionary *result = [self resultDictionaryFromResponseData:data];
            items = [self getShareItemsArrayFrom:result[@"items"] withContainer:container withShareKey:shareKey];
        } else {
            error = [CFSErrorUtil createErrorFrom:data response:response error:connectionError];
        }
                               
        completion(items, error);
    }];
}

- (void)deleteShare:(NSString *)shareKey
         completion:(void (^)(BOOL success, CFSError *error))completion
{
    NSAssert(shareKey.length != 0, CFSAssertShareZeroLengthMessage);
    
    NSString *deleteShareEndPoint = [NSString stringWithFormat:@"%@%@/", CFSRestAPIEndpointShares,shareKey];
    NSURLRequest *deleteShare = [CFSURLRequestBuilder urlRequestForHttpMethod:CFSRestHTTPMethodDELETE
                                                                      serverUrl:self.serverUrl
                                                                     apiVersion:CFSRestApiVersion
                                                                       endpoint:deleteShareEndPoint
                                                                queryParameters:nil
                                                                 formParameters:nil
                                                                    accessToken:self.accessToken];
    [NSURLConnection sendAsynchronousRequest:deleteShare
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        CFSError *error = nil;
        BOOL success = [self isResponeSucessful:response data:data];
        if (!success) {
           error = [CFSErrorUtil createErrorFrom:data response:response error:connectionError];
        }
                               
        completion(success, error);
    }];
}

- (void)createShare:(NSArray *)paths
           password:(NSString *)password
         completion:(void (^)(CFSShare *share, CFSError *error))completion
{
    NSAssert(paths.count != 0, CFSAssertPathZeroLengthMessage);
    
    NSMutableArray *createShareFormParams = [NSMutableArray array];
    
    for (NSString *path in paths) {
        [createShareFormParams addObject:@{CFSFormParameterPathKey : path}];
    }
    
    if (password) {
        [createShareFormParams addObject:@{CFSFormParameterPasswordKey : password}];
    }
    
    NSURLRequest *createShare = [CFSURLRequestBuilder urlRequestForHttpMethod:CFSRestHTTPMethodPOST
                                                                      serverUrl:self.serverUrl
                                                                     apiVersion:CFSRestApiVersion
                                                                       endpoint:CFSRestAPIEndpointShares
                                                                queryParameters:nil
                                                                 formParameters:createShareFormParams
                                                                    accessToken:self.accessToken];
   [NSURLConnection sendAsynchronousRequest:createShare
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        CFSShare *share = nil;
        CFSError *error = nil;
        if ([self isResponeSucessful:response data:data]) {
            NSDictionary *result = [self resultDictionaryFromResponseData:data];
            share = [[CFSShare alloc] initWithDictionary:result andRestAdapter:self];
        } else {
            error = [CFSErrorUtil createErrorFrom:data response:response error:connectionError];
        }

        completion(share, error);
    }];
}

- (void)setShareName:(NSString *)name
usingCurrentPassword:(NSString *)currentPassword
        withShareKey:(NSString *)shareKey
          completion:(void (^)(BOOL success, CFSShare *share, CFSError *error))completion
{
    NSAssert(shareKey.length != 0, CFSAssertShareZeroLengthMessage);
    
    NSMutableDictionary *alterShareFormParams = [NSMutableDictionary dictionary];
    if (currentPassword) {
        [alterShareFormParams setValue:currentPassword forKey:CFSFormParameterCurrentPasswordKey];
    }
    
    if (name) {
        [alterShareFormParams setValue:name forKey:CFSFormParameterNameKey];
    }

    NSString *alterShareEndpoint = [NSString stringWithFormat:@"%@%@%@",
                                    CFSRestAPIEndpointShares,
                                    shareKey,
                                    CFSRestAPIEndpointInfo];
    NSURLRequest *alterShare = [CFSURLRequestBuilder urlRequestForHttpMethod:CFSRestHTTPMethodPOST
                                                                     serverUrl:self.serverUrl
                                                                    apiVersion:CFSRestApiVersion
                                                                      endpoint:alterShareEndpoint
                                                               queryParameters:nil
                                                                formParameters:alterShareFormParams
                                                                   accessToken:self.accessToken];
    [NSURLConnection sendAsynchronousRequest:alterShare
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        CFSShare *share = nil;
        CFSError *error = nil;
        BOOL success = [self isResponeSucessful:response data:data];
        if (success) {
            share = [[CFSShare alloc] initWithDictionary:[self resultDictionaryFromResponseData:data] andRestAdapter:self];
        } else {
            error = [CFSErrorUtil createErrorFrom:data response:response error:connectionError];
        }
                               
        completion(success, share, error);
     }];
}

- (CFSShare *)setShareName:(NSString *)name
      usingCurrentPassword:(NSString *)currentPassword
              withShareKey:(NSString *)shareKey
                     error:(CFSError **)error
{
    NSAssert(shareKey.length != 0, CFSAssertShareZeroLengthMessage);
    
    NSMutableDictionary *alterShareFormParams = [NSMutableDictionary dictionary];
    if (currentPassword) {
        [alterShareFormParams setValue:currentPassword forKey:CFSFormParameterCurrentPasswordKey];
    }
    
    if (name) {
        [alterShareFormParams setValue:name forKey:CFSFormParameterNameKey];
    }
    
    NSString *alterShareEndpoint = [NSString stringWithFormat:@"%@%@%@",
                                    CFSRestAPIEndpointShares,
                                    shareKey,
                                    CFSRestAPIEndpointInfo];
    NSURLRequest *alterShare = [CFSURLRequestBuilder urlRequestForHttpMethod:CFSRestHTTPMethodPOST
                                                                     serverUrl:self.serverUrl
                                                                    apiVersion:CFSRestApiVersion
                                                                      endpoint:alterShareEndpoint
                                                               queryParameters:nil
                                                                formParameters:alterShareFormParams
                                                                   accessToken:self.accessToken];
    NSError *conError = nil;
    NSHTTPURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:alterShare returningResponse:&response error:&conError];
    *error = nil;
    CFSShare *share = nil;
    if (![self isResponeSucessful:response data:data]) {
        *error = [CFSErrorUtil createErrorFrom:data response:response error:conError];
    } else {
        share = [[CFSShare alloc] initWithDictionary:[self resultDictionaryFromResponseData:data] andRestAdapter:self];
    }
    
    return share;
}

- (void)setSharePasswordTo:(NSString *)newPassword
                      from:(NSString *)oldPassword
              withShareKey:(NSString *)shareKey
                completion:(void (^)(BOOL success, CFSError *error))completion
{
    NSAssert(shareKey.length != 0, CFSAssertShareZeroLengthMessage);
    
    NSMutableDictionary *alterShareFormParams = [NSMutableDictionary dictionary];
    if (oldPassword) {
        [alterShareFormParams setValue:oldPassword forKey:CFSFormParameterOldPasswordKey];
    }
    
    if (newPassword) {
        [alterShareFormParams setValue:newPassword forKey:CFSFormParameterPasswordKey];
    }
    
    NSString *alterShareEndpoint = [NSString stringWithFormat:@"%@%@%@",
                                    CFSRestAPIEndpointShares,
                                    shareKey,
                                    CFSRestAPIEndpointInfo];
    NSURLRequest *alterShare = [CFSURLRequestBuilder urlRequestForHttpMethod:CFSRestHTTPMethodPOST
                                                                     serverUrl:self.serverUrl
                                                                    apiVersion:CFSRestApiVersion
                                                                      endpoint:alterShareEndpoint
                                                               queryParameters:nil
                                                                formParameters:alterShareFormParams
                                                                   accessToken:self.accessToken];
    [NSURLConnection sendAsynchronousRequest:alterShare
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        BOOL success = [self isResponeSucessful:response data:data];
        CFSError *error = nil;
        if (!success) {
           error =  [CFSErrorUtil createErrorFrom:data response:response error:connectionError];
        }
                               
        completion(success, error);
     }];
}

- (void)unlockShare:(NSString *)shareKey password:(NSString *)password completion:(void (^)(BOOL success, CFSError *error))completion
{
    NSAssert(shareKey.length != 0, CFSAssertShareZeroLengthMessage);
    NSAssert(password.length != 0, CFSAssertPasswordZeroLengthMessage);
    
    NSString *unlockShareEndPoint = [NSString stringWithFormat:@"%@%@%@",
                                     CFSRestAPIEndpointShares,
                                     shareKey,
                                     CFSRestAPIEndpointUnlock];
    NSMutableDictionary *unlockShareFormParams = [NSMutableDictionary dictionaryWithObject:password forKey:CFSFormParameterPasswordKey];
    NSURLRequest *unlockShare = [CFSURLRequestBuilder urlRequestForHttpMethod:CFSRestHTTPMethodPOST
                                                                      serverUrl:self.serverUrl
                                                                     apiVersion:CFSRestApiVersion
                                                                       endpoint:unlockShareEndPoint
                                                                queryParameters:nil
                                                                 formParameters:unlockShareFormParams
                                                                    accessToken:self.accessToken];
    [NSURLConnection sendAsynchronousRequest:unlockShare
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        CFSError *error = nil;
        BOOL success = [self isResponeSucessful:response data:data];
        if (!success) {
           error = [CFSErrorUtil createErrorFrom:data response:response error:connectionError];
        }
                               
        completion(success, error);
     }];
}

#pragma mark - Create new directory
- (void)createFolderInContainer:(NSString *)path
                     whenExists:(CFSItemExistsOperation)operation
                       withName:(NSString *)name
                     completion:(void (^)(NSDictionary *newFolderDict, CFSError *error))completion
{
    NSAssert(path.length != 0, CFSAssertPathZeroLengthMessage);
    NSAssert(name.length != 0, CFSAssertNameZeroLengthMessage);
    
    NSString *exists = [self itemExistsOperationToString:operation];
    if (!exists) {
        exists = CFSOperationExistsFail;
    }
    
    NSString *createFolderEndpoint = [NSString stringWithFormat:@"%@%@", CFSRestApiEndpointFolders, path];
    NSDictionary *createFolderQueryParams = @{CFSQueryParameterOperation : CFSQueryParameterOperationCreate};
    NSMutableDictionary *createFolderFormParams = [NSMutableDictionary dictionary];
    [createFolderFormParams setValue:name forKey:CFSFormParameterNameKey];
    [createFolderFormParams setValue:exists forKey:CFSFormParameterExistsKey];
    NSURLRequest *createFolderRequest = [CFSURLRequestBuilder urlRequestForHttpMethod:CFSRestHTTPMethodPOST
                                                                              serverUrl:self.serverUrl
                                                                             apiVersion:CFSRestApiVersion
                                                                               endpoint:createFolderEndpoint
                                                                        queryParameters:createFolderQueryParams
                                                                         formParameters:createFolderFormParams
                                                                            accessToken:self.accessToken];
    [NSURLConnection sendAsynchronousRequest:createFolderRequest
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         if ([self isResponeSucessful:response data:data]) {
             NSArray *itemDicts = [self itemDictsFromResponseData:data];
             completion([itemDicts firstObject], nil);
         } else {
             completion(nil, [CFSErrorUtil createErrorFrom:data response:response error:connectionError]);
         }
     }];
}

#pragma mark - Downloads
- (void)downloadFile:(CFSFile *)file
                  to:(NSString *)localDestinationPath
            progress:(CFSFileTransferProgress)progress
          completion:(CFSFileTransferCompletion)completion
{
    NSString *fullPath = [localDestinationPath stringByAppendingPathComponent:file.name];
    
    NSString *fileEndpoint = [NSString stringWithFormat:@"%@%@", CFSRestApiEndpointFiles, file.path];
    
    NSURLRequest *downloadFileRequest = [CFSURLRequestBuilder urlRequestForHttpMethod:CFSRestHTTPMethodGET
                                                                            serverUrl:self.serverUrl
                                                                           apiVersion:CFSRestApiVersion
                                                                             endpoint:fileEndpoint
                                                                      queryParameters:nil
                                                                       formParameters:nil
                                                                          accessToken:self.accessToken];
    
    NSURLSessionDownloadTask *downloadTask = [self.transferManager.foregroundURLSession downloadTaskWithRequest:downloadFileRequest];

    [self.transferManager addTransferForDownloadTask:downloadTask
                                                path:fullPath
                                                file:file
                                            progress:progress
                                          completion:completion];
    [downloadTask resume];
}

- (void)downloadUrlOfFile:(CFSFile *)file completion:(void (^)(NSString *downloadurl))completion
{
    NSString *fileEndpoint = [NSString stringWithFormat:@"%@%@", CFSRestApiEndpointFiles, file.path];
    
    NSURLRequest *downloadFileRequest = [CFSURLRequestBuilder urlRequestForHttpMethod:CFSRestHTTPMethodGET
                                                                            serverUrl:self.serverUrl
                                                                           apiVersion:CFSRestApiVersion
                                                                             endpoint:fileEndpoint
                                                                      queryParameters:nil
                                                                       formParameters:nil
                                                                          accessToken:self.accessToken];
    
    NSURLSessionDownloadTask *downloadTask = [self.transferManager.foregroundURLSession downloadTaskWithRequest:downloadFileRequest];
    
    [self.transferManager addTransferForDownloadTask:downloadTask
                                                path:nil
                                                file:file
                                            progress:nil
                                          completion:nil
                                            redirect:^void(NSInteger transferId, NSString *path, NSURLResponse *response, BOOL *proceed) {
                                                NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
                                                NSString *location = headers[CFSHeaderLocation];
                                                *proceed = NO;
                                                completion(location);
    }];
    
    [downloadTask resume];
}

- (void)inputStreamOfFile:(CFSFile *)file completion:(void (^)(NSInputStream *))completion
{
    [self downloadUrlOfFile:file completion:^(NSString *downloadUrl) {
        NSURL *url = [NSURL URLWithString:downloadUrl];
        
        if (!url) {
            completion(nil);
        }
        
        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;

        CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)[url host], 80, &readStream, &writeStream);
        
        NSInputStream *inputStream = (__bridge_transfer NSInputStream *)readStream;
        
        completion(inputStream);
    }];
}

#pragma mark - Uploads
- (void)uploadFile:(NSString *)sourcePath
                to:(CFSContainer *)destContainer
          progress:(CFSFileTransferProgress)progress
        completion:(CFSFileTransferCompletion)completion
        whenExists:(CFSExistsOperation)operation
{
    NSString *exists = [self existsOperationToString:operation];
    if (!exists) {
        exists = CFSOperationExistsFail;
    }
    
    NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:sourcePath];
    [self uploadStream:inputStream
          withFileName:[sourcePath lastPathComponent]
                    to:destContainer
                  size:[[NSFileManager defaultManager] attributesOfItemAtPath:sourcePath error:nil].fileSize
              progress:progress
            completion:completion
            whenExists:operation];
}

- (void)uploadStream:(NSInputStream *)stream
        withFileName:(NSString *)fileName
                  to:(CFSContainer *)destContainer
                size:(int64_t)size
            progress:(CFSFileTransferProgress)progress
          completion:(CFSFileTransferCompletion)completion
          whenExists:(CFSExistsOperation)operation
{
    NSString *exists = [self existsOperationToString:operation];
    if (!exists) {
        exists = CFSOperationExistsFail;
    }
    
    NSString *destPath = [NSString stringWithFormat:@"%@%@", CFSRestApiEndpointFiles, destContainer.path];
    
    CFSInputStream *formStream = [CFSInputStream inputStreamWithFilename:fileName inputStream:stream whenExists:exists];
    NSURLRequest *uploadFileRequest = [CFSURLRequestBuilder urlRequestWithMultipartForHttpMethod:CFSRestHTTPMethodPOST
                                                                                       serverUrl:self.serverUrl
                                                                                      apiVersion:CFSRestApiVersion
                                                                                        endpoint:destPath
                                                                                 queryParameters:nil
                                                                                     inputStream:formStream
                                                                                     accessToken:self.accessToken];
    
    NSURLSessionUploadTask *uploadTask = [self.transferManager.foregroundURLSession uploadTaskWithStreamedRequest:uploadFileRequest];
    NSString *path = [NSString stringWithFormat:@"%@%@", destPath, fileName];
    [self.transferManager addTransferForUploadTask:uploadTask
                                              path:path
                                              size:size destContainer:destContainer
                                          progress:progress
                                        completion:completion];
    [uploadTask resume];
}

#pragma mark - Helpers
- (NSDictionary *)resultDictionaryFromResponseData:(NSData *)data
{
    NSError *error;
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&error];
    NSDictionary *resultDict = responseDict[@"result"];
    return resultDict;
}

#pragma mark - History
- (void)getActionHistoryWIthStartVersion:(NSInteger)startVersion
                             stopVersion:(NSInteger)stopVersion
                              completion:(void (^)(NSDictionary * history, CFSError *error))completion
{
    NSAssert(startVersion !=0 , @"Start version should not be 0");
    
    NSMutableDictionary *historyQueryParams=[NSMutableDictionary dictionary];
    historyQueryParams[CFSQueryParameterHistoryStart] = [@(startVersion) stringValue];
    if (stopVersion !=0) {
        historyQueryParams[CFSQueryParameterHistoryStop] = @(stopVersion).stringValue;
    }
    
    NSURLRequest *historyRequest = [CFSURLRequestBuilder urlRequestForHttpMethod:CFSHTTPMethodGET
                                                                       serverUrl:self.serverUrl
                                                                      apiVersion:CFSRestApiVersion
                                                                        endpoint:CFSAPIEndpointHistory
                                                                 queryParameters:historyQueryParams
                                                                  formParameters:nil
                                                                     accessToken:self.accessToken];
    [NSURLConnection sendAsynchronousRequest:historyRequest
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               NSDictionary* historyDictionary =nil;
                               CFSError *error = nil;
                               if ([self isResponeSucessful:response data:data]) {
                                   historyDictionary = [self resultDictionaryFromResponseData:data];
                               } else {
                                   error = [CFSErrorUtil createErrorFrom:data response:response error:connectionError];
                               }
                               completion(historyDictionary, error);
                           }];
}

#pragma mark - Admin
- (void)createAccountWithUsername:(NSString *)username
                         password:(NSString *)password
                            email:(NSString *)email
                        firstName:(NSString *)firstName
                         lastName:(NSString *)lastName
                       completion:(void (^)(NSDictionary * userDetails, CFSError *error))completion
{
    NSParameterAssert(self.adminId);
    NSParameterAssert(self.adminSecret);
    NSAssert(username.length != 0, @"Username should not be empty");
    NSAssert(password.length != 0, @"Password should not be empty");
    
    NSMutableDictionary *formParams = [[NSMutableDictionary alloc] init];
    formParams[CFSFormParameterCreateAccountUserKey] = username;
    formParams[CFSFormParameterCreateAccountPasswordKey] = password;
    if (email.length) {
        formParams[CFSFormParameterCreateAccountEmailKey] = email;
    }
    
    if (firstName.length) {
        formParams[CFSFormParameterCreateAccountFirstNameKey] = firstName;
    }
    
    if (lastName.length) {
        formParams[CFSFormParameterCreateAccountLastNameKey] = lastName;
    }
    
    NSURLRequest *createAccountRequest = [CFSURLRequestBuilder signedUrlRequestForHttpMethod:CFSHTTPMethodPOST
                                                                                   serverUrl:self.serverUrl
                                                                                  apiVersion:CFSRestApiVersion
                                                                                    endpoint:CFSAPIEndpointAdminCustomers
                                                                             queryParameters:nil
                                                                              formParameters:formParams
                                                                                    clientId:self.adminId
                                                                                clientSecret:self.adminSecret];
    [NSURLConnection sendAsynchronousRequest:createAccountRequest
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               NSDictionary *userDetails = nil;
                               CFSError *error = nil;
                               if([self isResponeSucessful:response data:data]) {
                                   userDetails = [self resultDictionaryFromResponseData:data];
                               } else {
                                   error = [CFSErrorUtil createErrorFrom:data response:response error:connectionError];
                               }
                               completion(userDetails, error);
                           }];
}

- (void)createPlanWithName:(NSString *)name limit:(NSString *)limit completion:(void (^)(CFSPlan *plan, CFSError *error))completion
{
    NSParameterAssert(self.adminId);
    NSParameterAssert(self.adminSecret);
    NSAssert(name.length != 0, @"Name should not be empty");
    NSAssert(limit.length != 0, @"Limit should not be empty");
    
    NSMutableDictionary *formParams = [[NSMutableDictionary alloc] init];
    formParams[CFSFormParameterPlanName] = name;
    formParams[CFSFormParameterPlanLimit] = limit;
    NSString *planEndPoint = [NSString stringWithFormat:@"%@%@", CFSAPIEndpointCustomers, CFSAPIEndpointPlan];
    NSURLRequest *createPlanRequest = [CFSURLRequestBuilder
                                       signedUrlRequestForHttpMethod:CFSHTTPMethodPOST
                                       serverUrl:self.serverUrl
                                       apiVersion:CFSRestApiVersion
                                       endpoint:planEndPoint
                                       queryParameters:nil
                                       formParameters:formParams
                                       clientId:self.adminId
                                       clientSecret:self.adminSecret];
    
    [NSURLConnection sendAsynchronousRequest:createPlanRequest
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *planDetails = nil;
        CFSError *error = nil;
        CFSPlan *plan = nil;
        if([self isResponeSucessful:response data:data]) {
            planDetails = [self resultDictionaryFromResponseData:data];
            plan = [[CFSPlan alloc] initWithDictionary:planDetails];
            
        } else {
            error = [CFSErrorUtil createErrorFrom:data response:response error:connectionError];
        }

        completion(plan, error);
    }];
}

- (void)listPlansWithCompletion:(void (^)(NSArray *plans, CFSError *error))completion
{
    NSParameterAssert(self.adminId);
    NSParameterAssert(self.adminSecret);
    NSString *planEndPoint = [NSString stringWithFormat:@"%@%@", CFSAPIEndpointCustomers, CFSAPIEndpointPlan];
    NSURLRequest *listPlanRequest = [CFSURLRequestBuilder
                                     signedUrlRequestForHttpMethod:CFSHTTPMethodGET
                                     serverUrl:self.serverUrl
                                     apiVersion:CFSRestApiVersion
                                     endpoint:planEndPoint
                                     queryParameters:nil
                                     formParameters:nil
                                     clientId:self.adminId
                                     clientSecret:self.adminSecret];
    
    [NSURLConnection sendAsynchronousRequest:listPlanRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        CFSError *error = nil;
        NSArray *plansArray = nil;
        if([self isResponeSucessful:response data:data]) {
            plansArray = [self getPlanArray:[self resultArrayFromResponseData:data]];
        } else {
            error = [CFSErrorUtil createErrorFrom:data response:response error:connectionError];
        }
        
        completion(plansArray, error);
    }];
}

- (void)updateUserWithId:(NSString *)userId
                userName:(NSString *)userName
               firstName:(NSString *)firstName
                lastName:(NSString *)lastName
                planCode:(NSString *)plancode
          WithCompletion:(void (^)(CFSUser *user, CFSError *error))completion
{
    NSParameterAssert(self.adminId);
    NSParameterAssert(self.adminSecret);
    NSAssert(userId.length != 0, @"UserId should not be empty");
    NSMutableDictionary *formParams = [[NSMutableDictionary alloc] init];
    
    if (userName.length) {
        formParams[CFSFormParameterCreateAccountUserKey] = userName;
    }
    
    if (plancode.length) {
        formParams[CFSFormParameterPlanCode] = plancode;
    }
    
    if (firstName.length) {
        formParams[CFSFormParameterCreateAccountFirstNameKey] = firstName;
    }
    
    if (lastName.length) {
        formParams[CFSFormParameterCreateAccountLastNameKey] = lastName;
    }
    if (formParams.count == 0) {
        formParams = nil;
    }
    
    NSString *planEndPoint = [NSString stringWithFormat:@"%@%@", CFSAPIEndpointCustomers, userId];
    NSURLRequest *updateUserRequest = [CFSURLRequestBuilder signedUrlRequestForHttpMethod:CFSHTTPMethodPOST
                                                                                serverUrl:self.serverUrl
                                                                               apiVersion:CFSRestApiVersion
                                                                                 endpoint:planEndPoint
                                                                          queryParameters:nil
                                                                           formParameters:formParams
                                                                                 clientId:self.adminId
                                                                             clientSecret:self.adminSecret];
    
    [NSURLConnection sendAsynchronousRequest:updateUserRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *userDetails = nil;
        CFSError *error = nil;
        CFSUser *user = nil;
        if([self isResponeSucessful:response data:data]) {
            userDetails = [self resultDictionaryFromResponseData:data];
            user = [[CFSUser alloc] initWithDictionary:userDetails];
        } else {
            error = [CFSErrorUtil createErrorFrom:data response:response error:connectionError];
        }
        completion(user, error);

    }];

}

- (void)deletePlan:(NSString *)planId completion:(void(^)(BOOL success, CFSError *error))completion
{
    NSParameterAssert(self.adminId);
    NSParameterAssert(self.adminSecret);
    NSAssert(planId.length != 0, @"planId should not be empty");
    NSString *planEndPoint = [NSString stringWithFormat:@"%@%@", CFSAPIEndpointCustomers, CFSAPIEndpointPlan];
    NSString *endPoint = [[planEndPoint stringByAppendingString:planId] stringByAppendingString:@"/"];
    NSURLRequest *deletePlanRequest = [CFSURLRequestBuilder signedUrlRequestForHttpMethod:CFSRestHTTPMethodDELETE
                                                                                serverUrl:self.serverUrl
                                                                               apiVersion:CFSRestApiVersion
                                                                                 endpoint:endPoint
                                                                          queryParameters:nil
                                                                           formParameters:nil
                                                                                 clientId:self.adminId
                                                                             clientSecret:self.adminSecret];
    [NSURLConnection sendAsynchronousRequest:deletePlanRequest
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
           CFSError *error = nil;
           if (![self isResponeSucessful:response data:data]) {
               error = [CFSErrorUtil createErrorFrom:data response:response error:connectionError];
           }
           
           completion([self isResponeSucessful:response data:data], error);
           
       }];
}

#pragma mark - Versions
- (void)getVersionsOfFile:(NSString *)fileUrl
             startVersion:(NSNumber *)startVersion
               endVersion:(NSNumber *)endVersion
                    limit:(NSNumber *)limit
               completion:(void (^)(NSArray *items, CFSError *error))completion
{
    NSMutableDictionary *fileVersionQueryParams = [NSMutableDictionary dictionary];
    if (startVersion) {
        [fileVersionQueryParams setValue:startVersion.stringValue forKey:CFSQueryParameterStartVersionKey];
    }
    
    if (endVersion) {
        [fileVersionQueryParams setValue:endVersion.stringValue forKey:CFSQueryParameterEndVersionKey];
    }
    
    if (limit) {
        [fileVersionQueryParams setValue:limit.stringValue forKey:CFSQueryParameterLimitKey];
    }
    
    NSString *fileVersionsEndPoint = [NSString stringWithFormat:@"%@%@%@",
                                      CFSRestApiEndpointFiles,
                                      fileUrl,
                                      CFSRestApiEndPointVersions];
    NSURLRequest *versionFileRequest = [CFSURLRequestBuilder urlRequestForHttpMethod:CFSRestHTTPMethodGET
                                                                           serverUrl:self.serverUrl
                                                                          apiVersion:CFSRestApiVersion
                                                                            endpoint:fileVersionsEndPoint
                                                                     queryParameters:fileVersionQueryParams
                                                                      formParameters:nil
                                                                         accessToken:self.accessToken];
    [NSURLConnection sendAsynchronousRequest:versionFileRequest
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               CFSError *error = nil;
                               NSArray *items = nil;
                               if ([self isResponeSucessful:response data:data]) {
                                   NSArray *versionsDictionary = (NSArray *)[self resultDictionaryFromResponseData:data];
                                   items = [self getItemsArrayFrom:versionsDictionary withContainer:nil withState:CFSItemStateIsOldVersion];
                               } else {
                                   error = [CFSErrorUtil createErrorFrom:data response:response error:connectionError];
                               }
                               
                               completion(items, error);
                           }];
}

#pragma mark - Meta data
- (void)getMetaDataWithPath:(NSString *)path type:(NSString *)type
          completionHandler:(CFSRestAdapterDictionaryWithErrorCompletion)handler
{
    NSAssert(type.length != 0, CFSAssertTypeZeroLengthMessage);
    
    [self validateItemType:type];
    NSString *metaEndpoint = nil;
    NSString *endPointType = nil;
    if([type isEqual:CFSItemTypeFile]) {
        endPointType = CFSRestApiEndpointFiles;
    } else if([type isEqual:CFSItemTypeFolder]) {
        endPointType = CFSRestApiEndpointFolders;
    } else if([type isEqual:CFSItemTypeFileSystem]) {
        endPointType = CFSAPIEndpointFilesystemAction;
    }
    
    if (path.length > 0) {
        metaEndpoint = [NSString stringWithFormat:@"%@%@%@", endPointType, path, CFSAPIEndpointMeta];
    } else {
        metaEndpoint = [NSString stringWithFormat:@"%@%@", endPointType, CFSAPIEndpointMeta];
    }
    
    NSURLRequest *request = [CFSURLRequestBuilder urlRequestForHttpMethod:CFSRestHTTPMethodGET
                                                                serverUrl:self.serverUrl
                                                               apiVersion:CFSRestApiVersion
                                                                 endpoint:metaEndpoint
                                                          queryParameters:nil
                                                           formParameters:nil
                                                              accessToken:self.accessToken];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               CFSError *error = nil;
                               NSDictionary *meta =nil;
                               if ([self isResponeSucessful:response data:data]) {
                                   meta = [self getMetaDictionary:data];
                               } else {
                                   error = [CFSErrorUtil createErrorFrom:data response:response error:connectionError];
                               }
                               
                               handler(meta, error);
                           }];
}

- (NSDictionary *)getMetaDictionary:(NSData *)data
{
    NSDictionary *resultDictionary = [self resultDictionaryFromResponseData:data];
    if(resultDictionary[@"meta"]) {
        resultDictionary = resultDictionary[@"meta"];
    }
    
    return resultDictionary;
}

- (void)validateItemType:(NSString *)type
{
    NSAssert(([type isEqual:CFSItemTypeFile] ||
              [type isEqual:CFSItemTypeFolder] ||
              [type isEqual:CFSItemTypeFileSystem]),
             CFSAssertTypeWrongMessage);
}

- (void)alterMetaDataAsyncWithPath:(NSString *)path meta:(NSDictionary *)meta
                              type:(NSString *)type
                 completionHandler:(CFSRestAdapterDictionaryWithErrorCompletion)handler
{
    NSURLRequest *request = [self metaDataRequestWithPath:path meta:meta type:type];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               CFSError *error = nil;
                               NSDictionary *meta =nil;
                               if ([self isResponeSucessful:response data:data]) {
                                   if ([type isEqual:CFSItemTypeFile]) {
                                       meta = [self resultDictionaryFromResponseData:data];
                                   } else if([type isEqual:CFSItemTypeFolder]) {
                                       meta = [self metaDictFromResponseData:data];
                                   }
                               } else {
                                   error = [CFSErrorUtil createErrorFrom:data response:response error:connectionError];
                               }
                               
                               handler(meta, error);
                           }];
}

- (NSDictionary *)alterMetaDataSyncWithPath:(NSString *)path
                                       meta:(NSDictionary *)meta
                                       type:(NSString *)type error:(CFSError **)error
{
    NSURLRequest *request = [self metaDataRequestWithPath:path meta:meta type:type];
    NSError *err = nil;
    NSHTTPURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    *error = [CFSErrorUtil createErrorFrom:data response:response error:err];
    NSDictionary *newMeta =nil;
    if ([self isResponeSucessful:response data:data]) {
        if ([type isEqual:CFSItemTypeFile]) {
            newMeta = [self resultDictionaryFromResponseData:data];
        } else if ([type isEqual:CFSItemTypeFolder]) {
            newMeta = [self metaDictFromResponseData:data];
        }
    }
    
    return newMeta;
}

- (NSURLRequest *)metaDataRequestWithPath:(NSString *)path
                                     meta:(NSDictionary *)meta
                                     type:(NSString *)type
{
    NSParameterAssert(meta);
    NSAssert(((NSString *)meta[CFSResponseVersionKey]).length != 0, CFSAssertVersionZeroLengthMessage);
    NSAssert(path.length != 0, CFSAssertPathZeroLengthMessage);
    NSAssert(type.length != 0, CFSAssertTypeZeroLengthMessage);
    
    NSString *metaEndpoint = nil;
    NSString *endPointType = nil;
    if ([type isEqual:CFSItemTypeFile]) {
        endPointType = CFSRestApiEndpointFiles;
    } else if ([type isEqual:CFSItemTypeFolder]) {
        endPointType = CFSRestApiEndpointFolders;
    }
    
    if (path.length>0) {
        metaEndpoint = [NSString stringWithFormat:@"%@%@%@", endPointType, path, CFSAPIEndpointMeta];
    } else {
        metaEndpoint = [NSString stringWithFormat:@"%@%@", endPointType, CFSAPIEndpointMeta];
    }
    
    return [CFSURLRequestBuilder urlRequestForHttpMethod:CFSRestHTTPMethodPOST
                                               serverUrl:self.serverUrl
                                              apiVersion:CFSRestApiVersion
                                                endpoint:metaEndpoint
                                         queryParameters:nil
                                          formParameters:meta accessToken:self.accessToken];
}

#pragma mark - Exists operation
- (NSString *)existsOperationToString:(CFSExistsOperation)operation
{
    NSString *result = nil;
    switch (operation)
    {
        case CFSExistsFail:
            result = CFSOperationExistsFail;
            break;
        case CFSExistsOverwrite:
            result = CFSOperationExistsOverwrite;
            break;
        case CFSExitsRename:
            result = CFSOperationExistsRename;
            break;
        case CFSExistsDefault:
        default:
            result = nil;
            break;
    }
    
    return result;
}

- (NSString *)itemExistsOperationToString:(CFSItemExistsOperation)operation
{
    NSString *result = nil;
    switch (operation)
    {
        case CFSItemExistsFail:
            result = CFSOperationExistsFail;
            break;
        case CFSItemExistsOverwrite:
            result = CFSOperationExistsOverwrite;
            break;
        case CFSItemExistsRename:
            result = CFSOperationExistsRename;
            break;
        case CFSItemExistsReuse:
            result = CFSOperationExistsReuse;
            break;
        case CFSItemExistsDefault:
        default:
            result = nil;
            break;
    }
    
    return result;
}

#pragma mark - Utilities
+ (NSString* )generateSignedRequestString:(NSString *) requestString secret:(NSString *)secret
{
    NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData *requestStrData = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *signedRequestData = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, secretData.bytes, secretData.length, requestStrData.bytes, requestStrData.length, signedRequestData.mutableBytes);
    NSString *signedRequestStr = [signedRequestData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return signedRequestStr;
}

- (BOOL)isResponeSucessful:(NSURLResponse *)response data:(NSData *)data
{
    NSInteger responseStatusCode = [((NSHTTPURLResponse*)response) statusCode];
    return responseStatusCode >= 200 && responseStatusCode < 300 && data ? YES : NO;
}

- (NSArray *)parseListAtContainter:(CFSContainer *)parent
                          response:(NSURLResponse *)response
                              data:(NSData *)data
                             error:(NSError *)connectionError
{
    NSArray *itemsDictArray = [self itemDictsFromResponseData:data];
    return [self getItemsArrayFrom:itemsDictArray withContainer:parent withState:nil];
};

- (NSArray *)getShareItemsArrayFrom:(NSArray *)itemsDictArray withContainer:(CFSContainer *)parent withShareKey:(NSString *)shareKey
{
    return [self getShareItemsArrayFrom:itemsDictArray withParentPath:parent.path withShareKey:shareKey];
}

- (NSArray *)getShareItemsArrayFrom:(NSArray *)itemsDictArray withParentPath:(NSString *)path withShareKey:(NSString *)shareKey
{
    NSMutableArray *itemArray = [NSMutableArray array];
    for (NSDictionary *itemDictionary in itemsDictArray) {
        NSMutableDictionary *itemDict = [NSMutableDictionary dictionaryWithDictionary:itemDictionary];
        itemDict[CFSItemStateIsShare] = @YES;
        itemDict[CFSItemShareKey] = shareKey;
        id item =nil;
        if ([itemDict[@"type"] isEqualToString:CFSItemTypeFolder]) {
            item = [[CFSFolder alloc] initWithDictionary:itemDict andParentPath:path andRestAdapter:self];
        } else {
            item = [[CFSFile alloc] initWithDictionary:itemDict andParentPath:path andRestAdapter:self];
        }
        [itemArray addObject:item];
    }
    
    return itemArray;
}

- (NSArray *)getItemsArrayFrom:(NSArray *)itemsDictArray withContainer:(CFSContainer *)parent withState:(NSString *)state
{
    return [self getItemsArrayFrom:itemsDictArray withParentPath:parent.path withState:state];
}

- (NSArray *)getPlanArray:(NSArray *)plansArray
{
    NSMutableArray *newPlanArray = [NSMutableArray array];
    for (NSDictionary *planDictionary in plansArray) {
        CFSPlan *plan = [[CFSPlan alloc] initWithDictionary:planDictionary];
        [newPlanArray addObject:plan];
    }
    
    return newPlanArray;
}

- (NSArray *)getItemsArrayFrom:(NSArray *)itemsDictArray withParentPath:(NSString *)parentPath withState:(NSString *)state
{
    NSMutableArray *itemArray = [NSMutableArray array];
    for (NSDictionary *itemDictionary in itemsDictArray) {
        NSMutableDictionary *itemDict = [NSMutableDictionary dictionaryWithDictionary:itemDictionary];
        if ([state isEqual:CFSItemStateIsShare]) {
            itemDict[CFSItemStateIsShare] = @YES;
        }
        
        if ([state isEqual:CFSItemStateIsTrash]) {
            itemDict[CFSItemStateIsTrash] = @YES;
        }
        
        if ([state isEqual:CFSItemStateIsOldVersion]) {
            itemDict[CFSItemStateIsOldVersion] = @YES;
        }
        
        id item = nil;
        if ([itemDict[@"type"] isEqualToString:CFSItemTypeFolder]) {
            item = [[CFSFolder alloc] initWithDictionary:itemDict andParentPath:parentPath andRestAdapter:self];
        } else {
            item = [[CFSFile alloc] initWithDictionary:itemDict andParentPath:parentPath andRestAdapter:self];
        }
        [itemArray addObject:item];
    }
    
    return itemArray;
}

- (NSArray *)parseListOfSharesWithResponse:(NSURLResponse *)response
                                      data:(NSData *)data
                                     error:(NSError *)connectionError
{
    NSMutableArray *sharesArray = [NSMutableArray array];
    NSArray *sharesDictArray = [self resultArrayFromResponseData:data];
    for (NSDictionary *shareDict in sharesDictArray) {
        CFSShare *share = [[CFSShare alloc] initWithDictionary:shareDict andRestAdapter:self];
        [sharesArray addObject: share];
    }
 
    return sharesArray;
}

- (NSArray *)resultArrayFromResponseData:(NSData *)data
{
    NSError *error;
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&error];
    NSArray *resultArray = responseDict[@"result"];
    return resultArray;
}

- (NSArray *)itemDictsFromResponseData:(NSData *)data
{
    NSDictionary *resultDict = [self resultDictionaryFromResponseData:data];
    NSArray *itemsDictArray = resultDict[@"items"];
    return itemsDictArray;
}

- (NSDictionary *)metaDictFromResponseData:(NSData *)data
{
    NSDictionary *resultDict = [self resultDictionaryFromResponseData:data];
    NSDictionary *meta = resultDict[@"meta"];
    return meta;
}

+ (NSDateFormatter *)getDateFormatter
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [dateFormatter setDateFormat:@"EEE', 'd' 'MMM' 'yyyy' 'hh':'mm':'ss' 'zzz"];
    [dateFormatter setLocale:locale];
    return dateFormatter;
}
@end
