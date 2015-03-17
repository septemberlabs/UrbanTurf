//
//  SaveFavoriteLocation.m
//  UrbanTurf
//
//  Created by Will Smith on 3/11/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "AppDelegate.h"
#import "SaveFavoriteLocation.h"
#import <GoogleMaps/GoogleMaps.h>

@interface SaveFavoriteLocation ()
@property (weak, nonatomic) IBOutlet UIView *locationInfo;
@property (weak, nonatomic) IBOutlet UILabel *latlonLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *mapViewContainingView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;
@end

@implementation SaveFavoriteLocation

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
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
                                               object:self.nameField];
    
    //UIView *newView = [[UIView alloc] initWithFrame:mapViewFrame];
    //newView.backgroundColor = [UIColor blueColor];
    //[self.view addSubview:newView];

    CGRect mapViewFrame = CGRectMake(0, CGRectGetHeight(self.locationInfo.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    GMSCameraPosition *currentlyViewedLocation = [GMSCameraPosition cameraWithTarget:self.currentLocation zoom:16];
    GMSMapView *mapView = [GMSMapView mapWithFrame:mapViewFrame camera:currentlyViewedLocation];
    mapView.delegate = self;
    //self.mapView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.view addSubview:mapView];
    
    UIImageView *crosshairs = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40.0, 40.0)];
    crosshairs.image = [UIImage imageNamed:@"cursor-crosshair"];
    crosshairs.center = CGPointMake(mapView.bounds.size.width / 2, mapView.bounds.size.height / 2);
    [self.view addSubview:crosshairs];
    
    /*
    NSLog(@"mapView bounds: %@", NSStringFromCGRect(self.mapView.bounds));
    NSLog(@"mapView bounds size: %@", NSStringFromCGSize(self.mapView.bounds.size));
    NSLog(@"mapView frame: %@", NSStringFromCGRect(self.mapView.frame));
    NSLog(@"mapView frame size: %@", NSStringFromCGSize(self.mapView.frame.size));
    NSLog(@"mapView center: %@", NSStringFromCGPoint(self.mapView.center));
    NSLog(@"locationInfo bounds: %@", NSStringFromCGRect(self.locationInfo.bounds));
    NSLog(@"locationInfo bounds size: %@", NSStringFromCGSize(self.locationInfo.bounds.size));
    NSLog(@"locationInfo frame: %@", NSStringFromCGRect(self.locationInfo.frame));
    NSLog(@"locationInfo frame size: %@", NSStringFromCGSize(self.locationInfo.frame.size));
    NSLog(@"locationInfo center: %@", NSStringFromCGPoint(self.locationInfo.center));
     */
    
    // HERE HERE
    // 1. remove old SaveFavoriteLocation MVC from storyboard, and all unused variables herein.
    // 2. If someone clicks done without adding a name to save the location with, throw up an alert, remove the text, and place the cursor there.
    // 3. Start laying out options page.
    
    
    
}

- (void)prepareTextField:(NSNotification *)userInfo
{
    self.nameField.text = nil;
    self.nameField.textColor = [UIColor blackColor];
}

- (IBAction)saveLocation:(id)sender {
    
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

- (void) mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
    self.latlonLabel.text = [NSString stringWithFormat:@"%f, %f", position.target.latitude, position.target.latitude];
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
