//
//  AppDelegate.m
//  PhotoViewer
//
//  Created by admin on 2020/7/15.
//  Copyright © 2020 ChenYuHong. All rights reserved.
//

#import "AppDelegate.h"
#import "PVTabBarController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // Create window
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    // Add tabBarController
    UITabBarController *mainTabBar = [[PVTabBarController alloc] init];
    self.window.rootViewController = mainTabBar;
    
    // Display window
    [_window makeKeyAndVisible];
    return YES;
}

@end
