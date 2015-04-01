//
//  Constants.h
//  UrbanTurf
//
//  Created by Will Smith on 3/21/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Constants : NSObject

extern NSString * const googleAPIKeyForBrowserApplications;
extern NSString * const googleAPIKeyForiOSApplications;

#pragma mark - USER DEFAULTS

extern NSString * const userDefaultsRadiusKey;
extern double const defaultSearchRadius;
extern double const minRadius;
extern double const maxRadius;

extern NSString * const userDefaultsDisplayOrderKey;
+ (NSArray *)displayOrders;

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

extern NSString *const API_ADDRESS;
extern double const LATLON_RADIUS; // default radius from the given lat/lon for which to return items

@end