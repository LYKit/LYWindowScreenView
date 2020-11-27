//
//  AppDelegate.m
//  demo
//
//  Created by langezhao on 2019/12/3.
//  Copyright © 2019 学习. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:[ViewController new]];
    self.window.rootViewController = navc;
    [self.window makeKeyAndVisible];
    
    return YES;
}



@end
