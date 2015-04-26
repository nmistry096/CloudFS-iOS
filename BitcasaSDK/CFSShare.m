//
//  CFSShare.m
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

#import "CFSShare.h"
#import "CFSFile.h"
#import "CFSFolder.h"
#import "CFSRestAdapter.h"

@interface CFSShare()

@end

@implementation CFSShare

CFSRestAdapter *_restAdapter;

- (CFSShare *)initWithDictionary:(NSDictionary *)dictionary
                 andRestAdapter:(CFSRestAdapter *)restAdapter;
{
    self = [super init];
    if (self)
    {
        _restAdapter = restAdapter;
        _shareKey = dictionary[CFSShareResponseResultShareKey];
        _size = dictionary[@"share_size"];
        _name = dictionary[@"share_name"];
        _dateContentLastModified = dictionary[@"single_item"][@"date_content_last_modified"];
        _dateMetaLastModified = dictionary[@"single_item"][@"date_meta_last_modified"];
        _applicationData = dictionary[@"single_item"][@"application_data"];
    }
    
    return self;
}

- (void)listWithCompletion:(void (^)(NSArray *items, CFSError *error))completion
{
    [_restAdapter browseShare:self.shareKey container:nil completion:completion];
}

- (void)setPasswordTo:(NSString *)newPassword
                    from:(NSString *)oldPassword
              completion:(void (^)(BOOL success, CFSError *error))completion
{
    [_restAdapter setSharePasswordTo:newPassword
                                from:oldPassword
                        withShareKey:self.shareKey
                          completion:completion];
}

- (void)deleteWithcompletion:(void (^)(BOOL success, CFSError *error))completion
{
    [_restAdapter deleteShare:self.shareKey completion:completion];
}

- (void)changeAttributes:(NSDictionary *)values
                password:(NSString *)password
              completion:(void (^)(BOOL success, CFSError *error))completion
{
    NSString *name = nil;
    if (values) {
        name = values[@"name"];
    }
    
    [_restAdapter setShareName:name usingCurrentPassword:password withShareKey:self.shareKey completion:^(BOOL success, CFSShare *share, CFSError *error) {
        _name = share.name;
        completion(success, error);
    }];
}

- (void)receiveShare:(NSString *)path whenExists:(CFSExistsOperation)operation completion:(void (^)(NSArray *items, CFSError *error))completion
{
    [_restAdapter receiveShare:self.shareKey path:path whenExists:operation completion:completion];
}

- (void)unlockShare:(NSString *)shareKey password:(NSString *)password completion:(void (^)(BOOL Success, CFSError *error))completion
{
    [_restAdapter unlockShare:shareKey password:(NSString *)password completion:completion];
}

- (BOOL)setName:(NSString *)newName usingCurrentPassword:(NSString *)password
{
    CFSError *error;
    CFSShare *share = [_restAdapter setShareName:newName usingCurrentPassword:password withShareKey:self.shareKey error:&error];
    BOOL success = NO;
    if (!error) {
        _name = share.name;
        success = [newName isEqualToString:_name];
    }
    
    return success;
}

@end
