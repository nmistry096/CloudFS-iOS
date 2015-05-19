//
//  CFSSession.m
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

#import "CFSSession.h"
#import "CFSRestAdapter.h"
#import "CFSUser.h"
#import "CFSAccount.h"
#import "CFSFilesystem.h"

NSInteger const CFSActionHistoryDefaultStartVersion = -10;

@interface CFSSession ()
@end

static CFSSession *_sharedSession = nil;

@implementation CFSSession


- (instancetype)initWithEndPoint:(NSString *)endPoint
               clientId:(NSString *)clientId
           clientSecret:(NSString *)clientSecret
{
    self = [super init];
    if (self) {
        self.restAdapter = [[CFSRestAdapter alloc] initWithServerUrl:endPoint clientId:clientId clientSecret:clientSecret];
        
        _sharedSession = self;
    }
    return self;
}


- (void)authenticateWithUsername:(NSString *)username
                     andPassword:(NSString *)password
                      completion:(void (^)(NSString *token, BOOL success , CFSError *error))completion
{
    [self.restAdapter authenticateWithEmail:username password:password completionHandler:^(NSString *token, CFSError *error) {
        if (error) {
            completion(nil, NO, error);
        } else {
            [_restAdapter  setAccessToken:token];
            [self.restAdapter getProfileWithCompletion:^(NSDictionary *dictionary){
                if (dictionary) {
                    self.user = [[CFSUser alloc] initWithDictionary:dictionary];
                    self.account = [[CFSAccount alloc] initWithDictionary:dictionary];
                    self.fileSystem = [[CFSFilesystem alloc] initWithRestAdapter:self.restAdapter];
                }
                completion(token, (dictionary ? YES : NO), error);
            }];
        }
    }];
}

- (void)unlink
{
    [_restAdapter setAccessToken:@""];
    self.account = nil;
    self.user = nil;
    self.fileSystem = nil;
}

- (BOOL)isLinked
{
    return (_restAdapter.accessToken && ![_restAdapter.accessToken isEqualToString:@""]);
}

- (CFSAccount *)account
{
    return self.isLinked ? _account : nil;
}

- (CFSUser *)user
{
    return self.isLinked ? _user : nil;
}

- (CFSFilesystem *)fileSystem
{
    return self.isLinked ? _fileSystem : nil;
}

-(void)actionHistoryWithCompletion:(void (^)(NSDictionary *history, CFSError *error))completion
{
     NSInteger startVersion  = CFSActionHistoryDefaultStartVersion;
     NSInteger stopVersion = 0;
     [self.restAdapter getActionHistoryWIthStartVersion:startVersion
                                            stopVersion:stopVersion
                                             completion:^(NSDictionary *history, CFSError *error){
         self.history = history;
         completion(history, error);
     }];
}

-(void)actionHistoryWithStartVersion:(NSInteger)startVersion
                      andStopVersion:(NSInteger)stopVersion
                      completion:(void (^)(NSDictionary *history, CFSError *error))completion
{
    if (startVersion == 0) {
        startVersion = CFSActionHistoryDefaultStartVersion;
    }
    
    [self.restAdapter getActionHistoryWIthStartVersion:startVersion
                                           stopVersion:stopVersion
                                            completion:^(NSDictionary *history, CFSError *error){
         self.history = history;
         completion(history, error);
     }];
}

-(void)setAdminCredentialsWithAdminClientId:(NSString *)adminClientId
                          adminClientSecret:(NSString *)adminClientSecret
{
    [_restAdapter setAdminCredentialsWithAdminClientId:adminClientId adminClientSecret:adminClientSecret];
}

-(void)createAccountWithUsername:(NSString *)username
                       password:(NSString *)password
                           email:(NSString *)email
                       firstName:(NSString *)firstName
                        lastName:(NSString *)lastName
              logInTocreatedUser:(BOOL)logInTocreatedUser
                  WithCompletion:(void (^)(CFSUser *user, CFSError *error))completion
{
    [self.restAdapter createAccountWithUsername:username
                                       password:password
                                          email:email
                                      firstName:firstName
                                       lastName:lastName
                                     completion:^(NSDictionary *userDetails, CFSError *error) {
         
         CFSUser *user;
         if (userDetails && !error) {
             user = [[CFSUser alloc] initWithDictionary:userDetails];
             if (logInTocreatedUser) {
                 [self authenticateWithUsername:username andPassword:password completion:^(NSString* token, BOOL success, CFSError *error) {
                     completion(user, error);
                 }];
             } else {
                 completion(user, error);
             }
         } else {
             completion(user, error);
         }
    }];
}

@end