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
#import "SearchFilters.h"
#import "ArticleContainer.h"

@interface NewsMap : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate, FetcherView, GooglePlacesView, GMSMapViewDelegate, UIScrollViewDelegate, ArticleOverlayViewDelegate, SearchFiltersDelegate, CLLocationManagerDelegate, UIAlertViewDelegate>

@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;

- (void)setLocationWithLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude zoom:(float)zoom;
- (void)setFocusOnArticleContainer:(ArticleContainer *)articleContainerToReceiveFocus;
- (void)loadArticle:(UITapGestureRecognizer *)gestureRecognizer;

@end
