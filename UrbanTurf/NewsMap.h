//
//  NewsMap.h
//  UrbanTurf
//
//  Created by Will Smith on 3/25/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Fetcher.h"
#import "GooglePlacesClient.h"

@interface NewsMap : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate, FetcherView, GooglePlacesView>

@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;

@end
