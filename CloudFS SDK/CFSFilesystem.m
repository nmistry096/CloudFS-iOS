//
//  CFSFilesystem.m
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

#import "CFSFilesystem.h"
#import "CFSContainer.h"
#import "CFSItem.h"
#import "CFSRestAdapter.h"
#import "CFSShare.h"
#import "CFSFile.h"
#import "CFSFolder.h"

@implementation CFSFilesystem

@class CFSError;

CFSRestAdapter* _restAdapter;

- (instancetype)initWithRestAdapter:(CFSRestAdapter *)restAdapter
{
    self = [super init];
    _restAdapter =  restAdapter;
    return self;
}

- (void)rootWithCompletion:(void (^)(CFSFolder *root, CFSError *error))completion
{
    [_restAdapter getMetaDataWithPath:nil type:CFSItemTypeFolder completionHandler:^(NSDictionary *dict, CFSError *error) {
        CFSFolder *root = [[CFSFolder alloc] initWithDictionary:dict andParentPath:@"/" andRestAdapter:_restAdapter];
        completion(root,error);
    }];
}

- (void)getItem:(NSString *)path
     completion:(void (^)(CFSItem *item, CFSError *error))completion{
   
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
    } else{
        parentPath =@"";
    }
    
    [_restAdapter getMetaDataWithPath:path type:CFSItemTypeFileSystem completionHandler:^(NSDictionary *dict, CFSError *error) {
        id item;
        if ([dict[@"type"] isEqualToString:CFSItemTypeFolder]) {
            item = [[CFSFolder alloc] initWithDictionary:dict andParentPath:parentPath andRestAdapter:_restAdapter];
        } else {
            item = [[CFSFile alloc] initWithDictionary:dict andParentPath:parentPath andRestAdapter:_restAdapter];
        }
        completion(item,error);
    }];
}

#pragma mark - list trash
- (void)listTrashWithCompletion:(void (^)(NSArray *items, CFSError *error))completion
{
    [_restAdapter getContentsOfTrashWithPath:nil completion:completion];
}


#pragma mark - shares
- (void)listSharesWithCompletion:(void (^)(NSArray *shares, CFSError *error))completion
{
    [_restAdapter listSharesWithCompletion:completion];
}

- (void)createShare:(NSArray *)paths
           password:(NSString *)password
         completion:(void (^)(CFSShare *share, CFSError *error))completion
{
    [_restAdapter createShare:paths password:password completion:completion];
}

- (void)retrieveShare:(NSString *)shareKey
             password:(NSString *)password
           completion:(void (^)(CFSShare *share, CFSError *error))completion
{
    CFSShare *share = [[CFSShare alloc] initWithDictionary:@{CFSShareResponseResultShareKey:shareKey} andRestAdapter:_restAdapter];    
    if (password) {
        [share unlockShareWithPassword:password completion:^(BOOL success, CFSError *error) {
            completion(success ? share : nil, error);
        }];
    } else {
        completion(share, nil);
    }
}

@end
