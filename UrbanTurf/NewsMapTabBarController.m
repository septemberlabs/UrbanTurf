//
//  NewsMapTabBarController.m
//  UrbanTurf
//
//  Created by Will Smith on 2/10/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "NewsMapTabBarController.h"
#import "Stylesheet.h"
#import "FavoriteLocationsTVC.h"
#import "NewsMap.h"

@interface NewsMapTabBarController ()

@end

@implementation NewsMapTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // thank you for font icon explanation: http://xcode.jackietrillo.com/?p=280

    NSDictionary* attributesNormal =  @{
                                        NSFontAttributeName: [UIFont fontWithName:@"fontello" size:34.0],
                                        UITextAttributeTextColor: [Stylesheet color1]
                                        };
    
    for (UITabBarItem* tabBarItem in self.tabBar.items) {
        [tabBarItem setTitleTextAttributes:attributesNormal forState:UIControlStateNormal];
        [tabBarItem setTitlePositionAdjustment:UIOffsetMake(0.0, -8.0)];
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

            // loop through the view controllers contained by this tab bar vc until map is found, then pluck out the current location
            for (id vc in self.viewControllers) {
                if ([vc isKindOfClass:[NewsMap class]]) {
                    NewsMap *primary = (NewsMap *)vc;
                    CLLocationCoordinate2D currentLocation = CLLocationCoordinate2DMake(primary.latitude, primary.longitude);
                    favorites.currentLocation = currentLocation;
                }
            }
        }
    }
}

#pragma mark - Transition between saved locations and news map

- (void)prepareAndLoadNewsMap:(CLLocationCoordinate2D)location
{
    // loop through the view controllers until the NewsMap is found, then set its location and select it as the active tab.
    for (id vc in self.viewControllers) {
        if ([vc isKindOfClass:[UINavigationController class]]) {  // the NewsMap is embedded in a navigation controller, so check for that first.
            UINavigationController *navigationController = (UINavigationController *)vc;
            if ([navigationController.viewControllers[0] isKindOfClass:[NewsMap class]]) {
                NewsMap *newsMap = (NewsMap *)navigationController.viewControllers[0];
                [newsMap setLocationWithLatitude:location.latitude andLongitude:location.longitude];
                self.selectedViewController = navigationController;
            }
        }
    }
}

@end