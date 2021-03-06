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

NSString * const userDefaultsDisplayOrderKey = @"displayOrder";
NSString * const DISPLAY_ORDER_TABLE_HEADER = @"Order to display stories";
NSString * const DISPLAY_ORDER_TABLE_FOOTER = @"Stories are listed either according to distance from the center of the map or in reverse chronological order.";

NSString * const ARTICLE_AGE_TABLE_HEADER = @"Display stories from";
NSString * const ARTICLE_AGE_TABLE_FOOTER = @"";

NSString * const ARTICLE_TAGS_TABLE_HEADER = @"Types of stories to display";
NSString * const ARTICLE_TAGS_TABLE_FOOTER = @"";

NSString * const userDefaultsHomeScreenLocationKey = @"homeScreenLocation";
NSString * const currentLocationString = @"Current Location";

NSString * const userDefaultsSavedLocationsKey = @"savedLocations";

NSString * const userDefaultsCityKey = @"city";
NSString * const HOME_CITY_TABLE_HEADER = @"";
NSString * const HOME_CITY_TABLE_FOOTER = @"This is the area that will display by default if your current location is disabled or otherwise unavailable.";

// UI
NSString * const image_not_downloaded = @"placeholder 250x250";
float const FONT_POINT_SIZE = 12.0;
NSString * const map_marker_remoteURL = @"http://septemberlabs.com/apps/hoodie/graphics/marker_googlemaps_remote_38x38.png";
NSString * const map_marker_currentLocation = @"blue marker 72x72";
CLLocationDistance const MARKER_OVERLAP_DISTANCE = 50.0; // in meters. 91.44 m = 300 ft.
CGFloat const PAN_THRESHOLD = 10;
CGFloat const PANNED_DISTANCE_THRESHOLD = 0.20;
int const ARTICLE_OVERLAY_VIEW_HEIGHT = 135;

NSString * const API_ADDRESS = @"http://app.urbanturf.com/api/articles?";
int const NUM_OF_RESULTS_LIMIT = 100;
double const BASE_RADIUS_FROM_USER_LOCATION = 0.5; // meters
double const DEFAULT_ZOOM_LEVEL = 14.0;
NSString * const RADIUS_UNITS = @"metric"; // metric|english

CLLocationDistance const DISTANCE_FILTER = 10; // in meters, so a tenth of a kilometer.

@implementation Constants

// thank you: http://stackoverflow.com/questions/20544616/static-nsarray-of-strings-how-where-to-initialize-in-a-view-controller
+ (NSArray *)cities
{
    static NSArray *cities;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cities = @[
                        @{@"Name" : @"Washington DC",
                          @"CenterLatitude" : [NSNumber numberWithDouble:38.909677], // 16th & P
                          @"CenterLongitude" : [NSNumber numberWithDouble:-77.036518],
                          @"UpperLeftLatitude" : [NSNumber numberWithDouble:39.037085],
                          @"UpperLeftLongitude" : [NSNumber numberWithDouble:-77.211634],
                          @"UpperRightLatitude" : [NSNumber numberWithDouble:39.041352],
                          @"UpperRightLongitude" : [NSNumber numberWithDouble:-76.872431],
                          @"BottomRightLatitude" : [NSNumber numberWithDouble:38.772052],
                          @"BottomRightLongitude" : [NSNumber numberWithDouble:-76.849085],
                          @"BottomRightLatitude" : [NSNumber numberWithDouble:38.782758],
                          @"BottomRightLongitude" : [NSNumber numberWithDouble:-77.199274]},
                        @{@"Name" : @"San Francisco",
                          @"CenterLatitude" : [NSNumber numberWithDouble:37.776692], // annointing Twitter HQ as the center of SF.
                          @"CenterLongitude" : [NSNumber numberWithDouble:-122.4167819],
                          @"UpperLeftLatitude" : [NSNumber numberWithDouble:37.815422],
                          @"UpperLeftLongitude" : [NSNumber numberWithDouble:-122.537361],
                          @"UpperRightLatitude" : [NSNumber numberWithDouble:37.936288],
                          @"UpperRightLongitude" : [NSNumber numberWithDouble:-122.182365],
                          @"BottomRightLatitude" : [NSNumber numberWithDouble:37.601934],
                          @"BottomRightLongitude" : [NSNumber numberWithDouble:-122.096535],
                          @"BottomRightLatitude" : [NSNumber numberWithDouble:37.590509],
                          @"BottomRightLongitude" : [NSNumber numberWithDouble:-122.538048]}
                        ];
    });
    return cities;
}

