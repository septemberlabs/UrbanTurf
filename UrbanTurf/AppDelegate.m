//
//  AppDelegate.m
//  UrbanTurf
//
//  Created by Will Smith on 12/22/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import "AppDelegate.h"
#import "Stylesheet.h"
#import "Constants.h"
#import <GoogleMaps/GoogleMaps.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // nav bar look
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack]; // this forces status bar text to be white.
    [[UINavigationBar appearance] setBarTintColor:[Stylesheet color6]];
    [[UINavigationBar appearance] setTintColor:[Stylesheet color7]];
    [[UINavigationBar appearance] setTranslucent:NO];
    
    // prepare the app defaults
    NSArray *defaultsKeys = [NSArray arrayWithObjects:
                             userDefaultsDisplayOrderKey,
                             userDefaultsHomeScreenLocationKey,
                             userDefaultsVersionKey,
                             nil];
    NSArray *defaultsValues = [NSArray arrayWithObjects:
                               [NSNumber numberWithInt:0], // the first element in the array, Closest First
                               @"Current Location",
                               version,
                               nil];
    NSDictionary *defaults = [NSDictionary dictionaryWithObjects:defaultsValues forKeys:defaultsKeys];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];

    // authenticate with Google for use of Maps
    [GMSServices provideAPIKey:googleAPIKeyForiOSApplications];
    
    //NSLog(@"user defaults: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    
    [Fabric with:@[CrashlyticsKit]];
    
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
