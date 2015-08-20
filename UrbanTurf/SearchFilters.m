//
//  SearchFilters.m
//  UrbanTurf
//
//  Created by Will Smith on 8/17/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "SearchFilters.h"
#import "Stylesheet.h"
#import "Constants.h"

@interface SearchFilters ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *updateMapButton;
@end

@implementation SearchFilters

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
    
    self.updateMapButton.backgroundColor = [Stylesheet color1];
}

- (void)setDisplayOrders:(NSMutableArray *)displayOrders
{
    _displayOrders = [[NSMutableArray alloc] initWithCapacity:[displayOrders count]];
    for (NSDictionary *displayOrder in displayOrders) {
        [_displayOrders addObject:[displayOrder mutableCopy]];
    }
}

- (void)setArticleAges:(NSMutableArray *)articleAges
{
    _articleAges = [[NSMutableArray alloc] initWithCapacity:[articleAges count]];
    for (NSDictionary *articleAge in articleAges) {
        [_articleAges addObject:[articleAge mutableCopy]];
    }
}

- (void)setArticleTags:(NSMutableArray *)articleTags
{
    _articleTags = [[NSMutableArray alloc] initWithCapacity:[articleTags count]];
    for (NSDictionary *tag in articleTags) {
        [_articleTags addObject:[tag mutableCopy]];
    }
}

- (IBAction)returnToNewsMap:(id)sender
{
    NSMutableArray *displayOrdersToReturn = [[NSMutableArray alloc] initWithCapacity:[self.displayOrders count]];
    for (NSMutableDictionary *displayOrder in self.displayOrders) {
        [displayOrdersToReturn addObject:[NSDictionary dictionaryWithDictionary:displayOrder]];
    }
    
    NSMutableArray *articleAgesToReturn = [[NSMutableArray alloc] initWithCapacity:[self.articleAges count]];
    for (NSMutableDictionary *articleAge in self.articleAges) {
        [articleAgesToReturn addObject:[NSDictionary dictionaryWithDictionary:articleAge]];
    }
    
    NSMutableArray *articleTagsToReturn = [[NSMutableArray alloc] initWithCapacity:[self.articleTags count]];
    for (NSMutableDictionary *tag in self.articleTags) {
        [articleTagsToReturn addObject:[NSDictionary dictionaryWithDictionary:tag]];
    }
    
    [self.delegate updateSearchFilters:[NSArray arrayWithArray:displayOrdersToReturn] articleAges:[NSArray arrayWithArray:articleAgesToReturn] articleTags:[NSArray arrayWithArray:articleTagsToReturn]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return [self.displayOrders count];
            break;
        case 1:
            return [self.articleAges count];
            break;
        case 2:
            return [self.articleTags count];
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
        checked = ((NSNumber *)[self.displayOrders[indexPath.row] objectForKey:@"Value"]).boolValue;

        /* DELETE AFTER 8/25. Was used for unimplemented UISegmentedControl stuff.
        NSMutableArray *displayOrderMenuItems;
        for (NSDictionary *displayOrder in self.displayOrders) {
            [displayOrderMenuItems addObject:[displayOrder objectForKey:@"Menu Item"]];
        }
         */
    }
    
    if (indexPath.section == 1) {
        filterLabel = (NSString *)[self.articleAges[indexPath.row] objectForKey:@"Menu Item"];
        checked = ((NSNumber *)[self.articleAges[indexPath.row] objectForKey:@"Value"]).boolValue;
    }
    
    if (indexPath.section == 2) {
        filterLabel = (NSString *)[self.articleTags[indexPath.row] objectForKey:@"Menu Item"];
        checked = ((NSNumber *)[self.articleTags[indexPath.row] objectForKey:@"Value"]).boolValue;
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return DISPLAY_ORDER_TABLE_HEADER;
            break;
        case 1:
            return ARTICLE_AGE_TABLE_HEADER;
            break;
        case 2:
            return ARTICLE_TAGS_TABLE_HEADER;
            break;
        default:
            return @"ERROR";
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"";
            break;
        case 1:
            return ARTICLE_AGE_TABLE_FOOTER;
            break;
        case 2:
            return ARTICLE_TAGS_TABLE_FOOTER;
            break;
        default:
            return @"ERROR";
    }
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
    
    // for the article age filter, only one can be checked at a time.
    if (indexPath.section == 1) {
        int i = 0;
        for (NSMutableDictionary *articleAge in self.articleAges) {
            if (i != indexPath.row) {
                [articleAge setObject:[NSNumber numberWithBool:NO] forKey:@"Value"];
                [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]].accessoryType = UITableViewCellAccessoryNone;
            }
            else {
                [articleAge setObject:[NSNumber numberWithBool:YES] forKey:@"Value"];
                [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]].accessoryType = UITableViewCellAccessoryCheckmark;
            }
            i++;
        }
    }
    
    // for the article tags filter, all choices can be either checked or unchecked, so we just toggle its value when a cell is tapped.
    if (indexPath.section == 2) {
        NSNumber *currentValue = (NSNumber *)[self.articleTags[indexPath.row] objectForKey:@"Value"];
        if (currentValue.boolValue == YES) {
            [self.articleTags[indexPath.row] setObject:[NSNumber numberWithBool:NO] forKey:@"Value"];
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
        }
        else {
            [self.articleTags[indexPath.row] setObject:[NSNumber numberWithBool:YES] forKey:@"Value"];
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