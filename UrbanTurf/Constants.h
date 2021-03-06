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

extern NSString * const userDefaultsDisplayOrderKey;
+ (NSArray *)displayOrders;
+ (NSArray *)articleAges;
+ (NSArray *)articleTags;
extern NSString * const DISPLAY_ORDER_TABLE_HEADER;
extern NSString * const DISPLAY_ORDER_TABLE_FOOTER;

extern NSString * const ARTICLE_AGE_TABLE_HEADER;
extern NSString * const ARTICLE_AGE_TABLE_FOOTER;

extern NSString * const ARTICLE_TAGS_TABLE_HEADER;
extern NSString * const ARTICLE_TAGS_TABLE_FOOTER;

extern NSString * const userDefaultsHomeScreenLocationKey;
extern NSString * const currentLocationString;

extern NSString * const userDefaultsSavedLocationsKey;

extern NSString * const userDefaultsCityKey;
+ (NSArray *)cities;
extern NSString * const HOME_CITY_TABLE_HEADER;
extern NSString * const HOME_CITY_TABLE_FOOTER;

#pragma mark - UI

extern NSString * const image_not_downloaded;
extern float const FONT_POINT_SIZE;
extern NSString * const map_marker_remoteURL;
extern NSString * const map_marker_currentLocation;
+ (NSArray *)mapMarkersDefault;
+ (NSArray *)mapMarkersSelected;
extern CLLocationDistance const MARKER_OVERLAP_DISTANCE; // distance in meters under which two locations are consolidated under one map marker.
extern CGFloat const PAN_THRESHOLD; // horizontal distance (px) that a pan translation must return before triggering a visual response from the UI.
extern CGFloat const PANNED_DISTANCE_THRESHOLD; // horizontal distance as percentage of view width that user must pan for neighboring article to move in.
extern int const ARTICLE_OVERLAY_VIEW_HEIGHT; // height (px) of articles in table view and in full-map mode.

#pragma mark - API & LOCATION

extern NSString * const API_ADDRESS;
extern int const NUM_OF_RESULTS_LIMIT; // ceiling on number of search results to return from the API.
extern double const BASE_RADIUS_FROM_USER_LOCATION; // radius from user's current location with which to start searching for stories.
extern double const DEFAULT_ZOOM_LEVEL; // default zoom level at which to set the map.
extern NSString * const RADIUS_UNITS; // english or metric for the API.

extern CLLocationDistance const DISTANCE_FILTER; // the default used for CLLocationManager's distanceFilter property. from the docs: "The minimum distance (measured in meters) a device must move horizontally before an update event is generated."

+ (NSDateFormatter *)dateFormatter;

typedef NS_ENUM(NSInteger, SuperviewFeature) {
    None,
    TableCellSeparator
};

@end