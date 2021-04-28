//
//  AppDelegate.m
//  YKNetworking
//
//  Created by Kevin on 2021/4/28.
//

#import "AppDelegate.h"
#import "TableViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    TableViewController *tableViewController = [TableViewController new];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:tableViewController];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    return YES;
}


@end
