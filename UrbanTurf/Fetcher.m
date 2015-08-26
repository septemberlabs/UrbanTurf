//
//  Fetcher.m
//  UrbanTurf
//
//  Created by Will Smith on 11/18/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import "Fetcher.h"

@implementation Fetcher

- (void)fetchDataAtLatidude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude radius:(float)radius units:(NSString *)units age:(int)age limit:(int)limit order:(NSString *)order {}

- (void)numberOfResultsAtLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude radius:(float)radius units:(NSString *)units age:(int)age {}

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
