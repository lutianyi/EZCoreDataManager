//
//  AppDelegate.m
//  EZCoreDataExample
//
//  Created by 卢天翊 on 15/9/9.
//  Copyright (c) 2015年 Lanou3G. All rights reserved.
//

#import "EZAppDelegate.h"
#import "EZViewController.h"

@interface EZAppDelegate ()

@end

@implementation EZAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    
    EZViewController * viewController = [EZViewController new];
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self.window setRootViewController:navigationController];
    
    [self.window setBackgroundColor:[UIColor whiteColor]];
    
    for (int i = 0; i < 10; i++) {
     
        NSDictionary * parameters = @{@"p_name": @"Ezer", @"p_age": @25};
        
        [[EZCoreDataManager defaultManager] addManagedObjectModelWithName:@"Person" dictionary:parameters];
    }
    
    return YES;
}

@end