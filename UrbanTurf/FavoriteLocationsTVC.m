//
//  FavoriteLocationsTVC.m
//  UrbanTurf
//
//  Created by Will Smith on 3/10/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "Constants.h"
#import "FavoriteLocationsTVC.h"
#import "SaveFavoriteLocation.h"

@interface FavoriteLocationsTVC ()
@property (strong, nonatomic) NSArray *savedLocations;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;
@end

@implementation FavoriteLocationsTVC

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.savedLocations = [[NSUserDefaults standardUserDefaults] arrayForKey:userDefaultsSavedLocationsKey];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
    
    // this sets the back button text of the subsequent vc, not the visible vc. confusing.
    // thank you: https://dbrajkovic.wordpress.com/2012/10/31/customize-the-back-button-of-uinavigationitem-in-the-navigation-bar/
    self.navigationBar.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:nil action:nil];

    //self.edgesForExtendedLayout = UIRectEdgeBottom;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.savedLocations = [[NSUserDefaults standardUserDefaults] arrayForKey:userDefaultsSavedLocationsKey];
    [self.tableView reloadData];
    NSLog(@"user defaults: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // the top section displays only a single row, the Save Location command
    if (section == 0) {
        return 1;
    }
    // the bottom section displays a row for each saved location
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
        if ([self.savedLocations count]) {
            return @"Favorites";
        }
        // if there are no saved locations, indicate this to the user
        else {
            return @"No Favorites";
        }
    }    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"Add This Location to Favorites";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        if ([self.savedLocations count]) {
            cell.textLabel.text = (NSString *)[[self.savedLocations objectAtIndex:indexPath.row] objectForKey:@"Name"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else {
            cell.textLabel.text = @"You haven't saved any locations.";
        }
    }

    return cell;
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return NO;
    }
    else {
        return YES;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSMutableArray *newArray = [self.savedLocations mutableCopy];
        [newArray removeObjectAtIndex:indexPath.row];
        self.savedLocations = newArray; // HOW CAN THIS WORK, assigning a mutable to an immutable array?

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.savedLocations forKey:userDefaultsSavedLocationsKey];
        [defaults synchronize];

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

        NSLog(@"user defaults: %@", [defaults dictionaryRepresentation]);

    }
    else {
        NSLog(@"Unhandled editing style! %d", (int)editingStyle);
    }
}

#pragma mark - Navigation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self performSegueWithIdentifier:@"SaveLocationToFavorites" sender:indexPath];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SaveLocationToFavorites"]) {
        if ([segue.destinationViewController isKindOfClass:[SaveFavoriteLocation class]]) {
            SaveFavoriteLocation *saveLocationVC = (SaveFavoriteLocation *)segue.destinationViewController;
            saveLocationVC.currentLocation = self.currentLocation;
        }
    }
}

@end
