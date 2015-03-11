//
//  TabBarController.m
//  UrbanTurf
//
//  Created by Will Smith on 2/10/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "TabBarController.h"
#import "Stylesheet.h"

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
    
    self.selectedIndex = 1;

}

@end
