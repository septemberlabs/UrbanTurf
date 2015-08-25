//
//  UrbanTurfFetcher.m
//  UrbanTurf
//
//  Created by Will Smith on 12/23/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

/*
 near = lat,lon; required
 radius = to two decimal places; required; in units specified by unit
 units = “metric”|“english”; optional; “english” is default
 limit = integer; optional; 10 is default
 age = number of days old, integer; -1 is all time
 order = newest/nearest
 */


#import "UrbanTurfFetcher.h"
#import "Article.h"
#import "Constants.h"

@implementation UrbanTurfFetcher

- (void)fetchDataWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude radius:(float)radius units:(NSString *)units limit:(int)limit age:(int)age order:(NSString *)order
{
    if ((latitude == 0) || (longitude == 0)) {
        CLLocationCoordinate2D testLocation = office;
        latitude = testLocation.latitude;
        longitude = testLocation.longitude;
    }
    
    NSString *urlToLoad = [NSString stringWithFormat:@"%@near=%f,%f&radius=%f&units=metric&limit=%d&age=%d&order=%@", API_ADDRESS, latitude, longitude, radius, limit, age, order];
    NSLog(@"URL we're loading: %@", urlToLoad);
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlToLoad]];
    NSURLSessionDownloadTask *task = [self.urlSession downloadTaskWithRequest:request completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
                    if (!error) {
                        NSDictionary *fetchedPropertyList;
                        NSData *fetchedJSONData = [NSData dataWithContentsOfURL:localFile]; // will block if url is not local!
                        if (fetchedJSONData) {
                            fetchedPropertyList = [NSJSONSerialization JSONObjectWithData:fetchedJSONData options:0 error:NULL];
                        }
                        NSArray *articles = [fetchedPropertyList valueForKeyPath:@"data"];
                        if (self.delegate && [self.delegate respondsToSelector:@selector(receiveData:)]) {
                            [self.delegate receiveData:articles];
                        }
                    }
                    else {
                        NSLog(@"Fetch failed: %@", error.localizedDescription);
                        NSLog(@"Fetch failed: %@", error.userInfo);
                    }
                }];
    [task resume];
}

- (int)numberOfResultsAtLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude radius:(float)radius units:(NSString *)units age:(int)age
{
    NSString *urlToLoad = [NSString stringWithFormat:@"%@near=%f,%f&radius=%f&units=metric&limit=%d&age=%d", API_ADDRESS, latitude, longitude, radius, limit, age];
    NSLog(@"URL we're loading: %@", urlToLoad);
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlToLoad]];
    NSURLSessionDownloadTask *task = [self.urlSession downloadTaskWithRequest:request completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSDictionary *fetchedPropertyList;
            NSData *fetchedJSONData = [NSData dataWithContentsOfURL:localFile]; // will block if url is not local!
            if (fetchedJSONData) {
                fetchedPropertyList = [NSJSONSerialization JSONObjectWithData:fetchedJSONData options:0 error:NULL];
            }
            NSArray *articles = [fetchedPropertyList valueForKeyPath:@"data"];
            if (self.delegate && [self.delegate respondsToSelector:@selector(receiveData:)]) {
                [self.delegate receiveData:articles];
            }
        }
        else {
            NSLog(@"Fetch failed: %@", error.localizedDescription);
            NSLog(@"Fetch failed: %@", error.userInfo);
        }
    }];
    [task resume];
}

@end
