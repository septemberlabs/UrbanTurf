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
NSString * const googleStaticMapBaseURL = @"https://maps.googleapis.com/maps/api/staticmap?";

#pragma mark - USER DEFAULTS

NSString * const userDefaultsRadiusKey = @"searchRadius";
double const defaultSearchRadius = 0.2;
double const minRadius = 0.1;
double const maxRadius = 2.0;
NSString * const RADIUS_TABLE_HEADER = @"This is the header";
NSString * const RADIUS_TABLE_FOOTER = @"This is the footer";

NSString * const userDefaultsDisplayOrderKey = @"displayOrder";
NSString * const DISPLAY_ORDER_TABLE_HEADER = @"Order to display stories";
NSString * const DISPLAY_ORDER_TABLE_FOOTER = @"The sequence in which stories are displayed is either according to distance from your chosen location, or in reverse chronological order (that is, most recent first).";

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

// UI
float const FONT_POINT_SIZE = 12.0;
NSString * const map_marker_default = @"red marker 48x48";
NSString * const map_marker_selected = @"green marker 48x48";
NSString * const map_marker_insets = @"{0, 0, 0, 0}"; // tried to use this with negative inset values to force extra tappable margin. was too hacky so ultimately went with fatter marker graphics.
CLLocationDistance const MARKER_OVERLAP_DISTANCE = 1.0; // in meters. 91.44 m = 300 ft.
CGFloat const PAN_THRESHOLD = 10;
CGFloat const PANNED_DISTANCE_THRESHOLD = 0.20;
int const ARTICLE_OVERLAY_VIEW_HEIGHT = 135;

NSString * const API_ADDRESS = @"http://app.urbanturf.com/api/articles?";
int const NUM_OF_RESULTS_LIMIT = 100;
double const LATLON_RADIUS = 0.5;
double const DEFAULT_ZOOM_LEVEL = 14.0;

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

+ (NSArray *)mapMarkersDefault
{
    static NSArray *mapMarkersDefault;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mapMarkersDefault = @[@"INVALID",
                              @"red marker 48x48 - 1",
                              @"red marker 48x48 - 2",
                              @"red marker 48x48 - 3",
                              @"red marker 48x48 - 4",
                              @"red marker 48x48 - 5",
                              @"red marker 48x48 - 6",
                              @"red marker 48x48 - 7",
                              @"red marker 48x48 - 8",
                              @"red marker 48x48 - 9",
                              @"red marker 48x48 - 9 plus",
                              ];
    });
    return mapMarkersDefault;
}

+ (NSArray *)mapMarkersSelected
{
    static NSArray *mapMarkersSelected;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mapMarkersSelected = @[@"INVALID",
                               @"green marker 48x48 - 1",
                               @"green marker 48x48 - 2",
                               @"green marker 48x48 - 3",
                               @"green marker 48x48 - 4",
                               @"green marker 48x48 - 5",
                               @"green marker 48x48 - 6",
                               @"green marker 48x48 - 7",
                               @"green marker 48x48 - 8",
                               @"green marker 48x48 - 9",
                               @"green marker 48x48 - 9 plus",
                               ];
    });
    return mapMarkersSelected;
}

@end