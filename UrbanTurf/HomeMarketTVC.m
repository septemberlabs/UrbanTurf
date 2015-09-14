//
//  HomeMarketTVC.m
//  UrbanTurf
//
//  Created by Will Smith on 8/31/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "HomeMarketTVC.h"
#import "Constants.h"
#import "Stylesheet.h"

@interface HomeMarketTVC ()

@end

@implementation HomeMarketTVC

#pragma mark - Table view data source

- (void)viewDidLoad
{
    // colors the check marks.
    self.tableView.tintColor = [Stylesheet color6];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[Constants cities] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    
    NSDictionary *city = (NSDictionary *)[[Constants cities] objectAtIndex:indexPath.row];
    cell.textLabel.text = (NSString *)[city objectForKey:@"Name"];
    
    // the home market may not be set, in which case none are checked.
    if ([[NSUserDefaults standardUserDefaults] objectForKey:userDefaultsCityKey] != nil) {
        if (indexPath.row == [[NSUserDefaults standardUserDefaults] integerForKey:userDefaultsCityKey]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // if a city has been set, and it's different than the one the user just selected, update the UI and user defaults value.
    if ([[NSUserDefaults standardUserDefaults] objectForKey:userDefaultsCityKey] != nil) {
        
        int currentlySelectedCity = (int)[defaults integerForKey:userDefaultsCityKey];
        
        // if the currently selected city is NOT the same as the row the user just selected (otherwise no update to the UI needed)
        if (currentlySelectedCity != indexPath.row) {
            
            // remove the checkmark from the currently selected row
            UITableViewCell *currentlySelectedCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentlySelectedCity inSection:indexPath.section]];
            currentlySelectedCell.accessoryType = UITableViewCellAccessoryNone;
            
            // set a checkmark at the newly selected row
            UITableViewCell *newlySelectedCell = [tableView cellForRowAtIndexPath:indexPath];
            newlySelectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            // update the data source (user defaults)
            [defaults setInteger:indexPath.row forKey:userDefaultsCityKey];
            [defaults synchronize];
        }
    }
    // if a city had not been set, simply update the UI and user defaults value.
    else {
        // set a checkmark at the newly selected row
        UITableViewCell *newlySelectedCell = [tableView cellForRowAtIndexPath:indexPath];
        newlySelectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        // update the data source (user defaults)
        [defaults setInteger:indexPath.row forKey:userDefaultsCityKey];
        [defaults synchronize];
    }
    
    // uncomment this if you want to add an unwind segue back to automatically return to the Options main menu
    //[self performSegueWithIdentifier:@"unwindAfterDisplayOrderSelection" sender:self];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return HOME_CITY_TABLE_HEADER;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return HOME_CITY_TABLE_FOOTER;
}

@end
