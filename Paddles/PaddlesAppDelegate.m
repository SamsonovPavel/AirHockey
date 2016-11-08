//
//  PaddlesAppDelegate.m
//  Paddles
//
//  Created by Pavel Samsonov on 10.12.15.
//  Copyright (c) 2015 Samsonov Pavel. All rights reserved.
//

#import "PaddlesAppDelegate.h"
#import "PaddlesViewController.h"
#import "TitleViewController.h"


@implementation PaddlesAppDelegate

- (void)showTitle
{
    if (self.gameController)
    {
        [self.viewController dismissViewControllerAnimated:NO completion:nil];
        self.gameController = nil;
    }
}

- (void)playGame:(int)computer
{
    if (self.gameController == nil)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.gameController = [storyboard instantiateViewControllerWithIdentifier:@"PaddlesViewController"];
        self.gameController.computer = computer;
        [self.viewController presentViewController:self.gameController animated:NO completion:nil];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.viewController = [storyboard instantiateViewControllerWithIdentifier:@"TitleViewController"];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    if (self.gameController)
        [self.gameController pause];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (self.gameController)
        [self.gameController resume];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
