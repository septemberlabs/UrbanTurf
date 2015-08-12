//
//  NewsMap.h
//  UrbanTurf
//
//  Created by Will Smith on 3/25/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "Fetcher.h"
#import "GooglePlacesClient.h"
#import "Article.h"
#import "ArticleOverlayView.h"

@interface NewsMap : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate, FetcherView, GooglePlacesView, GMSMapViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, ArticleOverlayViewDelegate>

@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;

- (void)setLocationWithLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude zoom:(float)zoom;
- (void)setFocusOnMarker:(GMSMarker *)markerToReceiveFocus;

@end
