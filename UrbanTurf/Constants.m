//
//  Constants.m
//  UrbanTurf
//
//  Created by Will Smith on 3/21/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "Constants.h"

// global string constants pattern described here: http://nshipster.com/c-storage-classes/

NSString * const googleAPIKey = @"AIzaSyDs6Xda8mpENemqpNEkCULatxluYJl0HIc";

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