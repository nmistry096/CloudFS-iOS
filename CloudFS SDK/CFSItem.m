//
//  CFSItem.m
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

#import "CFSItem.h"
#import "CFSContainer.h"
#import "CFSError.h"
#import "CFSRestAdapter.h"
#import "CFSErrorUtil.h"

@interface CFSItem ()

@property (nonatomic, retain, readwrite) NSString *path;
@property (nonatomic, retain, readwrite) NSString *itemId;
@property (nonatomic, retain, readwrite) NSString *type;
@property (nonatomic, retain, readwrite) NSString *parentId;
@property (nonatomic, readwrite) int64_t version;
@property (nonatomic, retain, readwrite) NSDate *dateContentLastModified;
@property (nonatomic, retain, readwrite) NSDate *dateMetaLastModified;
@property (nonatomic, retain, readwrite) NSDate *dateCreated;
@property (nonatomic, readwrite) BOOL isMirrored;
@property (nonatomic, readwrite, setter = setAppdata:) NSDictionary *applicationData;
@property (nonatomic, readwrite, setter = setItemName:) NSString *name;
@property (nonatomic, readwrite) BOOL isTrash;
@property (nonatomic, readwrite) BOOL isShare;
@property (nonatomic, readwrite) BOOL isOldVersion;
@property (nonatomic, readwrite) BOOL isDead;
@property (nonatomic, readwrite) NSDictionary *allowedOPerationList;
@property (nonatomic, readwrite) NSString *shareKey;
@property (nonatomic, retain) NSString *parentPath;

@end

NSString *const CFSResponseNameKey = @"name";
NSString *const CFSResponseItemIdKey = @"id";
NSString *const CFSResponseTypeKey = @"type";
NSString *const CFSResponseParentIdKey = @"parent_id";
NSString *const CFSResponseApplicationDataKey = @"application_data";
NSString *const CFSResponseDateContentLastModifiedKey = @"date_content_last_modified";
NSString *const CFSResponseDateMetaLastModifiedKey = @"date_meta_last_modified";
NSString *const CFSResponseOriginalPath = @"_bitcasa_original_path";
NSString *const CFSResponseDateCreatedKey = @"date_created";
NSString *const CFSResponseIsMirroredKey = @"is_mirrored";
NSString *const CFSResponseVersionKey = @"version";
NSString *const CFSOperationCopy = @"copy";
NSString *const CFSOperationMove = @"move";
NSString *const CFSOperationDelete = @"delete";
NSString *const CFSOperationRestore = @"restore";
NSString *const CFSOperationChangeAttribute = @"change_attributes";
NSString *const CFSOperationCreateFolder = @"create_folder";
NSString *const CFSOperationDownload = @"download";
NSString *const CFSOperationDownloadLink = @"download_link";
NSString *const CFSOperationUpload = @"upload";
NSString *const CFSOperationRead = @"read";
NSString *const CFSOperationList = @"list";
NSString *const CFSOperationVersions = @"versions";
NSString *const CFSOperationNotAllowedError = @"Operation not allowed.";

@implementation CFSItem

@synthesize name = _name;
@synthesize applicationData = _applicationData;

#pragma mark - Initilization

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
      andParentContainer:(CFSContainer *)parent
          andRestAdapter:(CFSRestAdapter *)restAdapter

