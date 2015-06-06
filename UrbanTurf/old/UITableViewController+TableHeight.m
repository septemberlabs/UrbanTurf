//
//  UITableViewController+TableHeight.m
//  UrbanTurf
//
//  Created by Will Smith on 4/2/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "UITableViewController+TableHeight.h"

@implementation UITableViewController (TableHeight)

// dynamically calculate the height of a table based on its actual contents.
// the purpose of this method was for use in SearchOptions to dynamically adjust the height of the container views.
- (CGFloat)tableHeightBasedOnContents
{
    if (self.tableView) {
        // add the table header and footer, as well as every section's header, footer, and cells.
        CGFloat height;
        CGFloat mostRecentValue;
        mostRecentValue = [self.tableView tableHeaderView].frame.size.height;
        //NSLog(@"most recent value: %f", mostRecentValue);
        height += [self.tableView tableHeaderView].frame.size.height;
        for (int section = 0; section <[self.tableView numberOfSections]; section++) {
            mostRecentValue = [self.tableView headerViewForSection:section].frame.size.height;
            //NSLog(@"most recent value: %f", mostRecentValue);
            height += [self.tableView headerViewForSection:section].frame.size.height;
            for (int row = 0; row < [self.tableView numberOfRowsInSection:section]; row++) {
                mostRecentValue = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]].frame.size.height;
                //NSLog(@"most recent value: %f", mostRecentValue);
                height += [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]].frame.size.height;
            }
            mostRecentValue = [self.tableView footerViewForSection:section].frame.size.height;
            //NSLog(@"most recent value: %f", mostRecentValue);
            height += [self.tableView footerViewForSection:section].frame.size.height;
        }
        mostRecentValue = [self.tableView tableFooterView].frame.size.height;
        //NSLog(@"most recent value: %f", mostRecentValue);
        height += [self.tableView tableFooterView].frame.size.height;
        
        return height;
    }
    else {
        return 0;
    }
    //return self.tableView.contentSize.height; // a different approach.
    //return self.tableView.frame.size.height;  // yet another.
}

@end
