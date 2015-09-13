//
//  SearchOptions.m
//  UrbanTurf
//
//  Created by Will Smith on 4/2/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "SearchOptions.h"

@interface SearchOptions ()
// these instance variables were all part of the attempt described below and can be deleted.
/*
@property (weak, nonatomic) IBOutlet UIView *radiusContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *radiusContainerViewHeight;
@property (weak, nonatomic) IBOutlet UIView *displayOrderContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *displayOrderContainerViewHeight;
 */
@end

@implementation SearchOptions

/*
 
 All this code was a failed attempt to calculate the actual height of the two table views contained in the container views. Currently their heights are
 hard-coded as constraints in the storyboard, but I wanted them to be dynamic to that each container view fit its contained table view exactly, with no margin anywhere.
 After a few years, abandoned this.

 - (void)viewWillAppear:(BOOL)animated
{
    
    NSLog(@"child controllers: %@", self.childViewControllers);
    for (UIViewController *childController in self.childViewControllers) {
        if ([childController isKindOfClass:[Radius class]]) {
            Radius *radius = (Radius *)childController;
            NSLog(@"official radius table height: %f", radius.tableView.frame.size.height);
            NSLog(@"actual radius table height: %f", [radius tableHeightBasedOnContents]);
            NSLog(@"radius container view height pre-sizeToFit: %@", NSStringFromCGSize(self.radiusContainerView.frame.size));
            //self.radiusContainerView.frame = CGRectMake(self.radiusContainerView.frame.origin.x, self.radiusContainerView.frame.origin.y, self.radiusContainerView.frame.size.width, [radius tableHeightBasedOnContents]);
            self.radiusContainerViewHeight.constant = [radius tableHeightBasedOnContents];
            NSLog(@"radius container view height post-sizeToFit: %@", NSStringFromCGSize(self.radiusContainerView.frame.size));
            //radius.tableView.frame.size.height = [radius tableHeightBasedOnContents];
        }
         if ([childController isKindOfClass:[DisplayOrder class]]) {
         DisplayOrder *displayOrder = (DisplayOrder *)childController;
         NSLog(@"official displayOrder table height: %f", displayOrder.tableView.frame.size.height);
         NSLog(@"actual displayOrder table height: %f", [displayOrder tableHeightBasedOnContents]);
         NSLog(@"displayOrder container view height pre-sizeToFit: %@", NSStringFromCGSize(self.displayOrderContainerView.frame.size));
         //self.radiusContainerView.frame = CGRectMake(self.radiusContainerView.frame.origin.x, self.radiusContainerView.frame.origin.y, self.radiusContainerView.frame.size.width, [radius tableHeightBasedOnContents]);
         self.displayOrderContainerViewHeight.constant = [displayOrder tableHeightBasedOnContents];
         NSLog(@"displayOrder container view height post-sizeToFit: %@", NSStringFromCGSize(self.displayOrderContainerView.frame.size));
         //radius.tableView.frame.size.height = [radius tableHeightBasedOnContents];
         }
    }

     self.topContainerView.layer.borderWidth = 1.0f;
     self.topContainerView.layer.borderColor = [[UIColor purpleColor] CGColor];
     NSLog(@"topContainView height: %f", self.topContainerView.frame.size.height);
     NSLog(@"top container child views: %@", self.topContainerView.subviews);
     for (UIView *subview in self.topContainerView.subviews) {
     if ([subview isKindOfClass:[UITableViewController class]]) {
     UITableViewController *containedTVC = (UITableViewController *)subview;
     NSLog(@"topContainView contained table height: %f", [containedTVC tableHeightBasedOnContents]);
     }
     }
     self.bottomContainerView.layer.borderWidth = 1.0f;
     self.bottomContainerView.layer.borderColor = [[UIColor redColor] CGColor];
     NSLog(@"bottomContainView height: %f", self.bottomContainerView.frame.size.height);
     NSLog(@"top container child views: %@", self.bottomContainerView.subviews);
     for (UIView *subview in self.bottomContainerView.subviews) {
     if ([subview isKindOfClass:[UITableViewController class]]) {
     UITableViewController *containedTVC = (UITableViewController *)subview;
     NSLog(@"bottomContainView contained table height: %f", [containedTVC tableHeightBasedOnContents]);
     }
     }
}
 */

@end