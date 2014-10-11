//
//  BCFileListVC.h
//  ShareFile
//
//  Created by Olga on 10/8/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BitcasaSDK/BitcasaAPI.h>

@class Container;
@interface BCFileListVC : UITableViewController <UIActionSheetDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TransferDelegate>

- (id)initWithDir:(Folder*)dir andItems:(NSArray*)items;

@end
