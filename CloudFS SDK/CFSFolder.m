//
//  CFSFolder.m
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

#import "CFSFolder.h"
#import "CFSRestAdapter.h"
#import "CFSErrorUtil.h"

@class CFSError;

@interface CFSFolder ()

@property (nonatomic, retain, readwrite) NSString *path;
@property (nonatomic, retain, readwrite) NSString *itemId;
@property (nonatomic, retain, readwrite) NSString *type;
@property (nonatomic, retain, readwrite) NSString *parentId;
@property (nonatomic, readwrite) int64_t version;
@property (nonatomic, retain, readwrite) NSDate *dateContentLastModified;
@property (nonatomic, retain, readwrite) NSDate *dateMetaLastModified;
@property (nonatomic, retain, readwrite) NSDate *dateCreated;
@property (nonatomic, readwrite) BOOL isMirrored;
@property (nonatomic, readwrite, getter = getAppdata, setter=setAppdata:) NSString *applicationData;
@property (nonatomic, readwrite, setter = setItemName:) NSString *name;

@end

@implementation CFSFolder

@dynamic path;
@dynamic itemId;
@dynamic type;
@dynamic parentId;
@dynamic version;
@dynamic dateContentLastModified;
@dynamic dateMetaLastModified;
@dynamic dateCreated;
@dynamic isMirrored;
@dynamic name;
@dynamic applicationData;

#pragma mark - create folder

- (void)createFolder:(NSString *)name
          whenExists:(CFSItemExistsOperation)exists
          completion:(void (^)(CFSFolder *newDir, CFSError *error))completion
{
    if (![self validateOperation:CFSOperationCreateFolder]) {
        completion(nil ,[CFSErrorUtil errorWithMessage:CFSOperationNotAllowedError]);
    }
    
    [_restAdapter createFolderInContainer:self.path
                               whenExists:exists
                                 withName:name
                               completion:^(NSDictionary *newContainerDict, CFSError *error) {
         if (newContainerDict == nil) {
             completion(nil, error);
         } else {
             CFSFolder *newDir = [[CFSFolder alloc] initWithDictionary:newContainerDict
                                                    andParentContainer:self
                                                        andRestAdapter:_restAdapter];
             completion(newDir, error);
         }
     }];
}

- (void)upload:(NSString *)fileSystemPath
      progress:(CFSFileTransferProgress)progress
    completion:(CFSFileTransferCompletion)completion
    whenExists:(CFSExistsOperation)exists
{
    if (![self validateOperation:CFSOperationUpload]) {
        completion(0 ,nil ,nil ,[CFSErrorUtil errorWithMessage:CFSOperationNotAllowedError]);
    }
    
    [_restAdapter uploadFile:fileSystemPath to:self progress:progress completion:completion whenExists:CFSExistsOverwrite];
}

- (BOOL)changeAttributes:(NSDictionary *)values ifConflict:(VersionExists)ifConflict
{
    return [super changeAttributes:values ifConflict:ifConflict];
}

- (BOOL)setApplicationData:(NSDictionary *)applicationData
{
    return [super setApplicationData:applicationData];
}

- (BOOL)setName:(NSString *)name
{
    return [super setName:name];
}

- (void)setItemAttributes:(NSDictionary *)values
{
    self.name = values[CFSResponseNameKey];
    self.dateContentLastModified = [NSDate dateWithTimeIntervalSince1970:[values[CFSResponseDateContentLastModifiedKey] doubleValue]];
    self.dateCreated = [NSDate dateWithTimeIntervalSince1970:[values[CFSResponseDateCreatedKey] doubleValue]];
    self.version = [values[CFSResponseVersionKey] integerValue];
    self.applicationData = values[CFSResponseApplicationDataKey];
    self.dateMetaLastModified = [NSDate dateWithTimeIntervalSince1970:[values[CFSResponseDateMetaLastModifiedKey] doubleValue]];
    self.parentId = values[CFSResponseParentIdKey];
    self.isMirrored = [values[CFSResponseIsMirroredKey] boolValue];
    self.type = values[CFSResponseTypeKey];
}

@end
