//
//  AppDelegate.h
//  ShareFile
//
//  Created by Olga on 10/8/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Session;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) Session* session;

@end

