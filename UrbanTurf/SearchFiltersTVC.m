//
//  SearchFiltersTVC.m
//  UrbanTurf
//
//  Created by Will Smith on 8/17/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "SearchFiltersTVC.h"
#import "Constants.h"

@interface SearchFiltersTVC ()
@end

@implementation SearchFiltersTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)displayOrder
{
    if (!_displayOrders) {
        _displayOrders = [NSMutableArray arrayWithCapacity:[[Constants displayOrders] count]];
        _displayOrders[0] = [NSNumber numberWithBool:YES];
        _displayOrders[1] = [NSNumber numberWithBool:NO];
    }
    return _displayOrders;
}

- (NSMutableArray *)tags
{
    if (!_tags) {
        _tags = [NSMutableArray arrayWithCapacity:[[Constants tags] count]];
        _tags[0] = [NSNumber numberWithBool:YES];
        _tags[1] = [NSNumber numberWithBool:YES];
        _tags[2] = [NSNumber numberWithBool:NO];
    }
    return _tags;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return [[Constants displayOrders] count];
            break;
        case 1:
            return [[Constants tags] count];
            break;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchFiltersCell" forIndexPath:indexPath];
 
    NSString *filterLabel;
    BOOL checked = NO;
    
    if (indexPath.section == 0) {
        filterLabel = (NSString *)[[Constants displayOrders] objectAtIndex:indexPath.row];
        if (self.displayOrder[indexPath.row]) {
            checked = YES;
        }
    }
    
    if (indexPath.section == 1) {
        filterLabel = (NSString *)[[Constants tags] objectAtIndex:indexPath.row];
        if (self.tags[indexPath.row]) {
            checked = YES;
        }
    }

    cell.textLabel.text = filterLabel;
    if (checked) {
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
    
    // in the first section for display order, the two choices are mutually excusive. so checking one forces the unchecking of the other.
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            self.displayOrder[0] = [NSNumber numberWithBool:YES];
            [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].accessoryType = UITableViewCellAccessoryCheckmark;
            self.displayOrder[1] = [NSNumber numberWithBool:NO];
            [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]].accessoryType = UITableViewCellAccessoryNone;
        }
        else {
            self.displayOrder[0] = [NSNumber numberWithBool:NO];
            [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].accessoryType = UITableViewCellAccessoryNone;
            self.displayOrder[1] = [NSNumber numberWithBool:YES];
            [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]].accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    // in the second section for tags, all choices can be either checked or unchecked, so we just toggle its value when a cell is tapped.
    if (indexPath.section == 1) {
        BOOL currentValue = [[self.tags objectAtIndex:indexPath.row] boolValue];
        if (currentValue == YES) {
            self.tags[indexPath.row] = [NSNumber numberWithBool:NO];
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
        }
        else {
            self.tags[indexPath.row] = [NSNumber numberWithBool:YES];
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
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
