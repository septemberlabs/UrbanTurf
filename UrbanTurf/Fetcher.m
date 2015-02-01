//
//  Fetcher.m
//  UrbanTurf
//
//  Created by Will Smith on 11/18/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import "Fetcher.h"

const CLLocationCoordinate2D home = {38.925162, -77.044052};
const CLLocationCoordinate2D lincolnMemorial = {38.889262, -77.048568};
const CLLocationCoordinate2D office = {38.914384, -77.041262};
const CLLocationCoordinate2D kingsCloister = {38.816724, -77.075691};
const CLLocationCoordinate2D jacksonHoleSquare = {43.479990, -110.761819};
//const float LATLON_RADIUS = 0.5; // radius from the given lat/lon for which to return photos
//#define LATLON_RADIUS (0.5) // used to define it thusly in HoodieTVC.m

@implementation Fetcher

- (void)fetchDataWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude {}

- (NSURLSession *)urlSession
{
    if (!_urlSession) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfig.allowsCellularAccess = YES;
        _urlSession = [NSURLSession sessionWithConfiguration:sessionConfig];
    }
    return _urlSession;
}

@end
