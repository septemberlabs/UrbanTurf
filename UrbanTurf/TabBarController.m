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
#import "NewsMap.h"
#import "Constants.h"
#import "UIImage+ColorOverlay.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageRenderingMode renderingMode = UIImageRenderingModeAlwaysTemplate;
    NSArray *tabs =  @[
                       @{@"Selected Image" : @"tabbar-favorites",
                         @"Unselected Image" : @"tabbar-favorites-selected",
                         @"Title" : @"My Locations"},
                       @{@"Selected Image" : @"tabbar-map",
                         @"Unselected Image" : @"tabbar-map-selected",
                         @"Title" : @"News Map"},
                       @{@"Selected Image" : @"tabbar-settings",
                         @"Unselected Image" : @"tabbar-settings-selected",
                         @"Title" : @"Settings"},
                       ];
    int i = 0;
    for (NSDictionary *tab in tabs) {
        UIImage *icon = [UIImage imageNamed:(NSString *)[tab objectForKey:@"Selected Image"]];
        icon = [icon imageWithRenderingMode:renderingMode];
        UIImage *iconSelected = [UIImage imageNamed:(NSString *)[tab objectForKey:@"Unselected Image"]];
        iconSelected = [iconSelected imageWithRenderingMode:renderingMode];
        UITabBarItem *button = [self.tabBar.items objectAtIndex:i];
        button.title = (NSString *)[tab objectForKey:@"Title"];
        button.image = icon;
        button.selectedImage = iconSelected;
        i++;
    }
    
    // The following uses the category UIImage+ColorOverlay to correctly color unselected tab text and icons, which apparently is quite difficult to do. thank you: http://stackoverflow.com/questions/11512783/unselected-uitabbar-color/24106632#24106632
    
    // set colors for SELECTED tabs
    [self.tabBar setTintColor:[Stylesheet color6]];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [Stylesheet color6] }
                                             forState:UIControlStateSelected];
    
    // set colors for UNSELECTED tabs
    UIColor *unselectedColor = [Stylesheet color6];
    // unselected text
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : unselectedColor }
                                             forState:UIControlStateNormal];
    
    // generate the correctly-colored unselected images based on the images set above.
    for (UITabBarItem *item in self.tabBar.items) {
        // use the category's imageWithColor: method
        item.image = [[item.image imageWithColor:unselectedColor] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    
    
    /******************************* old Fontello font icons method below. *******************************

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
     
    ******************************* old Fontello font icons method below. *******************************/

    
    self.selectedIndex = 1; // default view controller is the news map
    self.delegate = self; // the delegate is used to intercept button presses

}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Selection of tab bar button (UITabBarControllerDelegate)

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    // if the favorites button is pressed, send that view controller the current location.
    if ([viewController isKindOfClass:[UINavigationController class]]) {  // the FavoriteLocationsTVC is embedded in a navigation controller, so check for that first.
        UINavigationController *vc = (UINavigationController *)viewController;
        if ([vc.viewControllers[0] isKindOfClass:[FavoriteLocationsTVC class]]) {
            FavoriteLocationsTVC *favorites = (FavoriteLocationsTVC *)vc.viewControllers[0];
            // loop through the view controllers contained by this tab bar vc until map is found, then pluck out the current location.
            for (id vc in self.viewControllers) {
                if ([vc isKindOfClass:[UINavigationController class]]) { // the NewsMap is embedded in a navigation controller, so check for that first.
                    UINavigationController *navVC = (UINavigationController *)vc;
                    if ([navVC.viewControllers[0] isKindOfClass:[NewsMap class]]) {
                        NewsMap *primary = (NewsMap *)navVC.viewControllers[0];
                        CLLocationCoordinate2D currentLocation = CLLocationCoordinate2DMake(primary.latitude, primary.longitude);
                        favorites.currentLocation = currentLocation;
                    }
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
                [newsMap setLocationWithLatitude:location.latitude andLongitude:location.longitude zoom:DEFAULT_ZOOM_LEVEL];
                self.selectedViewController = navigationController;
            }
        }
    }
}

@end