{
    return [self initWithDictionary:dictionary andParentPath:parent.path andRestAdapter:restAdapter];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
           andParentPath:(NSString *)parentPath
          andRestAdapter:(CFSRestAdapter *)restAdapter
{
    self = [super init];
    if (self) {
        _restAdapter = restAdapter;
        _name = dictionary[CFSResponseNameKey];
        self.parentPath = parentPath;
        self.dateContentLastModified = [NSDate dateWithTimeIntervalSince1970:[dictionary[CFSResponseDateContentLastModifiedKey] doubleValue]];
        self.dateCreated = [NSDate dateWithTimeIntervalSince1970:[dictionary[CFSResponseDateCreatedKey] doubleValue]];
        self.version = [dictionary[CFSResponseVersionKey] integerValue];
        self.parentId = dictionary[CFSResponseParentIdKey];
        _applicationData = dictionary[CFSResponseApplicationDataKey];
        if (parentPath == nil) {
            self.path = dictionary[CFSResponseItemIdKey];
        } else {
            self.path = [parentPath stringByAppendingPathComponent:dictionary[CFSResponseItemIdKey]];
        }
        
        self.dateMetaLastModified = [NSDate dateWithTimeIntervalSince1970:[dictionary[CFSResponseDateMetaLastModifiedKey] doubleValue]];
        self.isMirrored = [dictionary[CFSResponseIsMirroredKey] boolValue];
        self.type = dictionary[CFSResponseTypeKey];
        self.itemId = dictionary[CFSResponseItemIdKey];
        [self setItemState:dictionary];
        [self setAllowedOPerationListValues];
    }
    
    return self;
}

- (void)setItemState:(NSDictionary *)dictionary
{
    if (dictionary[CFSItemStateIsTrash]) {
        self.isTrash = dictionary[CFSItemStateIsTrash];
    } else {
        self.isTrash = NO;
    }
    
    if (dictionary[CFSItemStateIsShare]) {
        self.isShare = dictionary[CFSItemStateIsShare];
        self.shareKey = dictionary[CFSItemShareKey];
        if (self.parentPath == nil) {
            self.path = [@"/" stringByAppendingPathComponent:dictionary[CFSResponseItemIdKey]];
        }
    } else {
        self.isShare = NO;
        self.shareKey = nil;
    }
    
    if (dictionary[CFSItemStateIsOldVersion]) {
        self.isOldVersion = dictionary[CFSItemStateIsOldVersion];
    } else {
        self.isOldVersion = NO;
    }
}

#pragma mark - copy
- (void)copyToDestinationContainer:(CFSContainer *)destination
                        whenExists:(CFSExistsOperation)exists
                              name:(NSString *)name
                        completion:(void (^)(CFSItem *newItem, CFSError *error))completion
{
    if (![self validateOperation:CFSOperationCopy]) {
        completion(nil,[CFSErrorUtil errorWithMessage:CFSOperationNotAllowedError]);
    }
    
    [_restAdapter copyItem:self to:destination whenExists:exists name:name completion:completion];
}

#pragma mark - move
- (void)moveToDestinationContainer:(CFSContainer *)destination
                        whenExists:(CFSExistsOperation)exists
                        completion:(void (^)(CFSItem *movedItem, CFSError *error))completion
{
    if (![self validateOperation:CFSOperationMove]) {
        completion(nil,[CFSErrorUtil errorWithMessage:CFSOperationNotAllowedError]);
    }
    
    [_restAdapter moveItem:self to:destination whenExists:exists completion:^(CFSItem *movedItem, CFSError *error) {
        if (!error) {
            [self setMovedItemMetaDeta:movedItem];
        }
        
        completion(movedItem,error);
    }];
}

#pragma mark - delete
- (void)deleteWithCommit:(BOOL)commit force:(BOOL)force completion:(void (^)(BOOL success , CFSError *error))completion
{
    if (![self validateOperation:CFSOperationDelete]) {
        completion(NO,[CFSErrorUtil errorWithMessage:CFSOperationNotAllowedError]);
    }
    
    [_restAdapter deleteItem:self commit:commit force:force completion:^(BOOL success, CFSError *error) {
        if (success) {
            if (self.isTrash || commit) {
                self.isDead = YES;
            } else {
                [self setDeletedItemMetaDeta];
            }
        }
        
        completion(success,error);
    }];
}

#pragma mark - restore
- (void)restoreToContainer:(CFSContainer *)destination
             restoreMethod:(RestoreOptions)method
           restoreArgument:(NSString *)restoreArgument
          maintainValidity:(BOOL)maintainValidity
                completion:(void (^)(BOOL success, CFSError *error))completion
{
    if (![self validateOperation:CFSOperationRestore]) {
        completion(NO,[CFSErrorUtil errorWithMessage:CFSOperationNotAllowedError]);
    }
    
    [_restAdapter restoreItem:self restoreMethod:method restoreArgument:restoreArgument to:destination completion:^(BOOL success, CFSError *error) {
        if (maintainValidity && !error && success) {
            [self validateRestoreItemStateWithContainer:destination restoreMethod:method restoreArgument:restoreArgument completion:^(NSDictionary *dictionary,NSString *parentPath, CFSError *newError) {
                if (newError) {
                    self.isDead = YES;
                } else {
                    self.parentPath = parentPath;
                    if (parentPath == nil) {
                        self.path = dictionary[CFSResponseItemIdKey];
                    } else {
                        self.path = [parentPath stringByAppendingPathComponent:dictionary[CFSResponseItemIdKey]];
                    }
                    [self setItemAttributes:dictionary];
                }
                
                completion(success,newError);
            }];
        } else {
            self.isDead = YES;
            completion(success,error);
        }
        
    }];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"Item class: %@; name = %@; url = %@; version = %qi", [self class], self.name, self.path, self.version];
}

