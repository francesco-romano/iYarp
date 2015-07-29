//
//  AppDelegate.m
//  IOL
//
//  Created by Francesco Romano on 19/07/15.
//  Copyright (c) 2015 Francesco Romano. All rights reserved.
//

#import "AppDelegate.h"
#import <yarp_iOS/IITYarpNetworkConfiguration.h>
#import "InitialViewController.h"
#import "IOLConstants.h"

@interface AppDelegate () <YarpNetworkCheckDelegate>

@end

@implementation AppDelegate

+ (void)initialize
{
    //Default preferences
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{
                                     IOLDefaultsNamespace: @"/root",
                                     IOLDefaultsHost : @"127.0.0.1",
                                     IOLDefaultsPort : @(10000),

                                     IOLDefaultsStateViewPort : @"/iolStateMachineHandler/imgLoc:o",
                                     IOLDefaultsOutputPort : @"/iIOL/outputPort:o"
                                     }];
    [userDefaults synchronize];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    InitialViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"InitializationView"];
    viewController.delegate = self;

    [self.window makeKeyAndVisible];
    [self.window.rootViewController presentViewController:viewController animated:YES completion:NULL];
    return YES;
}

- (void)viewController:(UIViewController *)viewController didCheckNetworkWithResult:(BOOL)result
{
    if (!result) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:@"Could not initialize network"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [viewController dismissViewControllerAnimated:YES completion:^{
                                                                      [(UITabBarController*)self.window.rootViewController setSelectedIndex:2
                                                                       ];                                                                  }];
                                                              }];

        [alert addAction:defaultAction];
        [viewController presentViewController:alert animated:YES completion:nil];

    }
    else {
        [viewController dismissViewControllerAnimated:YES completion:^{

        }];
    }
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

    [[IITYarpNetworkConfiguration sharedConfiguration] terminateNetwork];
}

@end
