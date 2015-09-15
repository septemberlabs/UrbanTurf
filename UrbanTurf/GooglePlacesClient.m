//
//  GooglePlacesClient.m
//  UrbanTurf
//
//  Created by Will Smith on 4/28/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "GooglePlacesClient.h"
#import "Constants.h"

#pragma mark - Constants
NSString * const googlePlacesResultsFormat = @"json";
NSString * const googlePlacesBaseURL = @"https://maps.googleapis.com/maps/api/place/";
NSString * const googlePlacesAutocompletePath = @"autocomplete/";
NSString * const googlePlacesAutocompleteRadius = @"10000";
NSString * const googlePlaceDetailsPath = @"details/";

@implementation GooglePlacesClient

+ (GooglePlacesClient *)sharedGooglePlacesClient
{
    static GooglePlacesClient *_sharedGooglePlacesClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedGooglePlacesClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:googlePlacesBaseURL]];
    });
    
    return _sharedGooglePlacesClient;
}

- (void)getPlacesLike:(NSString *)searchString atLocation:(CLLocationCoordinate2D)locationToSearchAround delegate:(id<GooglePlacesView>)delegate
{
    NSDictionary *params;
    // if location is not (0,0), include it in the API URL.
    if (locationToSearchAround.latitude != 0.0) {
        params = @{
                                 @"input" : searchString,
                                 @"location" : [NSString stringWithFormat:@"%f,%f", locationToSearchAround.latitude, locationToSearchAround.longitude],
                                 @"radius" : googlePlacesAutocompleteRadius,
                                 @"sensor" : @"true",
                                 @"key" : googleAPIKeyForBrowserApplications
                                 };
    }
    else {
        params = @{
                                 @"input" : searchString,
                                 @"radius" : googlePlacesAutocompleteRadius,
                                 @"sensor" : @"true",
                                 @"key" : googleAPIKeyForBrowserApplications
                                 };
    }
    [self GET:[NSString stringWithFormat:@"%@%@", googlePlacesAutocompletePath, googlePlacesResultsFormat]
   parameters:params
      success:^(NSURLSessionDataTask *task, id responseObject) {
          if ([responseObject isKindOfClass:[NSDictionary class]]) {
              NSDictionary *fetchedPlacesList = (NSDictionary *)responseObject;
              NSArray *places = [fetchedPlacesList valueForKeyPath:@"predictions"];
              [delegate receiveGooglePlacesAutocompleteResults:places];
          }
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          NSLog(@"Error: %@ ***** %@ ***** %@", task.originalRequest, task.response, error);
      }];
}

- (void)getPlaceDetails:(NSString *)place_id delegate:(id<GooglePlacesView>)delegate
{
    NSDictionary *params = @{
                             @"placeid" : place_id,
                             @"key" : googleAPIKeyForBrowserApplications
                             };
    
    [self GET:[NSString stringWithFormat:@"%@%@", googlePlaceDetailsPath, googlePlacesResultsFormat]
   parameters:params
      success:^(NSURLSessionDataTask *task, id responseObject) {
          if ([responseObject isKindOfClass:[NSDictionary class]]) {
              NSDictionary *fetchedPlace = (NSDictionary *)responseObject;
              [delegate receiveGooglePlacesPlaceDetails:fetchedPlace];
          }
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          NSLog(@"Error: %@ ***** %@ ***** %@", task.originalRequest, task.response, error);
      }];
}

@end