- (BOOL)setName:(NSString *)newName
{
    if (![self validateOperation:CFSOperationChangeAttribute]) {
        return NO;
    }
    
    NSMutableDictionary *meta = [[NSMutableDictionary alloc]init];
    meta[CFSResponseNameKey] = newName;
    meta[CFSResponseVersionKey] = [@(self.version) stringValue];
    CFSError *error;
    NSDictionary *newMeta = [_restAdapter alterMetaDataSyncWithPath:self.path meta:meta type:self.type error:&error];
    if (!error) {
        [self setItemAttributes:newMeta];
        return [_name isEqualToString:newName];
    }
    
    return false;
}

- (BOOL)setApplicationData:(NSDictionary *)newApplicationData
{
    if (![self validateOperation:CFSOperationChangeAttribute]) {
        return NO;
    }
    
    NSMutableDictionary *meta = [[NSMutableDictionary alloc]init];
    NSError *errorJson;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:newApplicationData options:0 error:&errorJson];
    NSString *JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    meta[CFSResponseApplicationDataKey] = JSONString;
    meta[CFSResponseVersionKey] = [@(self.version) stringValue];
    CFSError *error;
    NSDictionary *newMeta = [_restAdapter alterMetaDataSyncWithPath:self.path meta:meta type:self.type error:&error];
    if (!error && newMeta.count > 0) {
        [self setItemAttributes:newMeta];
        return YES;
    }
    
    return NO;
}

- (BOOL)changeAttributes:(NSDictionary *)values ifConflict:(VersionExists)ifConflict
{
    if (![self validateOperation:CFSOperationChangeAttribute]) {
        return NO;
    }
    
    NSMutableDictionary *meta = [NSMutableDictionary dictionaryWithDictionary:values];
    
    if(meta[CFSResponseApplicationDataKey] && [meta[CFSResponseApplicationDataKey] isKindOfClass:[NSDictionary class]])
    {
        NSError *errorJson;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:meta[CFSResponseApplicationDataKey] options:0 error:&errorJson];
        NSString *JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
        meta[CFSResponseApplicationDataKey] = JSONString;
    }
    
    meta[CFSResponseVersionKey] = [@(self.version) stringValue];
    if (ifConflict == VersionExistsIgnore) {
        meta[@"version-conflict"] = @"ignore";
    }
    
    CFSError *error;
    NSDictionary *newMeta = [_restAdapter alterMetaDataSyncWithPath:self.path meta:meta type:self.type error:&error];
    if (!error && newMeta.count > 0) {
        [self setItemAttributes:newMeta];
        return YES;
    }
    
    return NO;
}

- (void)changeAttributes:(NSDictionary *)values
              ifConflict:(VersionExists)ifConflict
              completion:(void (^)(BOOL success , CFSError *error))completion
{
    if (![self validateOperation:CFSOperationDelete]) {
        completion(NO,[CFSErrorUtil errorWithMessage:CFSOperationNotAllowedError]);
    }
    
    NSMutableDictionary *meta = [NSMutableDictionary dictionaryWithDictionary:values];
    
    if(meta[CFSResponseApplicationDataKey] && [meta[CFSResponseApplicationDataKey] isKindOfClass:[NSDictionary class]])
    {
        NSError *errorJson;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:meta[CFSResponseApplicationDataKey] options:0 error:&errorJson];
        NSString *JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
        meta[CFSResponseApplicationDataKey] = JSONString;
    }
    meta[CFSResponseVersionKey] = [@(self.version) stringValue];
    
    if (ifConflict == VersionExistsIgnore) {
        meta[@"version-conflict"] = @"ignore";
    }
    
    [_restAdapter alterMetaDataAsyncWithPath:self.path meta:meta type:self.type completionHandler:^(NSDictionary *dictionary, CFSError *error) {
        NSDictionary *newMeta = dictionary;
        if (!error && newMeta.count > 0) {
            [self setItemAttributes:newMeta];
            completion(YES,error);
        } else {
            completion(NO,error);
        }
    }];
}

