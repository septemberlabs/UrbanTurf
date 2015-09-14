//
//  Fetcher.h
//  UrbanTurf
//
//  Created by Will Smith on 11/18/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@protocol FetcherView; // forward declaration

@interface Fetcher : NSObject
@property (nonatomic, weak) id<FetcherView> delegate; // once fetch is executed, resulting data is sent to this delegate.
@property (strong, nonatomic) NSURLSession *urlSession;
- (void)fetchDataAtLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude radius:(float)radius units:(NSString *)units age:(int)age limit:(int)limit order:(NSString *)order; // essentially an abstract method that all subclasses must implement.
- (void)numberOfResultsAtLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude radius:(float)radius units:(NSString *)units age:(int)age; // essentially an abstract method that all subclasses must implement.
@end

// delegate protocol
@protocol FetcherView <NSObject>
@required
- (void)receiveData:(NSArray *)fetchedResults;
- (void)receiveNumberOfResults:(int)numberOfResults latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude radius:(float)radius units:(NSString *)units age:(int)age;
@end // end of delegate protocol
