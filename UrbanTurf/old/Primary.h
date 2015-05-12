//
//  HoodieVC.h
//  UrbanTurf
//
//  Created by Will Smith on 11/20/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Fetcher.h"

@interface Primary : UIViewController <UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, FetcherView>

@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;

@end
