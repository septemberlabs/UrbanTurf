//
//  TabBarController.m
//  UrbanTurf
//
//  Created by Will Smith on 2/10/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "TabBarController.h"
#import "Stylesheet.h"
#import "FavoriteLocationsTVC.h"
#import "Primary.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad {

    [super viewDidLoad];

    // thank you: http://xcode.jackietrillo.com/?p=280

    NSDictionary* attributesNormal =  @{
                                        NSFontAttributeName: [UIFont fontWithName:@"fontello" size:30.0],
                                        UITextAttributeTextColor: [Stylesheet color1]
                                        };
    
    for (UITabBarItem* tabBarItem in self.tabBar.items) {
        [tabBarItem setTitleTextAttributes:attributesNormal forState:UIControlStateNormal];
        [tabBarItem setTitlePositionAdjustment:UIOffsetMake(0.0, -9.0)];
    }

    [[self.tabBar.items objectAtIndex:0] setTitle:[NSString stringWithUTF8String:"\ue818"]]; // left: Star for bookmarked locations. "Saved Locations"
    [[self.tabBar.items objectAtIndex:1] setTitle:[NSString stringWithUTF8String:"\ue800"]]; // center: Map marker for all map interactions. "News Map"
    [[self.tabBar.items objectAtIndex:2] setTitle:[NSString stringWithUTF8String:"\ue808"]]; // right: Gear for options. "Options"
    
    self.selectedIndex = 1; // default view controller is the news map
    self.delegate = self; // the delegate is used to intercept button presses

}

#pragma mark - Selection of tab bar button (UITabBarControllerDelegate)

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    // if the favorites button is pressed, send that view controller the current location
    if ([viewController isKindOfClass:[UINavigationController class]]) {  // the FavoriteLocationsTVC is embedded in a navigation controller, so check for that first
        UINavigationController *vc = (UINavigationController *)viewController;
        if ([vc.viewControllers[0] isKindOfClass:[FavoriteLocationsTVC class]]) {
            FavoriteLocationsTVC *favorites = (FavoriteLocationsTVC *)vc.viewControllers[0];

            // loop through the view controllers until the Primary one is found
            for (id vc in self.viewControllers) {
                if ([vc isKindOfClass:[Primary class]]) {
                    Primary *primary = (Primary *)vc;
                    CLLocationCoordinate2D currentLocation;
                    currentLocation.latitude = primary.latitude;
                    currentLocation.longitude = primary.longitude;
                    favorites.currentLocation = currentLocation;
                }
            }
        }
    }
}

@end
