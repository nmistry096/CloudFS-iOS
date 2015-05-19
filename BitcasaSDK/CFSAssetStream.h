//
//  CFSAssetStream.h
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

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

/*!
 * BCAssetStream is a subclass of NSInputStream. It is used to wrap NSInputStream around ALAssetRepresentation.
 * It can be used in a request to stream large camera roll files because the assets are sandboxed.
 */
@interface CFSAssetStream : NSInputStream <NSCopying>

/*!
 *  Property for status of the stram.
 */
@property (assign) NSStreamStatus streamStatus;

/*!
 *  Designated initializer.
 *
 *  @param representation Asset reprerentation
 *  @param library        Asset Library
 *
 *  @return self as a object
 */
- (instancetype)initWithAssetRep:(ALAssetRepresentation *)representation fromAssetLibrary:(ALAssetsLibrary *)library;

/*!
 *  Get the file name.
 *
 *  @return filename of the asset.
 */
- (NSString *)filename;

/*!
 *  Length of the content
 *
 *  @return length of the asset
 */
- (long long)contentLength;

@end
