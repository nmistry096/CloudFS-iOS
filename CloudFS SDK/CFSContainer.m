//
//  CFSContainer.m
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

#import "CFSContainer.h"
#import "CFSRestAdapter.h"
#import "CFSErrorUtil.h"

@implementation CFSContainer

#pragma mark - list items

- (void)listWithCompletion:(void (^)(NSArray *items, CFSError *error))completion
{
    if (![self validateOperation:CFSOperationList]) {
        completion(nil,[CFSErrorUtil errorWithMessage:CFSOperationNotAllowedError]);
    }
    
    if (self.isTrash) {
        [_restAdapter getContentsOfTrashWithPath:self.path completion:completion];
    } else if(self.isShare) {
        [_restAdapter browseShare:self.shareKey container:self completion:completion];
    } else {
        [_restAdapter listContentsOfContainer:self completion:completion];
    }
}
@end
