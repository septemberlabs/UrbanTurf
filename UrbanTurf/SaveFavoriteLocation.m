//
//  SaveFavoriteLocation.m
//  UrbanTurf
//
//  Created by Will Smith on 3/11/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "SaveFavoriteLocation.h"
#import "Constants.h"
#import <GoogleMaps/GoogleMaps.h>

@interface SaveFavoriteLocation ()
@property (weak, nonatomic) IBOutlet UIView *locationInfo;
@property (weak, nonatomic) IBOutlet UILabel *latlonLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIImageView *crosshairs;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;
@end

static NSString *const defaultNameTextFieldContent = @"e.g., \"Home\" or \"Work\"";

@implementation SaveFavoriteLocation

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.nameTextField.text = defaultNameTextFieldContent;
    self.latlonLabel.text = [NSString stringWithFormat:@"%f, %f", self.currentLocation.latitude, self.currentLocation.longitude];
    
    // hairline border between location info and map
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = [UIColor lightGrayColor].CGColor;
    bottomBorder.borderWidth = 0.25f;
    bottomBorder.frame = CGRectMake(0, CGRectGetHeight(self.locationInfo.frame) - 1.0, CGRectGetWidth(self.locationInfo.frame) - 1, 0.25f);
    [self.locationInfo.layer addSublayer:bottomBorder];
    
    // get notified when the user selects the text field in order to clear the text and set the color back to black
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(prepareTextField:)
                                                 name:UITextFieldTextDidBeginEditingNotification
                                               object:self.nameTextField];
    
    [self.mapView moveCamera:[GMSCameraUpdate setTarget:self.currentLocation zoom:16.0f]];
    self.mapView.delegate = self;

}

- (void)viewWillLayoutSubviews
{
    // GMSMapView includes two subviews that the UIImageView is underneath, so it won't display without forcing it up front.
    [self.mapView bringSubviewToFront:self.crosshairs];
}

- (void)prepareTextField:(NSNotification *)userInfo
{
    self.nameTextField.text = nil;
    self.nameTextField.textColor = [UIColor blackColor];
}

// when user clicks Done
- (IBAction)saveLocation:(id)sender
{
    BOOL proceedWithSave = TRUE; // flag to determine if error checks passed
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *alreadySavedLocations = [defaults arrayForKey:userDefaultsSavedLocationsKey];
    NSString *cleanedString = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (![self checkForValidName]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Name Specified"
                                                        message:@"Please specify a name to save this location."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        proceedWithSave = FALSE;
    }
    
    // check that the user hasn't already used the same name
    if ((proceedWithSave) && (alreadySavedLocations != nil)) {
        for (id arrayElement in alreadySavedLocations) {
            NSDictionary *alreadySavedLocation = (NSDictionary *)arrayElement;
            if ([alreadySavedLocation[@"Name"] isEqualToString:cleanedString]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Name Already Used"
                                                                message:@"You already have a saved location by that name. Please choose an alternative name."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                proceedWithSave = FALSE;
                break;
            }
        }
    }
    
    // all tests passed. proceed with save.
    if (proceedWithSave) {
        
        NSDictionary *newLocation = @{
                                      @"Name" : cleanedString,
                                      @"Latitude" : [NSNumber numberWithFloat:self.currentLocation.latitude],
                                      @"Longitude" : [NSNumber numberWithFloat:self.currentLocation.longitude]
                                      };
        
        // if saved locations exist in user defaults, add the new location dictionary to end of that array
        NSArray *arrayToSave;
        if (alreadySavedLocations != nil) {
            arrayToSave = [alreadySavedLocations arrayByAddingObject:newLocation];
        }
        // otherwise create an entirely new array with the location dictionary as the sole object
        else {
            arrayToSave = [NSArray arrayWithObject:newLocation];
        }
        
        [defaults setObject:arrayToSave forKey:userDefaultsSavedLocationsKey];
        [defaults synchronize];
        
        // return to the saved locations screen
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (BOOL)checkForValidName
{
    // check to see if the user hasn't entered anything at all (ie, the default is still the value)
    if ([self.nameTextField.text isEqualToString:defaultNameTextFieldContent]) {
        return FALSE;
    }
    
    // check for just white space or nothing
    if ([[self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        return FALSE;
    }
    
    return TRUE;
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // there's only one button, so no need to check against the value of buttonIndex
    [self.nameTextField becomeFirstResponder];
}

// update the lat/lon readout in real time as the user pans around the map
- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
    self.latlonLabel.text = [NSString stringWithFormat:@"%f, %f", position.target.latitude, position.target.longitude];
}

@end
