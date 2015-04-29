//
//  CFSItem.m
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

#import "CFSItem.h"
#import "CFSContainer.h"
#import "CFSError.h"
#import "CFSRestAdapter.h"

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

@end

NSString *const CFSResponseNameKey = @"name";
NSString *const CFSResponseItemIdKey = @"id";
NSString *const CFSResponseTypeKey = @"type";
NSString *const CFSResponseParentIdKey = @"parent_id";
NSString *const CFSResponseApplicationDataKey = @"application_data";
NSString *const CFSResponseDateContentLastModifiedKey = @"date_content_last_modified";
NSString *const CFSResponseDateMetaLastModifiedKey = @"date_meta_last_modified";
NSString *const CFSResponseDateCreatedKey = @"date_created";
NSString *const CFSResponseIsMirroredKey = @"is_mirrored";
NSString *const CFSResponseVersionKey = @"version";

@implementation CFSItem

@synthesize name = _name;
@synthesize applicationData = _applicationData;

#pragma mark - Initilization

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
      andParentContainer:(CFSContainer *)parent
          andRestAdapter:(CFSRestAdapter *)restAdapter;

{
    return [self initWithDictionary:dictionary andParentPath:parent.path andRestAdapter:restAdapter];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
           andParentPath:(NSString *)parentPath
          andRestAdapter:(CFSRestAdapter *)restAdapter;
{
    self = [super init];
    if (self)
    {
        _restAdapter = restAdapter;
        _name = dictionary[CFSResponseNameKey];
        self.dateContentLastModified = [NSDate dateWithTimeIntervalSince1970:[dictionary[CFSResponseDateContentLastModifiedKey] doubleValue]];
        self.dateCreated = [NSDate dateWithTimeIntervalSince1970:[dictionary[CFSResponseDateCreatedKey] doubleValue]];
        self.version = [dictionary[CFSResponseVersionKey] integerValue];
        self.parentId = dictionary[CFSResponseParentIdKey];
        _applicationData = dictionary[CFSResponseApplicationDataKey];
        if (parentPath == nil) {
            self.path = dictionary[CFSResponseItemIdKey];
        }
        else {
            self.path = [parentPath stringByAppendingPathComponent:dictionary[CFSResponseItemIdKey]];
        }
        self.dateMetaLastModified = [NSDate dateWithTimeIntervalSince1970:[dictionary[CFSResponseDateMetaLastModifiedKey] doubleValue]];
        self.isMirrored = [dictionary[CFSResponseIsMirroredKey] boolValue];
        self.type = dictionary[CFSResponseTypeKey];
        self.itemId = dictionary[CFSResponseItemIdKey];
    }
    return self;
}

#pragma mark - copy
- (void)copyToDestinationContainer:(CFSContainer *)destination
                        whenExists:(CFSExistsOperation)exists
                        completion:(void (^)(CFSItem *newItem, CFSError *error))completion
{
    [_restAdapter copyItem:self to:destination whenExists:exists completion:completion];
}

#pragma mark - move
- (void)moveToDestinationContainer:(CFSContainer *)destination
                        whenExists:(CFSExistsOperation)exists
                        completion:(void (^)(CFSItem *movedItem, CFSError *error))completion
{
    [_restAdapter moveItem:self to:destination whenExists:exists completion:completion];
}

#pragma mark - delete
- (void)deleteWithCommit:(BOOL)commit force:(BOOL)force completion:(void (^)(BOOL success , CFSError *error))completion
{
    [_restAdapter deleteItem:self commit:commit force:force completion:completion];
}

#pragma mark - restore
- (void)restoreToContainer:(CFSContainer *)destination
             restoreMethod:(RestoreOptions)method
           restoreArgument:(NSString *)restoreArgument
                completion:(void (^)(BOOL success, CFSError *error))completion
{
    [_restAdapter restoreItem:self restoreMethod:method restoreArgument:restoreArgument to:destination completion:completion];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"Item class: %@; name = %@; url = %@; version = %qi", [self class], self.name, self.path, self.version];
}

- (BOOL)setName:(NSString *)newName
{
    NSMutableDictionary *meta = [[NSMutableDictionary alloc]init];
    meta[CFSResponseNameKey] = newName;
    meta[CFSResponseVersionKey] = [@(self.version) stringValue];
    CFSError *error;
    NSDictionary *newMeta = [_restAdapter alterMetaDataSyncWithPath:self.path meta:meta type:self.type error:&error];
    if(!error){
        [self setItemAttributes:newMeta];
        return [_name isEqualToString:newName];
    }
    return false;
}

- (BOOL)setApplicationData:(NSDictionary *)newApplicationData
{
    NSMutableDictionary *meta = [[NSMutableDictionary alloc]init];
    NSError *errorJson;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:newApplicationData options:0 error:&errorJson];
    NSString *JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    meta[CFSResponseApplicationDataKey] = JSONString;
    meta[CFSResponseVersionKey] = [@(self.version) stringValue];
    CFSError *error;
    NSDictionary *newMeta = [_restAdapter alterMetaDataSyncWithPath:self.path meta:meta type:self.type error:&error];
    if(!error && newMeta.count > 0){
        [self setItemAttributes:newMeta];
        return YES;
    }
    return NO;
}

- (BOOL)changeAttributes:(NSDictionary *)values ifConflict:(VersionExists)ifConflict
{
    NSMutableDictionary *meta = [NSMutableDictionary dictionaryWithDictionary:values];
    if(ifConflict == VersionExistsIgnore){
        meta[@"version-conflict"] = @"ignore";
    }
    CFSError *error;
    NSDictionary *newMeta = [_restAdapter alterMetaDataSyncWithPath:self.path meta:values type:self.type error:&error];
    if(!error && newMeta.count > 0){
        [self setItemAttributes:newMeta];
        return YES;
    }
    return NO;
}

- (void)changeAttributes:(NSDictionary *)values
              ifConflict:(VersionExists)ifConflict
              completion:(void (^)(BOOL success , CFSError *error))completion
{
    NSMutableDictionary *meta = [NSMutableDictionary dictionaryWithDictionary:values];
    if(ifConflict == VersionExistsIgnore){
        meta[@"version-conflict"] = @"ignore";
    }
    [_restAdapter alterMetaDataAsyncWithPath:self.path meta:values type:self.type completionHandler:^(NSDictionary *dictionary, CFSError *error) {
        NSDictionary *newMeta = dictionary;
        if(!error && newMeta.count > 0){
            [self setItemAttributes:newMeta];
            completion(YES,error);
        }
        else{
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

- (void)setItemName:(NSString *)name
{
    _name = name;
}

@end
 