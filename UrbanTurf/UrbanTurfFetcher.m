//
//  UrbanTurfFetcher.m
//  UrbanTurf
//
//  Created by Will Smith on 12/23/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import "UrbanTurfFetcher.h"
#import "Article.h"
#import "Constants.h"

@implementation UrbanTurfFetcher

- (void)fetchDataWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude
{
    [self fetchDataWithLatitude:latitude longitude:longitude radius:LATLON_RADIUS]; // use default radius if none specified
}

- (void)fetchDataWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude radius:(float)radius
{
    if ((latitude == 0) || (longitude == 0)) {
        CLLocationCoordinate2D testLocation = office;
        latitude = testLocation.latitude;
        longitude = testLocation.longitude;
    }
    
    NSString *urlToLoad = [NSString stringWithFormat:@"%@near=%f,%f&radius=%f&limit=%d&units=metric", API_ADDRESS, latitude, longitude, radius, NUM_OF_RESULTS_LIMIT];
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
