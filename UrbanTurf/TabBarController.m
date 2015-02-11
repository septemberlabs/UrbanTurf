//
//  TabBarController.m
//  UrbanTurf
//
//  Created by Will Smith on 2/10/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "TabBarController.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Near Me
    //UITabBarItem *nearMe = self.tabBar.items[0];
    //nearMe.title = @"just a test";
    
    //[[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], UITextAttributeTextColor, [UIFont fontWithName:@"font" size:0.0], UITextAttributeFont, nil] forState:UIControlStateHighlighted];
    
    UITabBarItem* tabBarItemBar = [self.tabBar.items objectAtIndex:0];
    UITabBarItem* tabBarItemMap = [self.tabBar.items objectAtIndex:1];
    
    UIFont* font = [UIFont fontWithName:@"fontello" size:30.0];
    NSDictionary* attributesNormal =  @{ NSFontAttributeName: font};
    
    [tabBarItemBar setTitleTextAttributes:attributesNormal forState:UIControlStateNormal];
    [tabBarItemMap setTitleTextAttributes:attributesNormal forState:UIControlStateNormal];
    
    [tabBarItemBar setTitle:[NSString stringWithUTF8String:"\ue80f"]];
    [tabBarItemMap setTitle:[NSString stringWithUTF8String:"\ue804"]];
    
    [tabBarItemBar setTitlePositionAdjustment:UIOffsetMake(0.0, -10.0)];
    [tabBarItemMap setTitlePositionAdjustment:UIOffsetMake(0.0, -12.0)];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