- (void)setItemAttributes:(NSDictionary *)values
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)validateRestoreItemStateWithContainer:(CFSContainer *)destination
                                restoreMethod:(RestoreOptions)method
                              restoreArgument:(NSString *)restoreArgument
                                   completion:(void (^)(NSDictionary *dictionary, NSString *parentPath, CFSError *error))completion
{
    
    __block NSString *path = nil;
    __block NSString *parentPath = nil;
    if (method == RestoreOptionsFail) {
        if(self.applicationData[@"_bitcasa_original_path"]) {
            parentPath = self.applicationData[@"_bitcasa_original_path"];
            path = [parentPath stringByAppendingPathComponent:self.itemId];
            [_restAdapter getMetaDataWithPath:path type:CFSItemTypeFileSystem completionHandler:^(NSDictionary *dict, CFSError *error) {
                completion(dict,parentPath,error);
            }];
        }
    } else if (method == RestoreOptionsRescue) {
        if (destination.isDead) {
            parentPath = @"/";
            path = [parentPath stringByAppendingPathComponent:self.itemId];
            [_restAdapter getMetaDataWithPath:path type:CFSItemTypeFileSystem completionHandler:^(NSDictionary *dict, CFSError *error) {
                completion(dict, parentPath, error);
            }];
        } else {
            parentPath = destination.path;
            path = [parentPath stringByAppendingPathComponent:self.itemId];
            [_restAdapter getMetaDataWithPath:path type:CFSItemTypeFileSystem completionHandler:^(NSDictionary *dict, CFSError *error) {
                if (error && error.code == 404) {
                    parentPath = @"/";
                    [_restAdapter getMetaDataWithPath:path type:CFSItemTypeFileSystem completionHandler:^(NSDictionary *dict, CFSError *error) {
                        completion(dict, parentPath, error);
                    }];
                }
                else {
                    completion(dict, parentPath, error);
                }
            }];
        }
    } else {
        [self validateRestoreItemStateRecreateWithContainer:destination
                                            restoreArgument:restoreArgument
                                                 completion:^(NSDictionary *dictionary, NSString *parentPath, CFSError *error) {
            completion(dictionary, parentPath, error);
        }];
    }
}

- (void)validateRestoreItemStateRecreateWithContainer:(CFSContainer *)destination
                                      restoreArgument:(NSString *)restoreArgument
                                           completion:(void (^)(NSDictionary *dictionary, NSString *parentPath, CFSError *error))completion
{
    
    NSMutableArray *pathNames = nil;
    pathNames =[NSMutableArray arrayWithArray:[restoreArgument componentsSeparatedByString:@"/"]];
    [self getParentPathComponentFromNamedPathComponent:pathNames parentPath:@"/" count:0 completion:completion];
    
}

