//
//  AppDelegate.m
//  ShareFile
//
//  Created by Olga on 10/8/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import "AppDelegate.h"
#import <BitcasaSDK/Session.h>
#import "AuthVC.h"
#import "BCFileListVC.h"
@interface AppDelegate ()

@end

static NSString* SERVER_URL = @"https://w2krfscy4f.cloudfs.io";
static NSString* APP_ID = @"aajNc4HKqv1cBR8y9g62YTrXyE6jn3zXJ_Nw8yXRQKU";
static NSString* APP_SECRET = @"yHTQD57owFI9kEJmKnjMDUyK-233Xx-dADxsf17MdaDd1zCCp2Vuiy8aGEj6GHFzeSxLntdJN51fPI2guTaGCw";

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UINavigationController *nav;
    
    _session = [[Session alloc] initWithServerURL:SERVER_URL clientId:APP_ID clientSecret:APP_SECRET];

    AuthVC* authVC = [[AuthVC alloc] init];
    nav = [[UINavigationController alloc] initWithRootViewController:authVC];
    
    [self.window setRootViewController:nav];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
