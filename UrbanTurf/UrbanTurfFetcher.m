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
 count = true; add this if you just want the count of results
 */

#import "UrbanTurfFetcher.h"
#import "Article.h"
#import "Constants.h"

@implementation UrbanTurfFetcher

- (void)fetchDataAtLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude radius:(float)radius units:(NSString *)units age:(int)age limit:(int)limit order:(NSString *)order
{
    NSString *urlToLoad = [NSString stringWithFormat:@"%@near=%f,%f&radius=%f&units=%@&age=%d&limit=%d&order=%@", API_ADDRESS, latitude, longitude, radius, units, age, limit, order];
    NSLog(@"Search results URL we're loading: %@", urlToLoad);
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

- (void)numberOfResultsAtLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude radius:(float)radius units:(NSString *)units age:(int)age
{
    NSString *urlToLoad = [NSString stringWithFormat:@"%@near=%f,%f&radius=%f&units=%@&age=%d&count=true", API_ADDRESS, latitude, longitude, radius, units, age];
    //NSLog(@"Number of results URL we're loading: %@", urlToLoad);
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlToLoad]];
    NSURLSessionDownloadTask *task = [self.urlSession downloadTaskWithRequest:request completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSString *numberOfResults = [NSString stringWithContentsOfURL:localFile encoding:NSASCIIStringEncoding error:nil];
            if (self.delegate && [self.delegate respondsToSelector:@selector(receiveNumberOfResults:latitude:longitude:radius:units:age:)]) {
                [self.delegate receiveNumberOfResults:[numberOfResults intValue] latitude:latitude longitude:longitude radius:radius units:units age:age];
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
