//
//  Constants.h
//  UrbanTurf
//
//  Created by Will Smith on 3/21/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface Constants : NSObject

extern NSString * const googleAPIKeyForBrowserApplications;
extern NSString * const googleAPIKeyForiOSApplications;
extern NSString * const googleStaticMapBaseURL;

#pragma mark - USER DEFAULTS

extern NSString * const userDefaultsRadiusKey;
extern double const defaultSearchRadius;
extern double const minRadius;
extern double const maxRadius;
extern NSString * const RADIUS_TABLE_HEADER;
extern NSString * const RADIUS_TABLE_FOOTER;

extern NSString * const userDefaultsDisplayOrderKey;
+ (NSArray *)displayOrders;
extern NSString * const DISPLAY_ORDER_TABLE_HEADER;
extern NSString * const DISPLAY_ORDER_TABLE_FOOTER;

extern NSString * const userDefaultsHomeScreenLocationKey;
extern NSString * const homeScreenLocation;

extern NSString * const userDefaultsSavedLocationsKey;

extern NSString * const userDefaultsVersionKey;
extern NSString * const version;

// constants used for pre-chosen locations
extern CLLocationCoordinate2D const home;
extern CLLocationCoordinate2D const lincolnMemorial;
extern CLLocationCoordinate2D const office;
extern CLLocationCoordinate2D const kingsCloister;
extern CLLocationCoordinate2D const jacksonHoleSquare;
//extern float const LATLON_RADIUS;

// UI
extern float const FONT_POINT_SIZE;
extern NSString * const map_marker_default;
+ (NSArray *)mapMarkersDefault;
extern NSString * const map_marker_selected;
+ (NSArray *)mapMarkersSelected;
extern NSString * const map_marker_insets;
extern CLLocationDistance const MARKER_OVERLAP_DISTANCE; // distance in meters under which two locations are consolidated under one map marker
extern CGFloat const PAN_THRESHOLD; // horizontal distance (px) that a pan translation must return before triggering a visual response from the UI.
extern CGFloat const PANNED_DISTANCE_THRESHOLD; // horizontal distance as percentage of view width that user must pan for neighboring article to move in.

extern NSString *const API_ADDRESS;
extern double const LATLON_RADIUS; // default radius from the given lat/lon for which to return items
extern double const DEFAULT_ZOOM_LEVEL; // default zoom level at which to set the map

@end