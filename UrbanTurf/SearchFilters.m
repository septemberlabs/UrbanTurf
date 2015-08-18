//
//  SearchFilters.m
//  UrbanTurf
//
//  Created by Will Smith on 8/17/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "SearchFilters.h"

@interface SearchFilters ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation SearchFilters

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
}

- (void)setDisplayOrders:(NSMutableArray *)displayOrders
{
    _displayOrders = [[NSMutableArray alloc] initWithCapacity:[displayOrders count]];
    for (NSDictionary *displayOrder in displayOrders) {
        [_displayOrders addObject:[displayOrder mutableCopy]];
    }
}

- (void)setTags:(NSMutableArray *)tags
{
    _tags = [[NSMutableArray alloc] initWithCapacity:[tags count]];
    for (NSDictionary *tag in tags) {
        [_tags addObject:[tag mutableCopy]];
    }
}

- (IBAction)returnToNewsMap:(id)sender
{
    NSMutableArray *displayOrdersToReturn = [[NSMutableArray alloc] initWithCapacity:[self.displayOrders count]];
    for (NSMutableDictionary *displayOrder in self.displayOrders) {
        [displayOrdersToReturn addObject:[NSDictionary dictionaryWithDictionary:displayOrder]];
    }
    
    NSMutableArray *tagsToReturn = [[NSMutableArray alloc] initWithCapacity:[self.tags count]];
    for (NSMutableDictionary *tag in self.tags) {
        [tagsToReturn addObject:[NSDictionary dictionaryWithDictionary:tag]];
    }
    
    [self.delegate updateSearchFilters:[NSArray arrayWithArray:displayOrdersToReturn] tags:[NSArray arrayWithArray:tagsToReturn]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return [self.displayOrders count];
            break;
        case 1:
            return [self.tags count];
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
        filterLabel = (NSString *)[self.displayOrders[indexPath.row] objectForKey:@"Menu Item"];
        NSNumber *currentValue = (NSNumber *)[self.displayOrders[indexPath.row] objectForKey:@"Value"];
        checked = currentValue.boolValue;
    }
    
    if (indexPath.section == 1) {
        filterLabel = (NSString *)[self.tags[indexPath.row] objectForKey:@"Menu Item"];
        NSNumber *currentValue = (NSNumber *)[self.tags[indexPath.row] objectForKey:@"Value"];
        checked = currentValue.boolValue;
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
            [self.displayOrders[0] setObject:[NSNumber numberWithBool:YES] forKey:@"Value"];
            [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].accessoryType = UITableViewCellAccessoryCheckmark;
            [self.displayOrders[1] setObject:[NSNumber numberWithBool:NO] forKey:@"Value"];
            [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]].accessoryType = UITableViewCellAccessoryNone;
        }
        else {
            [self.displayOrders[0] setObject:[NSNumber numberWithBool:NO] forKey:@"Value"];
            [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].accessoryType = UITableViewCellAccessoryNone;
            [self.displayOrders[1] setObject:[NSNumber numberWithBool:YES] forKey:@"Value"];
            [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]].accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    // in the second section for tags, all choices can be either checked or unchecked, so we just toggle its value when a cell is tapped.
    if (indexPath.section == 1) {
        NSNumber *currentValue = (NSNumber *)[self.tags[indexPath.row] objectForKey:@"Value"];
        if (currentValue.boolValue == YES) {
            [self.tags[indexPath.row] setObject:[NSNumber numberWithBool:NO] forKey:@"Value"];
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
        }
        else {
            [self.tags[indexPath.row] setObject:[NSNumber numberWithBool:YES] forKey:@"Value"];
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