//
//  DisplayOrder.m
//  UrbanTurf
//
//  Created by Will Smith on 3/22/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "DisplayOrder.h"
#import "Constants.h"

@interface DisplayOrder ()

@end

@implementation DisplayOrder

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[Constants displayOrders] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }

    cell.textLabel.text = (NSString *)[[Constants displayOrders] objectAtIndex:indexPath.row];
    
    if (indexPath.row == [[NSUserDefaults standardUserDefaults] integerForKey:userDefaultsDisplayOrderKey]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
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
    int currentlySelectedDisplayOrder = (int)[defaults integerForKey:userDefaultsDisplayOrderKey];
    
    // if the currently selected display order is NOT the same as the row the user just selected (otherwise no update to the UI needed)
    if (currentlySelectedDisplayOrder != indexPath.row) {

        // remove the checkmark from the currently selected row
        UITableViewCell *currentlySelectedCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentlySelectedDisplayOrder inSection:indexPath.section]];
        currentlySelectedCell.accessoryType = UITableViewCellAccessoryNone;
        
        // set a checkmark at the newly selected row
        UITableViewCell *newlySelectedCell = [tableView cellForRowAtIndexPath:indexPath];
        newlySelectedCell.accessoryType = UITableViewCellAccessoryCheckmark;

        // update the data source (user defaults)
        [defaults setInteger:indexPath.row forKey:userDefaultsDisplayOrderKey];
        [defaults synchronize];
        NSLog(@"user defaults: %@", [defaults dictionaryRepresentation]);
        
    }

    // uncomment this if you want to add an unwind segue back to automatically return to the Options main menu
    //[self performSegueWithIdentifier:@"unwindAfterDisplayOrderSelection" sender:self];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Order to display stories";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return @"The sequence in which stories are displayed is either according to distance from your chosen location, or in reverse chronological order (that is, most recent first).";
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