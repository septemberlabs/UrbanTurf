//
//  Constants.m
//  UrbanTurf
//
//  Created by Will Smith on 3/21/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "Constants.h"
#import <CoreLocation/CoreLocation.h>

// global string constants pattern described here: http://nshipster.com/c-storage-classes/

NSString * const googleAPIKeyForBrowserApplications = @"AIzaSyA0b_bOTi257UdLINlcn7JGOjrSiYM-kBk";
NSString * const googleAPIKeyForiOSApplications = @"AIzaSyDs6Xda8mpENemqpNEkCULatxluYJl0HIc";

#pragma mark - USER DEFAULTS

NSString * const userDefaultsRadiusKey = @"searchRadius";
double const defaultSearchRadius = 0.2;
double const minRadius = 0.1;
double const maxRadius = 2.0;

NSString * const userDefaultsDisplayOrderKey = @"displayOrder";

NSString * const userDefaultsHomeScreenLocationKey = @"homeScreenLocation";

NSString * const userDefaultsSavedLocationsKey = @"savedLocations";

NSString * const userDefaultsVersionKey = @"version";
NSString * const version = @"0.9";

const CLLocationCoordinate2D home = {38.925162, -77.044052};
const CLLocationCoordinate2D lincolnMemorial = {38.889262, -77.048568};
const CLLocationCoordinate2D office = {38.914384, -77.041262};
const CLLocationCoordinate2D kingsCloister = {38.816724, -77.075691};
const CLLocationCoordinate2D jacksonHoleSquare = {43.479990, -110.761819};
//const float LATLON_RADIUS = 0.5; // radius from the given lat/lon for which to return photos
//#define LATLON_RADIUS (0.5) // used to define it thusly in HoodieTVC.m

NSString * const API_ADDRESS = @"http://hoodie.staging.logicbrush.com/api/articles?";
double const LATLON_RADIUS = 0.5;

@implementation Constants

// thank you: http://stackoverflow.com/questions/20544616/static-nsarray-of-strings-how-where-to-initialize-in-a-view-controller
+ (NSArray *)displayOrders
{
    static NSArray *displayOrders;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        displayOrders = @[@"Closest First",
                          @"Newest First"];
    });
    return displayOrders;
}

@end