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
@property (nonatomic, weak) id<FetcherView> delegate; // once fetch is executed, resulting data is sent to this delegate
@property (strong, nonatomic) NSURLSession *urlSession;
- (void)fetchDataWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude; // essentially an abstract method that all subclasses must implement
@end

// delegate protocol
@protocol FetcherView <NSObject>
@required
- (void)receiveData:(NSArray *)fetchedResults;
@end // end of delegate protocol
