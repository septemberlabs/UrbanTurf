//
//  SaveFavoriteLocation.m
//  UrbanTurf
//
//  Created by Will Smith on 3/11/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "SaveFavoriteLocation.h"

@interface SaveFavoriteLocation ()
@property (weak, nonatomic) IBOutlet UILabel *latlonLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;
@end

@implementation SaveFavoriteLocation

- (void)viewDidLoad {
    [super viewDidLoad];
    self.latlonLabel.text = [NSString stringWithFormat:@"%f, %f", self.currentLocation.latitude, self.currentLocation.longitude];
}

- (IBAction)saveLocation:(id)sender {
    
    static NSString *userDefaultsKey = @"savedLocations";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *locationDictionary = @{
                        @"Name" : self.nameField.text,
                        @"Latitude" : [NSNumber numberWithFloat:self.currentLocation.latitude],
                        @"Longitude" : [NSNumber numberWithFloat:self.currentLocation.longitude]
                        };

    // if saved locations exist in user defaults, add the new location dictionary to end of that array
    NSArray *arrayToSave;
    if ([defaults arrayForKey:userDefaultsKey] != nil) {
        arrayToSave = [[defaults arrayForKey:userDefaultsKey] arrayByAddingObject:locationDictionary];
    }
    // otherwise create an entirely new array with the location dictionary as the sole object
    else {
        arrayToSave = [NSArray arrayWithObject:locationDictionary];
    }
    
    [defaults setObject:arrayToSave forKey:userDefaultsKey];
    [defaults synchronize];
    
    NSLog(@"user defaults: %@", [defaults dictionaryRepresentation]);

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