- (void)getParentPathComponentFromNamedPathComponent:(NSArray *)pathNames
                                          parentPath:(NSString *)parentPath
                                               count:(NSInteger)count
                                          completion:(void (^)(NSDictionary *dictionary, NSString *parentPath, CFSError *error))completion
{
    __block NSString *path = nil;
    __block NSInteger newCount = count;
    [_restAdapter listContentsOfPath:parentPath completion:^(NSArray *items, CFSError *error) {
        if(error) {
            completion(nil,parentPath,error);
        } else {
            for (CFSItem *item in items) {
                if ([item.name isEqualToString:pathNames[newCount]] && pathNames.count > newCount) {
                    newCount ++;
                    path = [parentPath stringByAppendingPathComponent:item.itemId];
                    if (pathNames.count <= newCount) {
                        NSString *newParentPath = path;
                        path = [newParentPath stringByAppendingPathComponent:self.itemId];
                        [_restAdapter getMetaDataWithPath:path type:CFSItemTypeFileSystem completionHandler:^(NSDictionary *dict, CFSError *error) {
                            completion(dict, newParentPath, error);
                        }];
                    } else {
                        [self getParentPathComponentFromNamedPathComponent:pathNames parentPath:path count:newCount completion:completion];
                        break;
                    }
                }
            }
            if (newCount == count && !(pathNames.count == newCount)) {
                completion(nil,parentPath,[CFSErrorUtil errorWithMessage:@"Path not found."]);
            }
        }
    }];

}
- (void)setItemName:(NSString *)name
{
    _name = name;
}

-(void)setMovedItemMetaDeta:(CFSItem *)item
{
    self.path = item.path;
    self.parentPath = item.parentPath;
    self.parentId = item.parentId;
    self.version = item.version;
}

- (void)setDeletedItemMetaDeta
{
    self.isTrash = YES;
    NSMutableDictionary *applicationData = [NSMutableDictionary dictionaryWithDictionary:self.applicationData];
    applicationData[CFSResponseOriginalPath] = self.parentPath;
    self.applicationData = [NSDictionary dictionaryWithDictionary:applicationData];
    self.path = self.itemId;
}

- (void)setAllowedOPerationListValues
{
    self.allowedOPerationList = @{CFSOperationCopy:@{CFSItemStateIsTrash:@NO,CFSItemStateIsOldVersion:@NO,CFSItemStateIsShare:@NO},
                                  CFSOperationMove:@{CFSItemStateIsTrash:@NO,CFSItemStateIsOldVersion:@NO,CFSItemStateIsShare:@NO},
                                  CFSOperationDelete:@{CFSItemStateIsTrash:@YES,CFSItemStateIsOldVersion:@NO,CFSItemStateIsShare:@NO},
                                  CFSOperationVersions:@{CFSItemStateIsTrash:@YES,CFSItemStateIsOldVersion:@NO,CFSItemStateIsShare:@NO},
                                  CFSOperationChangeAttribute:@{CFSItemStateIsTrash:@NO,CFSItemStateIsOldVersion:@NO,CFSItemStateIsShare:@NO},
                                  CFSOperationCreateFolder:@{CFSItemStateIsTrash:@NO,CFSItemStateIsOldVersion:@NO,CFSItemStateIsShare:@NO},
                                  CFSOperationDownload:@{CFSItemStateIsTrash:@NO,CFSItemStateIsOldVersion:@NO,CFSItemStateIsShare:@YES},
                                  CFSOperationDownloadLink:@{CFSItemStateIsTrash:@YES,CFSItemStateIsOldVersion:@NO,CFSItemStateIsShare:@YES},
                                  CFSOperationUpload:@{CFSItemStateIsTrash:@NO,CFSItemStateIsOldVersion:@NO,CFSItemStateIsShare:@NO},
                                  CFSOperationRestore:@{CFSItemStateIsTrash:@YES,CFSItemStateIsOldVersion:@NO,CFSItemStateIsShare:@NO},
                                  CFSOperationRead:@{CFSItemStateIsTrash:@NO,CFSItemStateIsOldVersion:@NO,CFSItemStateIsShare:@YES},
                                  CFSOperationList:@{CFSItemStateIsTrash:@YES,CFSItemStateIsOldVersion:@YES,CFSItemStateIsShare:@YES}};
}

- (BOOL)validateOperation:(NSString *)operation
{
    BOOL isAllowed =YES;
    if (self.isDead) {
        isAllowed = NO;
    }
    
    NSDictionary *list = self.allowedOPerationList[operation];
    if (self.isTrash && isAllowed) {
        isAllowed = list[CFSItemStateIsTrash];
    }
    
    if (self.isOldVersion && isAllowed) {
        isAllowed = list[CFSItemStateIsOldVersion];
    }
    
    if (self.isShare && isAllowed) {
        isAllowed = list[CFSItemStateIsShare];
    }
    
    return isAllowed;
}

@end
 