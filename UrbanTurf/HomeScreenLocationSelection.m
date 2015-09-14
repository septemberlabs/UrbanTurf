//
//  HomeScreenLocationSelection.m
//  UrbanTurf
//
//  Created by Will Smith on 3/23/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "HomeScreenLocationSelection.h"
#import "Constants.h"
#import "Stylesheet.h"

@interface HomeScreenLocationSelection ()
@property (strong, nonatomic) NSArray *savedLocations;
@end

@implementation HomeScreenLocationSelection

- (void)viewDidLoad
{
    // colors the check marks.
    self.tableView.tintColor = [Stylesheet color6];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.savedLocations = [[NSUserDefaults standardUserDefaults] arrayForKey:userDefaultsSavedLocationsKey];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else {
        return [self.savedLocations count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }
    else {
        return @"Or, Choose from Your Favorites";
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Select the location where the app should focus when launched.";
    }
    else {
        if ([self.savedLocations count] == 0) {
            return @"You haven't saved any locations. Tap the big star icon at the bottom of the screen to do so.";
        }
        else {
            return nil;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentHomeScreenLocation = [defaults stringForKey:userDefaultsHomeScreenLocationKey];
    
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = currentLocationString;
        if ([currentHomeScreenLocation isEqualToString:currentLocationString]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else {
        // return item in Saved Locations array at index indexPath.row
        NSDictionary *savedLocation = (NSDictionary *)[self.savedLocations objectAtIndex:indexPath.row];
        cell.textLabel.text = (NSString *)savedLocation[@"Name"];
        
        if ([currentHomeScreenLocation isEqualToString:(NSString *)savedLocation[@"Name"]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentHomeScreenLocation = [defaults stringForKey:userDefaultsHomeScreenLocationKey];
    
    // if the currently selected home screen location is NOT the same as the row the user just selected (otherwise no update to the UI needed)
    if (![currentHomeScreenLocation isEqualToString:[tableView cellForRowAtIndexPath:indexPath].textLabel.text]) {

        // loop through all cells, turning off the checkmark. because the number of cells will never be more than a few, this is an adequate, if inefficient, way to do it.
        for (int section = 0; section < [tableView numberOfSections]; section++) {
            for (int row = 0; row < [tableView numberOfRowsInSection:section]; row++) {
                // remove the checkmark from the currently selected row
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        
        // set a checkmark at the newly selected row
        UITableViewCell *newlySelectedCell = [tableView cellForRowAtIndexPath:indexPath];
        newlySelectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        // update the data source (user defaults)
        [defaults setObject:newlySelectedCell.textLabel.text forKey:userDefaultsHomeScreenLocationKey];
        [defaults synchronize];
    }
    
    // uncomment this if you want to add an unwind segue back to automatically return to the Options main menu
    //[self performSegueWithIdentifier:@"unwindAfterDisplayOrderSelection" sender:self];    
}

@end