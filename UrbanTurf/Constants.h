//
//  Constants.h
//  UrbanTurf
//
//  Created by Will Smith on 3/21/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

extern NSString * const googleAPIKey;

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

@end