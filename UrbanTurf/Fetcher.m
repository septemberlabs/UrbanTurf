//
//  Fetcher.m
//  UrbanTurf
//
//  Created by Will Smith on 11/18/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import "Fetcher.h"

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
