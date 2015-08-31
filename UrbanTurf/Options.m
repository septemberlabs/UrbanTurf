//
//  Options.m
//  UrbanTurf
//
//  Created by Will Smith on 3/22/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "Options.h"
#import "Constants.h"

@interface Options ()
@property (weak, nonatomic) IBOutlet UITableViewCell *displayOrderCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *searchRadiusCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *homeScreenCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *versionCell;
@end

@implementation Options

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"user defaults: %@", [defaults dictionaryRepresentation]);
    NSDictionary *displayOrder = [[Constants displayOrders] objectAtIndex:[defaults integerForKey:userDefaultsDisplayOrderKey]];
    self.displayOrderCell.detailTextLabel.text = (NSString *)[displayOrder objectForKey:@"Menu Item"];
    self.searchRadiusCell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f mi", [defaults floatForKey:userDefaultsRadiusKey]];
    self.homeScreenCell.detailTextLabel.text = [defaults stringForKey:userDefaultsHomeScreenLocationKey];
    self.versionCell.detailTextLabel.text = [defaults stringForKey:userDefaultsVersionKey];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"ShowDisplayOrderOptionsScreen"]) {
    }

    if([segue.identifier isEqualToString:@"ShowRadiusOptionsScreen"]) {
    }
    
    if([segue.identifier isEqualToString:@"ShowHomeScreenOptionsScreen"]) {
    }

}

// just here to hook up the unwind segue in storyboard
- (IBAction)unwind:(UIStoryboardSegue *)unwindSegue
{
}

@end
