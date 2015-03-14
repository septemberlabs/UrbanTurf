//
//  FavoriteLocationsTVC.m
//  UrbanTurf
//
//  Created by Will Smith on 3/10/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "FavoriteLocationsTVC.h"
#import "SaveFavoriteLocation.h"

@interface FavoriteLocationsTVC ()

@property NSArray *savedLocations;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;
@end

@implementation FavoriteLocationsTVC

- (void)viewDidLoad {
    
    [super viewDidLoad];

    static NSString *userDefaultsKey = @"savedLocations";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.savedLocations = [defaults arrayForKey:userDefaultsKey];
    
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
    [self.tableView reloadData];
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
        if ([self.savedLocations count]) {
            return [self.savedLocations count];
        }
        // if there are no saved locations, display a single row communicating that to the user
        else {
            return 1;
        }
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return nil;
    }
    else {
        return @"Favorites";
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"Add Location to Favorites";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        if ([self.savedLocations count]) {
            cell.textLabel.text = (NSString *)[[self.savedLocations objectAtIndex:indexPath.row] objectForKey:@"Name"];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else {
            cell.textLabel.text = @"You haven't saved any locations.";
        }
    }

    return cell;
    
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // HERE HERE HERE
        // 1. Deleting the last row in Saved Locations crashes, something to do with deleteRowsAtIndexPaths.
        // 2. Table view isn't displaying new records as they are saved.
        // 3. Delete the default text from the UITextField once the user clicks inside it.
        // 4. Confirm the text in the UITextField is left-aligned.
        // 5. Fix the cropped view display in Save Location.
        // 6. Fix the Autolayout issues with the table view in this class.
        // 7. Start re-aquainting yourself with MKMapView and current locations and passing that around.
        
        
        
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        NSMutableArray *newArray = [self.savedLocations mutableCopy];
        [newArray removeObjectAtIndex:indexPath.row];
        self.savedLocations = newArray; // HOW CAN THIS WORK, assigning a mutable to an immutable array?

        static NSString *userDefaultsKey = @"savedLocations";
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.savedLocations forKey:userDefaultsKey];
        [defaults synchronize];

        NSLog(@"user defaults: %@", [defaults dictionaryRepresentation]);

    }
    else {
        NSLog(@"Unhandled editing style! %ld", editingStyle);
    }
}

/* ********** ORIGINAL **********
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