+ (NSArray *)displayOrders
{
    static NSArray *displayOrders;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        displayOrders = @[
                          @{@"Menu Item" : @"Closest First",
                            @"Value" : [NSNumber numberWithBool:YES],
                            @"API Parameter" : @"nearest"},
                          @{@"Menu Item" : @"Newest First",
                            @"Value" : [NSNumber numberWithBool:NO],
                            @"API Parameter" : @"newest"}
                          ];
    });
    return displayOrders;
}

+ (NSArray *)articleAges
{
    static NSArray *articleAges;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        articleAges = @[
                 @{@"Menu Item" : @"Last 30 Days",
                   @"Value" : [NSNumber numberWithBool:NO],
                   @"API Parameter" : @"30"},
                 @{@"Menu Item" : @"Last Year",
                   @"Value" : [NSNumber numberWithBool:YES],
                   @"API Parameter" : @"365"},
                 @{@"Menu Item" : @"Last 2 Years",
                   @"Value" : [NSNumber numberWithBool:NO],
                   @"API Parameter" : @"730"},
                 @{@"Menu Item" : @"Last 4 Years",
                   @"Value" : [NSNumber numberWithBool:NO],
                   @"API Parameter" : @"1460"},
                 @{@"Menu Item" : @"All Time",
                   @"Value" : [NSNumber numberWithBool:NO],
                   @"API Parameter" : @"-1"}
                 ];
    });
    return articleAges;
}

+ (NSArray *)articleTags
{
    static NSArray *articleTags;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        articleTags = @[
                 @{@"Menu Item" : @"Real Estate & Buildings",
                   @"Value" : [NSNumber numberWithBool:YES],
                   @"API Parameter" : @"real estate"},
                 @{@"Menu Item" : @"Food & Restaurants",
                   @"Value" : [NSNumber numberWithBool:YES],
                   @"API Parameter" : @"food"},
                 @{@"Menu Item" : @"Stores & Retail",
                   @"Value" : [NSNumber numberWithBool:YES],
                   @"API Parameter" : @"retail"}
                 ];
    });
    return articleTags;
}

+ (NSArray *)mapMarkersDefault
{
    static NSArray *mapMarkersDefault;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mapMarkersDefault = @[@"INVALID",
                              @"red marker 72x72 - 1",
                              @"red marker 72x72 - 2",
                              @"red marker 72x72 - 3",
                              @"red marker 72x72 - 4",
                              @"red marker 72x72 - 5",
                              @"red marker 72x72 - 6",
                              @"red marker 72x72 - 7",
                              @"red marker 72x72 - 8",
                              @"red marker 72x72 - 9",
                              @"red marker 72x72 - 9 plus",
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
                               @"red marker 72x72 - 1 selected",
                               @"red marker 72x72 - 2 selected",
                               @"red marker 72x72 - 3 selected",
                               @"red marker 72x72 - 4 selected",
                               @"red marker 72x72 - 5 selected",
                               @"red marker 72x72 - 6 selected",
                               @"red marker 72x72 - 7 selected",
                               @"red marker 72x72 - 8 selected",
                               @"red marker 72x72 - 9 selected",
                               @"red marker 72x72 - 9 plus selected",
                               ];
    });
    return mapMarkersSelected;
}

+ (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"enUSPOSIXLocale"];
        dateFormatter.dateFormat = @"MM-dd-yyyy";
        //dateFormatter.timeStyle = NSDateFormatterNoStyle;
        //dateFormatter.dateStyle = NSDateFormatterShortStyle;
    });
    return dateFormatter;
}

@end