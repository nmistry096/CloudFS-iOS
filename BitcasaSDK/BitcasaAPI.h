//
//  BitcasaAPI.h
//  BitcasaSDK
//
//  Created by Olga on 8/21/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Item;
@protocol TransferDelegate <NSObject>
@optional
#pragma mark - download
- (void)itemAtPath:(NSString*)itemPath didCompleteDownloadToURL:(NSURL*)locationURL error:(NSError*)err;
- (void)itemAtPath:(NSString*)itemPath didDownload:(int64_t)totalBytesWritten outOfTotal:(int64_t)totalBytesExpectedToWrite;

#pragma mark - upload
- (void)fileAtPath:(NSString*)filePath didCompleteUploadWithError:(NSError*)err;
- (void)fileAtPath:(NSString*)filePath didReceiveResponse:(NSURLResponse*)response;
- (void)fileAtPath:(NSString*)filePath didUpload:(int64_t)totalBytesUploaded outOfTotal:(int64_t)totalBytesExpectedToWrite;
@end

@class Container;
@class Folder;
@interface BitcasaAPI : NSObject
+ (NSString *)accessTokenWithEmail:(NSString *)email password:(NSString *)password;

#pragma mark - Get profile
+ (void)getProfileWithCompletion:(void(^)(NSDictionary* response))completion;

#pragma mark - List directory contents
+ (void)getContentsOfContainer:(Container*)container completion:(void (^)(NSArray* response))completion;

#pragma mark - Move item(s)
+ (void)moveItem:(Item*)itemToMove to:(id)toItem completion:(void (^)(Item* movedItem))completion;
+ (void)moveItems:(NSArray*)itemsToMove to:(id)toItem completion:(void (^)(NSArray* success))completion;

#pragma mark - Delete item(s)
+ (void)deleteItem:(Item*)itemToDelete completion:(void (^)(BOOL success))completion;
+ (void)deleteItems:(NSArray*)items completion:(void (^)(NSArray* results))completion;

#pragma mark - Copy item(s)
+ (void)copyItem:(Item*)itemToCopy to:(id)destItem completion:(void (^)(Item* newItem))completion;
+ (void)copyItems:(NSArray*)items to:(id)toItem completion:(void (^)(NSArray* success))completion;

#pragma mark - Create new directory
+ (void)createFolderInContainer:(Container*)container withName:(NSString*)name completion:(void (^)(NSDictionary* newFolderDict))completion;

#pragma mark - Downloads
+ (void)downloadItem:(Item*)item delegate:(id <TransferDelegate>)delegate;

#pragma mark - Uploads
+ (void)uploadFile:(NSURL*)sourceURL to:(Folder*)destContainer delegate:(id <TransferDelegate>)delegate;
@end