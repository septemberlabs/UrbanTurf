//
//  GooglePlacesClient.h
//  UrbanTurf
//
//  Created by Will Smith on 4/28/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import <CoreLocation/CoreLocation.h>

@protocol GooglePlacesView; // forward declaration

@interface GooglePlacesClient : AFHTTPSessionManager

+ (GooglePlacesClient *)sharedGooglePlacesClient; // get the singleton
- (void)getPlacesLike:(NSString *)searchString atLocation:(CLLocationCoordinate2D)locationToSearchAround delegate:(id<GooglePlacesView>)delegate;
- (void)getPlaceDetails:(NSString *)place_id delegate:(id<GooglePlacesView>)delegate;

// constants
extern NSString * const googlePlacesResultsFormat;
extern NSString * const googlePlacesBaseURL;
extern NSString * const googlePlacesAutocompletePath;
extern NSString * const googlePlacesAutocompleteRadius;
extern NSString * const googlePlaceDetailsPath;

@end


// delegate protocol
@protocol GooglePlacesView <NSObject>
@required
- (void)receiveGooglePlacesAutocompleteResults:(NSArray *)fetchedPlaces;
- (void)receiveGooglePlacesPlaceDetails:(NSDictionary *)fetchedPlace;
@end // end of delegate protocol