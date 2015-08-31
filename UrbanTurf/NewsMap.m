//
//  NewsMap.m
//  UrbanTurf
//
//  Created by Will Smith on 3/25/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "NewsMap.h"
#import "Constants.h"
#import "UrbanTurfFetcher.h"
#import "Stylesheet.h"
#import "GooglePlacesClient.h"
#import "UIImageView+AFNetworking.h"
#import "ArticleOverlayView.h"
#import "NewsMapTableViewCell.h"
#import "ArticleViewController.h"
#import "UIView+AddBorders.h"
#import <Crashlytics/Crashlytics.h>

@interface NewsMap ()

/*
 these two arrays comprise the model. self.articles is the result of the fetch and is an arry of articles. we construct the array of articleContainers after first populating self.articles. an articleContainer stores the article(s) whose location the articleContainer's marker visually represents on the map. because some articles have locations that are very close or identical, we cluster such articles in a single articleContainer, represented visusally by a single marker. in such cases, the articleContainer's articles array contain multiple elements. therefore, there is a one-to-many relationship between articleContainers and articles, not one-to-one. this relationship is managed and contained by articleContainer. there IS a one-to-one relationship between articleContainers and the rows in the table view (and markers on the map; each articleContainer contains only one marker). for cells that represent articleContainers with multiple stories at its location, the cell is pannable, with the stories ordered in reverse chronological order.
 */
@property (strong, nonatomic) NSMutableArray *articles; // of Articles
@property (strong, nonatomic) NSMutableArray *articleContainers; // of ArticleContainers

@property (strong, nonatomic) Fetcher *fetcher; // fetches data

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL locationAwarenessEnabled;

@property (weak, nonatomic) IBOutlet UIButton *toggleViewButton; // button to right of search field.
@property (weak, nonatomic) IBOutlet UIButton *searchFiltersButton; // button to left of search field.

// data structures related to search field.
@property (strong, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) NSMutableArray *recentSearches; // of NSString

// UI components.
@property (strong, nonatomic) GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *mapContainerView;
@property (strong, nonatomic) GMSMarker *currentLocationMarker;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) CGFloat originalMapViewBottomEdgeY;
@property (nonatomic, strong) CALayer *borderBetweenMapAndTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapContainerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) ArticleContainer *articleContainerWithFocus; // article container with current focus, if any. list-view mode.

// search filters.
@property (strong, nonatomic) NSArray *displayOrders;
@property (strong, nonatomic) NSArray *articleAges;
@property (strong, nonatomic) NSArray *articleTags;

// related to panning cells that represent multiple articles.
@property (nonatomic) BOOL shouldRecognizeSimultaneouslyWithGestureRecognizer;
@property (strong, nonatomic) NSMutableArray *tableViewPanGestureRecognizers; // we save all the pan GRs so that we can deactivate them when the table view starts scrolling vertically.

// various states and constraints of the UI related to the article overlay effect in full-map mode.
@property (nonatomic) BOOL listView;
@property (nonatomic) BOOL articleOverlaid;
@property (strong, nonatomic) GMSMarker *tappedMarker;
@property (strong, nonatomic) IBOutlet UIView *articleOverlay;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *articleOverlayTopEdgeConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *articleOverlayHeightConstraint;

// alert views related to location awareness checking.
@property (strong, nonatomic) UIAlertView *cityPrompt;
@property (strong, nonatomic) UIAlertView *noLocationAwarenessAcknowledgement;

// state to track whether we're in the launch process.
@property (nonatomic) BOOL clearDataAndMapUponFetchReturn;

typedef NS_ENUM(NSInteger, LocationUnavailableReason) {
    LocationServicesTurnedOff,
    PermissionDeniedRightNow,
    PermissionAlreadyDenied
};

typedef NS_ENUM(NSInteger, ArticlePanDirection) {
    Left,
    Right,
    SnapBack
};

@end

@implementation NewsMap


#define CHARACTERS_BEFORE_SEARCHING 3
static CGFloat const extraMarginForSearchRadius = 0.20; // 20 percent.
@synthesize searchResults = _searchResults;


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // turn off the navigation bar, which we only want to see when we load an article.
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // configure the table view
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // map view button
    [self.toggleViewButton.titleLabel setFont:[UIFont fontWithName:[Stylesheet fonticons] size:[Stylesheet searchBarFontIconSize]]];
    [self.toggleViewButton setTitleColor:[Stylesheet color1] forState:UIControlStateNormal];
    [self.toggleViewButton setTitle:[NSString stringWithUTF8String:"\ue80f"] forState:UIControlStateNormal];
    
    // search filters button
    [self.searchFiltersButton.titleLabel setFont:[UIFont fontWithName:[Stylesheet fonticons] size:[Stylesheet searchBarFontIconSize]]];
    [self.searchFiltersButton setTitleColor:[Stylesheet color1] forState:UIControlStateNormal];
    [self.searchFiltersButton setTitle:[NSString stringWithUTF8String:"\ue804"] forState:UIControlStateNormal];
    
    // search filters. see Constants.m for the values each array element represents.
    self.displayOrders = [Constants displayOrders];
    self.articleAges = [Constants articleAges];
    self.articleTags = [Constants articleTags];

    self.searchDisplayController.searchBar.tintColor = [Stylesheet color1];
    
    // by default the table view is displayed.
    self.listView = YES;
    
    // hide the spinner unless necessary.
    //self.spinner.hidden = YES;
    self.spinner.hidesWhenStopped = YES;
    
    self.articleOverlaid = NO;
    self.tappedMarker = nil;
    self.originalMapViewBottomEdgeY = self.tableView.frame.origin.y;
    
    self.shouldRecognizeSimultaneouslyWithGestureRecognizer = YES;
    self.tableViewPanGestureRecognizers = [[NSMutableArray alloc] init];
    
    // this sets the back button text of the subsequent vc, not the visible vc. confusing.
    // thank you: https://dbrajkovic.wordpress.com/2012/10/31/customize-the-back-button-of-uinavigationitem-in-the-navigation-bar/
    //self.navigationBar.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //[self fetchData];
    
    self.clearDataAndMapUponFetchReturn = YES;
    
    self.locationAwarenessEnabled = NO;
    [self establishLocationAwarenessPermissions];
}

- (GMSMapView *)mapView
{
    if (!_mapView) {
        
        GMSCameraPosition *cameraPosition = [[GMSCameraPosition alloc] initWithTarget:(CLLocationCoordinate2DMake(self.latitude, self.longitude)) zoom:DEFAULT_ZOOM_LEVEL bearing:0 viewingAngle:0];
        
        // instantiate and configure the map.
        self.mapView = [GMSMapView mapWithFrame:self.mapContainerView.bounds camera:cameraPosition];
        self.mapView.translatesAutoresizingMaskIntoConstraints = NO;
        self.mapView.delegate = self;
        self.mapView.settings.myLocationButton = NO;
        self.mapView.indoorEnabled = NO; // disabled this to suppress the random error "Encountered indoor level with missing enclosing_building field" we were getting.
        
        // add it the screen.
        [self.mapContainerView addSubview:self.mapView];

        // add the bottom border for a hairline separation between the map and table view.
        self.borderBetweenMapAndTable = [self.mapView addBorder:UIRectEdgeBottom color:[Stylesheet color5] thickness:0.5f];
        
        // finally, pin the map view to the edges of the map container view.
        UIView *subview = self.mapView;
        UIView *superview = self.mapContainerView;
        NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:subview
                                                                             attribute:NSLayoutAttributeLeading
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:superview
                                                                             attribute:NSLayoutAttributeLeading
                                                                            multiplier:1.0
                                                                              constant:0];
        NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:subview
                                                                              attribute:NSLayoutAttributeTrailing
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:superview
                                                                              attribute:NSLayoutAttributeTrailing
                                                                             multiplier:1.0
                                                                               constant:0];
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:subview
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:superview
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0
                                                                          constant:0];
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:subview
                                                                            attribute:NSLayoutAttributeBottom
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:superview
                                                                            attribute:NSLayoutAttributeBottom
                                                                           multiplier:1.0
                                                                             constant:0];
        
        NSArray *arrayOfConstraints = [NSArray arrayWithObjects:leadingConstraint, trailingConstraint, topConstraint, bottomConstraint, nil];
        
        for (NSLayoutConstraint *constraint in arrayOfConstraints) {
            [superview addConstraint:constraint];
        }
    }

    return _mapView;
}

#define SEARCH_RESULTS_MINIMUM 5
#define INCREMENT_TO_RADIUS 1.0
#define MAX_RADIUS_TO_SEARCH 4.0
//The purpose of this method is to show SEARCH_RESULTS_MINIMUM pieces of news on the map near user's current location. Increase the radius by INCREMENT_TO_RADIUS and try again if the current radius doesn't yield SEARCH_RESULTS_MINIMUM results. Repeat until we have at least SEARCH_RESULTS_MINIMUM results or the radius is greater than MAX_RADIUS_TO_SEARCH, in which case we prompt the user to select one of the hard-coded city options.
- (void)receiveNumberOfResults:(int)numberOfResults latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude radius:(float)radius units:(NSString *)units age:(int)age
{
    // if the number of search results at this radius is SEARCH_RESULTS_MINIMUM or more, display the map.
    if (numberOfResults >= SEARCH_RESULTS_MINIMUM) {
        [self setLocationWithLatitude:latitude andLongitude:longitude zoom:DEFAULT_ZOOM_LEVEL];
        NSLog(@"Made it!");
    }
    // otherwise, extend the map
    else {
        float newRadius = radius + INCREMENT_TO_RADIUS; // add INCREMENT_TO_RADIUS kilometers of radius each time to expand the scope of search results.
        if (newRadius < MAX_RADIUS_TO_SEARCH) { // the max radius we want to expand to before giving up is MAX_RADIUS_TO_SEARCH.
            [self.fetcher numberOfResultsAtLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude radius:newRadius units:units age:age];
        }
        else {
            [self promptForOrGoToCity];
        }
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    // we add this here so that we don't have to change it in Interface Builder too when/if we tweak the value. IB has a value for it which is close to ARTICLE_OVERLAY_VIEW_HEIGHT but, because of this line of code, disregarded and ultimately totally irrelevant.
    self.articleOverlayHeightConstraint.constant = ARTICLE_OVERLAY_VIEW_HEIGHT;
}

- (void)establishLocationAwarenessPermissions
{
    // if location services are turned on, check permissions.
    if ([CLLocationManager locationServicesEnabled]) {
        
        CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
        
        switch (authorizationStatus) {
            case kCLAuthorizationStatusNotDetermined:
                NSLog(@"kCLAuthorizationStatusNotDetermined reported in establishLocationAwarenessPermissions.");
                // this means the user hasn't yet specified permission one way or the other, so we call requestWhenInUseAuthorization, which will prompt the user for permission.
                self.locationAwarenessEnabled = NO;
                [self.locationManager requestWhenInUseAuthorization];
                break;
            case kCLAuthorizationStatusRestricted:
                NSLog(@"kCLAuthorizationStatusRestricted reported in establishLocationAwarenessPermissions.");
                // we don't have permission so proceed with fallback.
                self.locationAwarenessEnabled = NO;
                [self processLackOfLocationAwareness:PermissionAlreadyDenied];
                break;
            case kCLAuthorizationStatusDenied:
                NSLog(@"kCLAuthorizationStatusDenied reported in establishLocationAwarenessPermissions.");
                // we don't have permission so proceed with fallback.
                self.locationAwarenessEnabled = NO;
                [self processLackOfLocationAwareness:PermissionAlreadyDenied];
                break;
            case kCLAuthorizationStatusAuthorized: // kCLAuthorizationStatusAuthorized == kCLAuthorizationStatusAuthorizedAlways
                NSLog(@"kCLAuthorizationStatusAuthorized reported in establishLocationAwarenessPermissions.");
                // we have permission so turn on location awareness.
                self.locationAwarenessEnabled = YES;
                [self.locationManager startUpdatingLocation];
                break;
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                NSLog(@"kCLAuthorizationStatusAuthorizedWhenInUse reported in establishLocationAwarenessPermissions.");
                // we have permission so turn on location awareness.
                self.locationAwarenessEnabled = YES;
                [self.locationManager startUpdatingLocation];
                break;
        }
    }
    // if location services aren't turned on, proceed with fallback.
    else {
        [self processLackOfLocationAwareness:LocationServicesTurnedOff];
    }
}

- (void)processLackOfLocationAwareness:(LocationUnavailableReason)reason
{
    // the user has location services turned off altogether.
    if (reason == LocationServicesTurnedOff) {
        self.noLocationAwarenessAcknowledgement = [[UIAlertView alloc] initWithTitle:@"Location Services Are Off"
                                                                         message:@"You can turn on location awareness under your phone's Settings at any time. (We recommend it!)"
                                                                        delegate:self
                                                               cancelButtonTitle:@"Got it"
                                                               otherButtonTitles:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.noLocationAwarenessAcknowledgement show];
        });
    }
    // the user was just asked to allow location awareness, and said no.
    if (reason == PermissionDeniedRightNow) {
        self.noLocationAwarenessAcknowledgement = [[UIAlertView alloc] initWithTitle:@"Bummer!"
                                                                         message:@"The app works better if it knows your location. If you change your mind, go to your phone's Settings to turn on location awareness at any time."
                                                                        delegate:self
                                                               cancelButtonTitle:@"Got it"
                                                               otherButtonTitles:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.noLocationAwarenessAcknowledgement show];
        });
    }
    // the user was asked at an earlier date to allow location awareness, and said no. so we don't communicate anything since we already did so the first time around.
    if (reason == PermissionAlreadyDenied) {
        [self promptForOrGoToCity];
    }
}

// this method checks user defaults to see if the user selected a city at some previous date, in which case we go there directly. otherwise we prompt the user to select a city, then save that in user defaults (in UIAlertViewDelegate delegate method clickedButtonAtIndex: below).
- (void)promptForOrGoToCity
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:userDefaultsCityKey] != nil) {
        NSDictionary *city = (NSDictionary *)[[Constants cities] objectAtIndex:[defaults integerForKey:userDefaultsCityKey]];
        CLLocationDegrees cityCenterLatitude = ((NSNumber *)[city objectForKey:@"CenterLatitude"]).doubleValue;
        CLLocationDegrees cityCenterLongitude = ((NSNumber *)[city objectForKey:@"CenterLongitude"]).doubleValue;
        [self setLocationWithLatitude:cityCenterLatitude andLongitude:cityCenterLongitude zoom:12];
    }
    else {
        [self promptToSelectCity];
    }
}

// just the prompt for the user to select a city.
- (void)promptToSelectCity
{
    self.cityPrompt = [[UIAlertView alloc] initWithTitle:@"Choose A City"
                                                        message:@"Choose the city you'd like to view."
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil];
    for (NSDictionary *city in [Constants cities]) {
        NSString *cityName = (NSString *)[city objectForKey:@"Name"];
        [self.cityPrompt addButtonWithTitle:cityName];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.cityPrompt show];
    });
}

#pragma mark - UIAlertViewDelegate

// we check which alertView was clicked in order to know how to proceed.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // we don't check which index because there is only one button on self.noLocationAwarenessAcknowledgement.
    if ([alertView isEqual:self.noLocationAwarenessAcknowledgement]) {
        [self promptForOrGoToCity];
    }
    
    // the prompt to select a city.
    if ([alertView isEqual:self.cityPrompt]) {
        NSDictionary *selectedCity = (NSDictionary *)[[Constants cities] objectAtIndex:buttonIndex];
        NSLog(@"selected city: %@", [selectedCity objectForKey:@"Name"]);
        CLLocationDegrees latitude = ((NSNumber *)[selectedCity objectForKey:@"CenterLatitude"]).doubleValue;
        CLLocationDegrees longitude = ((NSNumber *)[selectedCity objectForKey:@"CenterLongitude"]).doubleValue;
        [self setLocationWithLatitude:latitude andLongitude:longitude zoom:DEFAULT_ZOOM_LEVEL];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:buttonIndex forKey:userDefaultsCityKey];
        [defaults synchronize];
    }
}

#pragma mark - Accessors

- (Fetcher *)fetcher
{
    if (!_fetcher) {
        _fetcher = [[UrbanTurfFetcher alloc] init];
        _fetcher.delegate = self;
    }
    return _fetcher;
}

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 250; // in meters, so a quarter of a kilometer.
    }
    return _locationManager;
}

- (NSArray *)searchResults
{
    if (!_searchResults) {
        _searchResults = [NSArray array];
    }
    return _searchResults;
}

- (NSArray *)articles
{
    if (!_articles) {
        _articles = [[NSMutableArray alloc] init];
    }
    return _articles;
}

- (NSArray *)markers
{
    if (!_articleContainers) {
        _articleContainers = [[NSMutableArray alloc] init];
    }
    return _articleContainers;
}

- (void)setSearchResults:(NSArray *)searchResults
{
    _searchResults = searchResults;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.searchDisplayController.searchResultsTableView reloadData];
    });
}

- (NSMutableArray *)recentSearches
{
    if (!_recentSearches) {
        _recentSearches = [[NSMutableArray alloc] init];
    }
    return _recentSearches;
}

// this method actually just moves the map to the given lat/lon. it is in idleAtCameraPosition where self.latitude and self.longitude are actually set with the new values (and where the model is updated with new data).
- (void)setLocationWithLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude zoom:(float)zoom
{
    // if the caller wants to control the zoom level, it will be a positive value. otherwise it will be -1.
    if (zoom > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mapView animateToCameraPosition:[GMSCameraPosition cameraWithLatitude:latitude longitude:longitude zoom:zoom bearing:0 viewingAngle:0]];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mapView animateToCameraPosition:[GMSCameraPosition cameraWithLatitude:latitude longitude:longitude zoom:self.mapView.camera.zoom bearing:0 viewingAngle:0]];
        });
    }
}

#pragma mark - Fetching

- (void)fetchData
{
    [self.fetcher fetchDataAtLatitude:self.latitude longitude:self.longitude radius:[self radiusToSearch] units:RADIUS_UNITS age:[self getSelectedArticleAge] limit:NUM_OF_RESULTS_LIMIT order:[self getSelectedDisplayOrder]];
    [self.spinner startAnimating];
}

// loop through self.displayOrders and set days to item whose "Value" is set to YES.
- (NSString *)getSelectedDisplayOrder
{
    NSString *order;
    for (NSDictionary *displayOrder in self.displayOrders) {
        if (((NSNumber *)[displayOrder objectForKey:@"Value"]).boolValue) {
            order = (NSString *)[displayOrder objectForKey:@"API Parameter"];
            break;
        }
    }
    return order;
}

// loop through self.articleAges and set days to item whose "Value" is set to YES.
- (int)getSelectedArticleAge
{
    int days = -1;
    for (NSDictionary *articleAge in self.articleAges) {
        if (((NSNumber *)[articleAge objectForKey:@"Value"]).boolValue) {
            days = ((NSString *)[articleAge objectForKey:@"API Parameter"]).intValue;
            break;
        }
    }
    return days;
}


- (void)receiveData:(NSArray *)fetchedResults
{
    //NSLog(@"fetchedResults called.");
    NSMutableArray *processedFromJSON = [NSMutableArray arrayWithCapacity:[fetchedResults count]];
    //NSLog(@"results: %@", fetchedResults);
    NSDateFormatter *dateFormatter = [Constants dateFormatter];
    for (NSDictionary *article in fetchedResults) {
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake([article[@"latitude"] doubleValue], [article[@"longitude"] doubleValue]);
        Article *processedArticle = [[Article alloc] initWithTitle:article[@"headline"] Location:location];
        processedArticle.url = article[@"website"];
        processedArticle.imageURL = article[@"image_url"];
        processedArticle.introduction = article[@"intro"];
        processedArticle.publication = article[@"website_name"];
        processedArticle.date = [dateFormatter dateFromString:article[@"article_date"]];
        processedArticle.article_id = article[@"id"];
        [processedFromJSON addObject:processedArticle];
    }
    
    // if the user updating the search filters is what triggered the fetch, we purge the data and clear the map (rather than appending the results of the new fetch to the existing data and adding them to the map).
    if (self.clearDataAndMapUponFetchReturn) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mapView clear];
            if (self.currentLocationMarker != nil) {
                self.currentLocationMarker.map = self.mapView;
            }
        });
        self.articles = [NSMutableArray array];
        self.articleContainers = [NSMutableArray array];
    }
    // if self.clearDataAndMapUponFetchReturn was NO, set it back to the default of YES.
    else {
        self.clearDataAndMapUponFetchReturn = YES;
    }
    
    // first update the data.
    [self updateDataWithArray:[processedFromJSON copy]];
    // then update the UI (i.e., map and table view).
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateMarkersOnMap];
        [self.tableView reloadData]; // update the tableview
        [self.spinner stopAnimating];
    });
}

#pragma mark - TVC methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableView) {
        return 1;
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if ([self.searchDisplayController.searchBar.text length] < CHARACTERS_BEFORE_SEARCHING) {
            if ([self numberOfRecentSearchesToDisplay]) return 2; // two sections if there are recent searches
            else return 1;
        }
        else {
            return 1;
        }
    }
    
    return 0;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // the article containers all contain a single map marker, which correlate one-to-one with the cells in the table view.
    if (tableView == self.tableView) {
        return [self.articleContainers count] + 1; // the extra one is for the last cell, a spacer cell.
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if ([self.searchDisplayController.searchBar.text length] < CHARACTERS_BEFORE_SEARCHING) {
            if ([self numberOfRecentSearchesToDisplay]) {
                if (section == 0) {
                    return [self numberOfRecentSearchesToDisplay];
                }
                else {
                    return (1 + [self numberOfSavedLocationsToDisplay]); // current location plus saved locations
                }
            }
            else {
                return (1 + [self numberOfSavedLocationsToDisplay]); // current location plus saved locations
            }
        }
        else {
            return [self.searchResults count];
        }
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return nil;
    }
    
    // if the table view sending the message is the search controller TVC.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        // displaying the pre-search results options.
        if ([self.searchDisplayController.searchBar.text length] < CHARACTERS_BEFORE_SEARCHING) {
            
            // if there are recent searches, the first section will be those. if not, the first (and only) section will be saved locations.
            if ([self numberOfRecentSearchesToDisplay]) {
                if (section == 0) {
                    return @"Recent searches";
                }
                else {
                    return @"Saved locations";
                }
            }
            else {
                return @"Saved locations";
            }
        }
        // displaying the search results.
        else {
            return @"Matching places";
        }
        
    }
    
    return 0;
}

- (NSInteger)numberOfRecentSearchesToDisplay
{
    if ([self.recentSearches count] > 3) {
        return 3;
    }
    else {
        return [self.recentSearches count];
    }
}

- (NSInteger)numberOfSavedLocationsToDisplay
{
    NSArray *savedLocations = [[NSUserDefaults standardUserDefaults] arrayForKey:userDefaultsSavedLocationsKey];
    if ([savedLocations count] > 3) {
        return 3;
    }
    else {
        return [savedLocations count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // if the table view sending the message is the articles table view.
    if (tableView == self.tableView) {
        // if the row is the last one, it's the bottom buffer cell so give it an arbitrarily tall height.
        if (indexPath.row == [self.articleContainers count]) {
            return 300;
        }
        // otherwise, give it the standard height for all the article table cells.
        else {
            //return TOP_CAPTION_HEIGHT + IMAGE_HEIGHT + BOTTOM_CAPTION_HEIGHT + VERTICAL_MARGIN;
            return ARTICLE_OVERLAY_VIEW_HEIGHT;
        }
    }
    
    // if the table view sending the message is the search controller TVC
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return tableView.rowHeight;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // if the table view sending the message is the articles table view.
    if (tableView == self.tableView) {
        
        // this is a unique cell, the last one, and doesn't need much configuration.
        if (indexPath.row == [self.articleContainers count]) {
            static NSString *LastCellIdentifier = @"Last Cell - Spacer";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LastCellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LastCellIdentifier];
            }
            return cell;
        }
        
        // The way this works is we have a custom UITableViewCell class called NewsMapTableViewCell. The table view prototype cell's custom class in the storyboard is set to this class, as is its identifier. The NewsMapTableViewCell class is simply a container view of a single ArticleOverlayView subview called articleView. ArticleOverlayView is the owner of the correspondingly named xib. In this way we have one custom view designed in a xib (ArticleOverlayView.xib) that can be used both in the table view and as the view that slides up when a marker is tapped in full screen map mode. (The reason we don't simply make the table view prototype cell's custom class ArticleOverlayView is that that would force ArticleOverlayView to be subclassed from UITableViewCell, which we don't want.) Thank you: http://www.pumpmybicep.com/2014/07/21/designing-a-custom-uitableviewcell-in-interface-builder/
        static NSString *cellIdentifier = @"NewsMapTableViewCell";
        NewsMapTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        // if (cell == nil) {}  don't need to check for nil according to second paragraph under Listing 4-3 here: https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TableView_iPhone/CreateConfigureTableView/CreateConfigureTableView.html#//apple_ref/doc/uid/TP40007451-CH6-SW5

        // if we get a recycled cell, the old articleView is likely still there. we check for it, then its presence in the subviews array. if it's there, we remove it.
        if (cell.articleView) {
            if ([cell.subviews containsObject:cell.articleView]) {
                [cell.articleView removeFromSuperview];
            }
        }
        
        ArticleOverlayView *articleOverlaySubview = [[ArticleOverlayView alloc] initWithFrame:cell.frame];
        articleOverlaySubview.delegate = self;
        articleOverlaySubview.translatesAutoresizingMaskIntoConstraints = NO;
        [cell addSubview:articleOverlaySubview];
        [articleOverlaySubview setEdgesToSuperview:cell leading:0 trailing:0 top:0 bottom:0 superviewFeature:TableCellSeparator];
        cell.articleView = articleOverlaySubview;
        
        ArticleContainer *articleContainer = (ArticleContainer *)self.articleContainers[indexPath.row];

        Article *article = (Article *)[articleContainer articleOfDisplayedTeaser];
        [articleOverlaySubview configureTeaserForArticle:article];

        // this ensures that the background color is reset, lest it be colored due to reuse of a scroll-selected cell.
        articleOverlaySubview.backgroundColor = [UIColor whiteColor];
        
        // add the gesture recognizer if the cell corresponds to a marker that has multiple articles.
        if ([articleContainer.articles count] > 1) {
            [articleOverlaySubview addPanGestureRecognizer];
            articleOverlaySubview.delegate = self;
        }
        
        //NSLog(@"subviews of row %d: %@", (int)indexPath.row, cell.subviews);
        int i = 1;
        for (UIView *subview in cell.subviews) {
            if ([subview isKindOfClass:[articleOverlaySubview class]]) {
                //NSLog(@"Row %d. %d: %@", (int)indexPath.row, i, subview);
                i++;
            }
        }
        if (i >= 3) {
            NSLog(@"table cell has too many articleOverlaySubviews! (%d to be exact.)", i);
            [[Crashlytics sharedInstance] crash];
        }

        return cell;
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {

        // displaying the pre-search results options.
        if ([self.searchDisplayController.searchBar.text length] < CHARACTERS_BEFORE_SEARCHING) {

            static NSString *reusableCellIdentifier = @"searchResultsTableCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reusableCellIdentifier];
            }

            // if there are recent searches, the first section will be those. if not, the first (and only) section will be saved locations.
            if ([self numberOfRecentSearchesToDisplay]) {
                if (indexPath.section == 0) {
                    cell.textLabel.text = (NSString *)[self.recentSearches objectAtIndex:indexPath.row];
                }
                else {
                    if (indexPath.row == 0) {
                        cell.textLabel.text = @"Current location";
                    }
                    else {
                        NSDictionary *locationToDisplay = [[[NSUserDefaults standardUserDefaults] arrayForKey:userDefaultsSavedLocationsKey] objectAtIndex:(indexPath.row - 1)];
                        cell.textLabel.text = (NSString *)[locationToDisplay objectForKey:@"Name"];
                    }
                }
            }
            else {
                if (indexPath.row == 0) {
                    cell.textLabel.text = @"Current location";
                }
                else {
                    NSDictionary *locationToDisplay = [[[NSUserDefaults standardUserDefaults] arrayForKey:userDefaultsSavedLocationsKey] objectAtIndex:(indexPath.row - 1)];
                    cell.textLabel.text = (NSString *)[locationToDisplay objectForKey:@"Name"];
                }
            }

            return cell;
            
        }
        // displaying the search results.
        else {
            static NSString *reusableCellIdentifier = @"searchResultsTableCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reusableCellIdentifier];
            }
            NSDictionary *place = [self.searchResults objectAtIndex:indexPath.row];
            //NSLog(@"place: %@", [place description]);
            cell.textLabel.text = [NSString stringWithFormat:@"%@", [place objectForKey:@"description"]];
            return cell;
        }
    }

    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // if the table view sending the message is the search controller TVC
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        // deselect the row and remove the search controller apparatus (search box, results tableview, etc.).
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        [self.searchDisplayController setActive:NO animated:YES];
        
        // save the search for display in search history later.
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        [self.recentSearches insertObject:selectedCell.textLabel.text atIndex:0];
        
        NSDictionary *selectedSearchResult = (NSDictionary *)self.searchResults[indexPath.row];
        //NSLog(@"selectedSearchResult: %@", [selectedSearchResult description]);
        NSString *placeID = [selectedSearchResult objectForKey:@"place_id"];
        [[GooglePlacesClient sharedGooglePlacesClient] getPlaceDetails:placeID delegate:self];
        
    }
}

#pragma mark - Search Bar

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self executeSearch:searchBar.text];
}

- (void)executeSearch:(NSString *)searchString
{
    // TO DO: set the region to the DMV
    CLLocationCoordinate2D locationToSearchAround = CLLocationCoordinate2DMake(38.895108, -77.036548);
    
    [[GooglePlacesClient sharedGooglePlacesClient] getPlacesLike:searchString atLocation:locationToSearchAround delegate:self];
}

- (void)receiveGooglePlacesAutocompleteResults:(NSArray *)fetchedPlaces
{
    self.searchResults = fetchedPlaces;
}

- (void)receiveGooglePlacesPlaceDetails:(NSDictionary *)fetchedPlace
{
    // create the coordinate structure with the returned JSON.
    CLLocationCoordinate2D selectedLocation = CLLocationCoordinate2DMake([[fetchedPlace valueForKeyPath:@"result.geometry.location.lat"] doubleValue], [[fetchedPlace valueForKeyPath:@"result.geometry.location.lng"] doubleValue]);
    
    // store it in an instance variable, which will trigger a fetch of articles at that location.
    [self setLocationWithLatitude:selectedLocation.latitude andLongitude:selectedLocation.longitude zoom:DEFAULT_ZOOM_LEVEL];
    
    // on the main queue update the UI (map and table view).
    dispatch_async(dispatch_get_main_queue(), ^{
        // return the table to the top
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    });
}

#pragma mark - GMSMapViewDelegate

- (void) mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position
{
    NSLog(@"idleAtCameraPosition called.");
    [self removeArticleOverlay];
    self.latitude = position.target.latitude;
    self.longitude = position.target.longitude;
    [self fetchData];
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self removeArticleOverlay];
}

- (void)removeArticleOverlay
{
    // if an article is overlaid, hide it. (else, do nothing.)
    if (self.articleOverlaid) {
        
        [self.view layoutIfNeeded];
        self.articleOverlayTopEdgeConstraint.constant += self.articleOverlayHeightConstraint.constant;
        
        [UIView animateWithDuration:0.35
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                             // once the article overlay is off-screen, remove all the subviews (should be just one, but just in case iterate across entire subviews array).
                             [[self.articleOverlay subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
                         }];
        
        // update the state of the article overlay.
        self.articleOverlaid = NO;
        if (self.tappedMarker) {
            // reset the tapped marker to its default color.
            ArticleContainer *tappedMarkerArticleContainer = (ArticleContainer *)self.tappedMarker.userData;
            self.tappedMarker.icon = [self getIconForArticleContainer:tappedMarkerArticleContainer selected:NO];
            // nullify the self.tappedMarker pointer to indicate that there is no tapped marker. the marker continues to exist because there is another pointer to it.
            self.tappedMarker = nil;
        }
    }
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    /*
     Possible cases:
     1. Articles are displayed (list view). Tapping a marker goes to article in list view.
     2. Full map is displayed, no article overlaid. Display article for tapped marker.
     3. Full map is displayed, article is overlaid. Display article for tapped marker unless it's the same marker as the last one tapped.
     */
    
    ArticleContainer *articleContainer = (ArticleContainer *)marker.userData;
    
    // we are in list mode, meaning the table view of articles is visible beneath the map.
    if (self.listView) {
        [self setFocusOnArticleContainer:articleContainer];
    }

    // we are in full-map mode.
    else {

        // if no article is already overlaid, display the tapped one.
        if (!self.articleOverlaid) {
           
            // add the gesture recognizer if the cell corresponds to a marker that has multiple articles.
            if ([articleContainer.articles count] > 1) {
                [self prepareArticleOverlayViewWithFrame:self.articleOverlay.bounds article:[articleContainer articleOfDisplayedTeaser] superview:self.articleOverlay addPanGestureRecognizer:YES];
            }
            else {
                [self prepareArticleOverlayViewWithFrame:self.articleOverlay.bounds article:[articleContainer articleOfDisplayedTeaser] superview:self.articleOverlay addPanGestureRecognizer:NO];
            }
            
            // the article overlay starts life hidden because its top edge constraint equals the super view's bottom edge. so it is pushed down, and hidden behind the tab bar. to slide it up, we reduce this constraint, effectively giving it a smaller Y value, i.e. higher vertical placement in the view window. we reverse this -- i.e. add to the constraint -- to push the article overlay back off screen.
            [self.view layoutIfNeeded];
            self.articleOverlayTopEdgeConstraint.constant -= self.articleOverlayHeightConstraint.constant;

            [UIView animateWithDuration:0.35
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 [self.view layoutIfNeeded];
                             }
                             completion:^(BOOL finished) {
                             }];
            
            // make the marker green.
            marker.icon = [self getIconForArticleContainer:articleContainer selected:YES];

            // update the state of the article overlay.
            self.articleOverlaid = YES;
            self.tappedMarker = marker;
        }
        // an article is already overlaid.
        else {
            // if the tapped article is NOT the one already overlaid, we display the tapped article. (else, do nothing.)
            if (![marker isEqual:self.tappedMarker]) {
            
                // add the gesture recognizer if the cell corresponds to a marker that has multiple articles.
                if ([articleContainer.articles count] > 1) {
                    [self prepareArticleOverlayViewWithFrame:self.articleOverlay.bounds article:[articleContainer articleOfDisplayedTeaser] superview:self.articleOverlay addPanGestureRecognizer:YES];
                }
                else {
                    [self prepareArticleOverlayViewWithFrame:self.articleOverlay.bounds article:[articleContainer articleOfDisplayedTeaser] superview:self.articleOverlay addPanGestureRecognizer:NO];
                }
 
                [UIView transitionWithView:self.articleOverlay
                                  duration:0.5
                                   options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionTransitionFlipFromRight
                                animations:^{
                                    [[self.articleOverlay.subviews objectAtIndex:0] removeFromSuperview];
                                    // used to have the line below but commented it out to put it above, where newArticleOverlaySubview is instantiated. still seems to work. but if the animation breaks for some reason, consider uncommenting this line here and removing it from above.
                                    //[self.articleOverlay addSubview:newArticleOverlaySubview];
                                }
                                completion:nil];
                
                // reset the existing tapped marker back to the default color and make the newly tapped marker green.
                ArticleContainer *tappedMarkerArticleContainer = (ArticleContainer *)self.tappedMarker.userData;
                self.tappedMarker.icon = [self getIconForArticleContainer:tappedMarkerArticleContainer selected:NO];
                marker.icon = [self getIconForArticleContainer:articleContainer selected:YES];
                
                // update the state of the article overlay, namely which marker was last tapped.
                self.tappedMarker = marker;

            }
        }
    }

    return YES;
}

- (ArticleOverlayView *)prepareArticleOverlayViewWithFrame:(CGRect)frame article:(Article *)article superview:(UIView *)superview addPanGestureRecognizer:(BOOL)addPanGestureRecognizer
{
    // instantiate the subview and set constraints on it to fill the bounds of the placeholder superview self.articleOverlay.
    ArticleOverlayView *articleOverlaySubview = [[ArticleOverlayView alloc] initWithFrame:frame];
    articleOverlaySubview.delegate = self;
    articleOverlaySubview.respondsToTaps = YES;
    articleOverlaySubview.topBorder = YES;
    articleOverlaySubview.translatesAutoresizingMaskIntoConstraints = NO;
    [superview addSubview:articleOverlaySubview];
    [articleOverlaySubview setEdgesToSuperview:superview leading:0 trailing:0 top:0 bottom:0 superviewFeature:None];
    [articleOverlaySubview configureTeaserForArticle:article]; // set the values for the article overlay view's various components.

    if (addPanGestureRecognizer) {
        [articleOverlaySubview addPanGestureRecognizer];
    }

    return articleOverlaySubview;
}

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture
{
    // if a gesture started the move we don't want to clear the data/map after the fetch.
    if (gesture) {
        self.clearDataAndMapUponFetchReturn = NO;
    }
}

// the radius to search is based on the visible area of the map. we take the longest side of the visible map and halve it. this would cover everything, but we expand it with multiplier extraMarginForSearchRadius so that when the user pans around nearby, there are already markers there.
- (CGFloat)radiusToSearch
{
    CLLocationDistance radius;
    CLLocationDistance distanceAtWidestSide;
    CLLocation *pointA;
    CLLocation *pointB;
    
    // width is longer than height, so get radius from width.
    if (self.mapView.bounds.size.width > self.mapView.bounds.size.height) {
        pointA = [[CLLocation alloc] initWithLatitude:self.mapView.projection.visibleRegion.nearLeft.latitude longitude:self.mapView.projection.visibleRegion.nearLeft.longitude];
        pointB = [[CLLocation alloc] initWithLatitude:self.mapView.projection.visibleRegion.nearRight.latitude longitude:self.mapView.projection.visibleRegion.nearRight.longitude];
    }
    // height is longer than width, so get radius from height.
    else {
        pointA = [[CLLocation alloc] initWithLatitude:self.mapView.projection.visibleRegion.nearLeft.latitude longitude:self.mapView.projection.visibleRegion.nearLeft.longitude];
        pointB = [[CLLocation alloc] initWithLatitude:self.mapView.projection.visibleRegion.farLeft.latitude longitude:self.mapView.projection.visibleRegion.farLeft.longitude];
    }
    
    //NSLog(@"point A: %f,%f", pointA.coordinate.latitude, pointA.coordinate.longitude);
    //NSLog(@"point B: %f,%f", pointB.coordinate.latitude, pointB.coordinate.longitude);

    distanceAtWidestSide = [pointA distanceFromLocation:pointB]; // return value in meters.
    //NSLog(@"distance: %f", distanceAtWidestSide);
    radius = distanceAtWidestSide / 2; // halve the span to get the radius.
    radius = radius / 1000; // divide by 1000 to convert kilometers.
    //NSLog(@"radius: %f", radius);
    radius = radius * (1.0 + extraMarginForSearchRadius);
    //NSLog(@"radius with extra: %f", radius);
    
    return radius;
}


#pragma mark - Article scrolling behavior

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // disable all the pan GRs on the table items that correspond to articleContainers with multiple stories.
    for (UIPanGestureRecognizer *panGR in self.tableViewPanGestureRecognizers) {
        panGR.enabled = NO;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // re-enable all the pan GRs that were disabled at the beginning of the scroll.
    for (UIPanGestureRecognizer *panGR in self.tableViewPanGestureRecognizers) {
        panGR.enabled = YES;
    }

    [self startMapReorientation];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self startMapReorientation];
}

- (void)startMapReorientation
{
    NSIndexPath *topmostIndexPath = [[self.tableView indexPathsForVisibleRows] objectAtIndex:0];
    UITableViewCell *topmostCell = [self.tableView cellForRowAtIndexPath:topmostIndexPath];

    // we're converting the current y values of both the topmost visible cell and the top edge of the table view to the window's coordinate system.
    // we will then compare them to learn if the topmost visible cell is more or less than half exposed. if less, it means the user has scrolled that cell more than half off the screen and the second cell is the more appropriate top cell, so we scroll to it (topmostIndexPath.row + 1).
    CGPoint topmostCellVerticalMidpoint = CGPointMake(topmostCell.bounds.origin.x, (topmostCell.bounds.size.height / 2));
    CGPoint topmostCellVerticalMidpointInWindowCoordinateSystem = [topmostCell convertPoint:topmostCellVerticalMidpoint toView:nil];
    CGPoint tableViewOriginInWindowCoordinateSystem = [self.tableView convertPoint:self.tableView.bounds.origin toView:nil];

    // this is the current y value of the vertical midpoint of the cell and the top border of the table, both in the window's coordinate system.
    CGFloat verticalMidpoint = topmostCellVerticalMidpointInWindowCoordinateSystem.y;
    CGFloat topEdgeOfTable = tableViewOriginInWindowCoordinateSystem.y;
    
    // if verticalMidpoint is greater than topEdgeOfTable it means that more than half the cell is exposed, and we should scroll to display it.
    ArticleContainer *articleContainerToReceiveFocus;
    if (verticalMidpoint >= topEdgeOfTable) {
        if (topmostIndexPath.row < [self.articleContainers count]) {
            articleContainerToReceiveFocus = (ArticleContainer *)[self.articleContainers objectAtIndex:topmostIndexPath.row];
        }
        else {
            articleContainerToReceiveFocus = (ArticleContainer *)[self.articleContainers lastObject];
        }
    }
    // otherwise the top edge of the table is lower than the midpoint of the top cell, meaning only the bottom half or less are exposed, and we should scroll to display the cell beneath it.
    else {
        if ((topmostIndexPath.row + 1) < [self.articleContainers count]) {
            articleContainerToReceiveFocus = (ArticleContainer *)[self.articleContainers objectAtIndex:(topmostIndexPath.row + 1)];
        }
        else {
            articleContainerToReceiveFocus = (ArticleContainer *)[self.articleContainers lastObject];
        }
    }
    
    NSDictionary *userInfo = @{ @"articleContainerToReceiveFocus" : articleContainerToReceiveFocus };
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                  target:self
                                                selector:@selector(setFocusOnArticleContainerWithTimer:)
                                                userInfo:userInfo
                                                 repeats:NO];
}

- (void)setFocusOnArticleContainer:(ArticleContainer *)articleContainerToReceiveFocus
{
    // Three things need to happen to visually focus on a new marker/cell:
    // 1. De-highlight the currently-focused one, if it exists.
    // 2. Move the map camera to the newly-focused marker's location.
    // 3. Scroll the table and highlight the newly-focused cell. The actual highlighting occurs in delegate method scrollViewDidEndScrollingAnimation because to highlight a cell by changing its background, it needs to be visible first. That is, it needs to have scrolled into view and can't be off-screen.
    
    // 1
    if (self.articleContainerWithFocus) {
        NSIndexPath *indexPathWithCurrentFocus = [NSIndexPath indexPathForRow:[self.articleContainers indexOfObject:self.articleContainerWithFocus] inSection:0];
        NewsMapTableViewCell *cellWithCurrentFocus = (NewsMapTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPathWithCurrentFocus];
        cellWithCurrentFocus.articleView.backgroundColor = [UIColor whiteColor];
    }
    self.articleContainerWithFocus = articleContainerToReceiveFocus; // save the newly focused article.
    
    // 2
    [self moveCameraToMarker:articleContainerToReceiveFocus.marker highlightMarker:YES];

    // 3
    // when the scrolling finishes, delegate method scrollViewDidEndScrollingAnimation will do the actual highlighting.
    NSIndexPath *indexPathToReceiveFocus = [NSIndexPath indexPathForRow:[self.articleContainers indexOfObject:articleContainerToReceiveFocus] inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPathToReceiveFocus atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    // we need to do the following for the case when scrollToRowAtIndexPath causes no scroll because either a) articleContainerToReceiveFocus is the topmost cell and the user got there by pull-dragging to the top or b) the exceedingly rare case where the user has stopped scrolling on the exact pixel between two cells so no further scroll is necessary. In either of those cases, the backgroundColor animation (i.e., highlighting) would not have occurred because scrollViewDidEndScrollingAnimation would never be called.
    NewsMapTableViewCell *cellToReceiveFocus = (NewsMapTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPathToReceiveFocus];
    CGPoint cellOriginInWindowCoordinateSystem = [cellToReceiveFocus convertPoint:cellToReceiveFocus.bounds.origin toView:nil];
    CGPoint tableViewOriginInWindowCoordinateSystem = [self.tableView convertPoint:self.tableView.bounds.origin toView:nil];
    if (cellOriginInWindowCoordinateSystem.y == tableViewOriginInWindowCoordinateSystem.y) {
        [UIView animateWithDuration:0.5 animations:^{
            cellToReceiveFocus.articleView.backgroundColor = [Stylesheet color3];
        }];
    }
    
}

- (void)setFocusOnArticleContainerWithTimer:(NSTimer *)timer
{
    [self setFocusOnArticleContainer:(ArticleContainer *)timer.userInfo[@"articleContainerToReceiveFocus"]];
}

- (void)moveCameraToMarker:(GMSMarker *)markerToReceiveFocus highlightMarker:(BOOL)highlightMarker
{
    // reset all the markers to the default color.
    for (ArticleContainer *articleContainer in self.articleContainers) {
        articleContainer.marker.icon = [self getIconForArticleContainer:articleContainer selected:NO];
    }
    // move the map to the newly focused article's location and set the corresponding marker to selected.
    if (highlightMarker) {
        ArticleContainer *articleContainerOfMarkerToReceiveFocus = (ArticleContainer *)markerToReceiveFocus.userData;
        markerToReceiveFocus.icon = [self getIconForArticleContainer:articleContainerOfMarkerToReceiveFocus selected:YES];
    }
}

- (IBAction)pressToggleViewButton:(id)sender
{
    // hide the list, go full screen with the map
    if (self.listView) {
        
        // we need to save this for when we reanimate the table view back in.
        self.originalMapViewBottomEdgeY = self.tableView.frame.origin.y;
        
        // remove this border instantly; don't animate its disappearance.
        self.borderBetweenMapAndTable.opacity = 0.0;
        
        // we expand the map view by animating the change in its height constraint to its current height plus the table view's current height. by changing the constraint, the height of the table view will respond accordingly (ie, shrink to nothing) thanks to other constraints that force equality between the bottom of the map view and top of the table view. credit for technique: http://stackoverflow.com/questions/12622424/how-do-i-animate-constraint-changes
        [self.view layoutIfNeeded];
        self.mapContainerViewHeightConstraint.constant = self.mapContainerView.frame.size.height + self.tableView.frame.size.height;
        
        [UIView animateWithDuration:0.4
                              delay:0.0 // we can add delay here (0.3 or more seems necessary) to avoid the user seeing the grey areas of the new map rect that momentarily appear before the new map tiles load.
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                             //[self.toggleListViewButton setTitle:[NSString stringWithUTF8String:"\ue807"] forState:UIControlStateNormal];

                             // upon completion, if there was a selected marker, de-select it in the table view and on the map.
                             if (self.articleContainerWithFocus) {
                                 NSIndexPath *indexPathOfCellWithFocus = [NSIndexPath indexPathForRow:[self.articleContainers indexOfObject:self.articleContainerWithFocus] inSection:0];
                                 NewsMapTableViewCell *cellWithFocus = (NewsMapTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPathOfCellWithFocus];
                                 cellWithFocus.articleView.backgroundColor = [UIColor whiteColor];
                                 self.articleContainerWithFocus.marker.icon = [self getIconForArticleContainer:self.articleContainerWithFocus selected:NO];
                                 self.articleContainerWithFocus = nil; // update the state.
                             }
                         }];
        
        self.listView = NO; // save the state so we know whether to expand or contract next time the button is pressed.
    }
    
    // show the list, shrink the map
    else {

        [self removeArticleOverlay];
        
        // we contract the map view by animating the change in its height constraint to its current height (i.e., the whole window) minus the difference between the table view's current y position (very bottom of window) and the original bottom edge of the map view.
        [self.view layoutIfNeeded];
        self.mapContainerViewHeightConstraint.constant = self.mapContainerView.frame.size.height - (self.tableView.frame.origin.y - self.originalMapViewBottomEdgeY);
        
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                             self.borderBetweenMapAndTable.opacity = 1.0; // display the border instantly once the animation has completed.
                             [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO]; // scroll to the top of the table view.
                         }];

        self.listView = YES; // save the state so we know whether to expand or contract next time the button is pressed.
    }

    [self fetchData];

}

- (IBAction)pressSearchFiltersButton:(id)sender
{
    NSLog(@"search filters");
    //[[Crashlytics sharedInstance] crash];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // at the end of scrolling, the topmost visible row will be the one we want to give focus.
    //NSIndexPath *indexPathOfCellToFocus = [[self.tableView indexPathsForVisibleRows] objectAtIndex:0];
    NSIndexPath *indexPathOfCellToFocus = [NSIndexPath indexPathForRow:[self.articleContainers indexOfObject:self.articleContainerWithFocus] inSection:0];
    NewsMapTableViewCell *cellToFocus = (NewsMapTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPathOfCellToFocus];
    // fade in the highlighting color.
    [UIView animateWithDuration:0.5 animations:^{
        cellToFocus.articleView.backgroundColor = [Stylesheet color3];
    }];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidScrollToTop called.");
}

#pragma mark - UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    // execute the autocomplete search only once the user has entered at least three characters.
    if ([searchString length] >= CHARACTERS_BEFORE_SEARCHING) {
        [self executeSearch:searchString];
    }
    else {
        self.searchResults = [NSArray array];
    }
    
    // the autocomplete data is downloaded asynchronously, and the table is reloaded upon completion then, not now.
    return NO;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"DisplayArticleSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[ArticleViewController class]]) {
            ArticleViewController *articleVC = (ArticleViewController *)segue.destinationViewController;
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            //Article *articleToDisplay = (Article *)self.articles[indexPath.row];
            Article *articleToDisplay = [self.articleContainers[indexPath.row] articleOfDisplayedTeaser];
            articleVC.article = articleToDisplay;
        }
    }
    if ([segue.identifier isEqualToString:@"SearchFiltersSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[SearchFilters class]]) {
            SearchFilters *searchFilters = (SearchFilters *)segue.destinationViewController;
            searchFilters.displayOrders = [self.displayOrders mutableCopy];
            searchFilters.articleAges = [self.articleAges mutableCopy];
            searchFilters.articleTags = [self.articleTags mutableCopy];
            searchFilters.delegate = self;
        }
    }
}

#pragma mark - Misc

// called when an article is tapped in full-mape view.
- (void)loadArticle:(Article *)article
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    ArticleViewController *articleVC = (ArticleViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ArticleViewController"];
    articleVC.article = article;
    [self.navigationController pushViewController:articleVC animated:YES];
}

- (void)updateDataWithArray:(NSArray *)newDataArray // newDataArray is an array of Articles.
{
    NSArray *addedArticles = [self populateArticlesArray:newDataArray]; // fill self.articles.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self populateArticleContainersArray:addedArticles]; // fill self.articleContainers.
    });
}

- (NSArray *)populateArticlesArray:(NSArray *)newDataArray // newDataArray is an array of Articles.
{
    // first extract all the article_ids into their own array.
    NSMutableArray *existingArticle_IDs = [[NSMutableArray alloc] init];
    for (Article *article in self.articles) {
        [existingArticle_IDs addObject:article.article_id];
    }
    
    // we then search this array to quickly determine which articles in newDataArray already exist in self.articles. if an article doesn't exist in self.articles, stick it in articleToAdd, which is finally appended to self.articles.
    NSMutableArray *articlesToAdd = [[NSMutableArray alloc] init];
    for (Article *article in newDataArray) {
        // if it doesn't exist, add it.
        if (![existingArticle_IDs containsObject:article.article_id]) {
            [articlesToAdd addObject:article];
        }
    }
    [self.articles addObjectsFromArray:articlesToAdd];
    return articlesToAdd;
}

- (void)populateArticleContainersArray:(NSArray *)articlesToMap // articlesToMap is an array of Articles.
{
    NSLog(@"number of articles: %d", (int)[articlesToMap count]);
    
    int i = 1;
    for (Article *article in articlesToMap) {
        
        //NSLog(@"article: %d", i);
        
        CLLocation *articleLocation = [[CLLocation alloc] initWithLatitude:article.coordinate.latitude longitude:article.coordinate.longitude];
        
        BOOL locationMatchedExistingMarker = NO;
        
        int j = 1;
        
        for (ArticleContainer *articleContainer in self.articleContainers) {
            
            //NSLog(@"marker: %d", j);
            
            CLLocationCoordinate2D articleContainerCoordinate;
            
            NSMutableArray *articlesAtLocation = (NSMutableArray *)articleContainer.articles;
            // just use the first article in the array for its coordinate. doesn't matter which we choose; the point is that they're all the same location.
            articleContainerCoordinate = ((Article *)[articlesAtLocation firstObject]).coordinate;
            CLLocation *articleContainerLocation = [[CLLocation alloc] initWithLatitude:articleContainerCoordinate.latitude longitude:articleContainerCoordinate.longitude];
            // test whether the location associated with this marker is the same as the current article. if it is, append this article to the array of articles for this marker.
            if ([articleLocation distanceFromLocation:articleContainerLocation] < MARKER_OVERLAP_DISTANCE) {
                
                // loop through the array. if the new article happened later than an existing article, insert the new article at that spot in front of the existing article. that way we'll have a reverse-chronologically ordered array at the end.
                BOOL articleStillNeedsToBeAdded = YES;
                for (int i = 0; i < [articlesAtLocation count]; i++) {
                    Article *articleAlreadyInArray = (Article *)articlesAtLocation[i];
                    // true if article.date is later in time than articleAlreadyInArray.date.
                    if ([article.date compare:articleAlreadyInArray.date] == NSOrderedDescending) {
                        [articlesAtLocation insertObject:article atIndex:i];
                        articleStillNeedsToBeAdded = NO;
                        break;
                    }
                }
                // article was earlier than all the existing articles, meaning it hasn't been added and should be tacked on the end.
                if (articleStillNeedsToBeAdded) {
                    [articlesAtLocation addObject:article];
                }
                
                article.container = articleContainer;
                locationMatchedExistingMarker = YES;
                break;
            }
            j++;
            
        }
        
        // if the article's location was not found to exist at one of the article containers, add a new article container for it.
        if (!locationMatchedExistingMarker) {
            ArticleContainer *newArticleContainer = [[ArticleContainer alloc] init];
            newArticleContainer.marker = [GMSMarker markerWithPosition:article.coordinate];
            newArticleContainer.marker.userData = newArticleContainer; // marker.userData is a pointer to its containing container.
            NSMutableArray *articlesAtLocation = [[NSMutableArray alloc] initWithObjects:article, nil];
            newArticleContainer.articles = articlesAtLocation;
            newArticleContainer.indexOfDisplayedTeaser = 0; // default is first element in the array (ie, most recent article).
            article.container = newArticleContainer;
            [self.articleContainers addObject:newArticleContainer];
        }
        i++;
    }
}

// Loop through self.articleContainers and examine each one's marker. All markers whose positions are offscreen more than OFF_SCREEN_THRESHOLD, remove them from the map and their corresponding articles and article containers. For markers whose positions are onscreen or within acceptable margin offscreen, if they aren't already displayed (check whether marker.map is nil), display them. If they are already displayed, check whether the current icon isEqual to the icon it should be. If not, display the appropriate marker. (If so, do nothing.)
- (void)updateMarkersOnMap
{
    // first remove markers that are offscreen
    [self removeOffscreenMarkers];

    for (ArticleContainer *articleContainer in self.articleContainers) {
        GMSMarker *marker = articleContainer.marker;
        marker.icon = [self getIconForArticleContainer:articleContainer selected:NO];
        if (!marker.map) {
            marker.map = self.mapView;
        }
        marker.appearAnimation = kGMSMarkerAnimationPop;
    }
    
    // if the currentLocationMarker was set during a call to didUpdateLocations, display it on the map now.
    if (self.currentLocationMarker != nil) {
        self.currentLocationMarker.map = self.mapView;
    }
}

- (void)removeOffscreenMarkers
{
    NSMutableArray *articleContainersToRemove = [[NSMutableArray alloc] init];

    for (ArticleContainer *articleContainer in self.articleContainers) {
        // if the marker's coordinate is NOT visible, remove it.
        if (![self.mapView.projection containsCoordinate:articleContainer.marker.position]) {
            for (Article *article in articleContainer.articles) {
                [self.articles removeObject:article];
            }
            articleContainer.marker.map = nil; // this removes the marker from the map visually.
            [articleContainersToRemove addObject:articleContainer]; // add this article container to the list to be removed.
        }
    }
    // remove all the article containers accrued by the loop above.
    [self.articleContainers removeObjectsInArray:articleContainersToRemove];
}

- (UIImage *)getIconForArticleContainer:(ArticleContainer *)articleContainer selected:(BOOL)selected
{
    NSString *imageName;
    // we have to fiddle with this a little because the first position is invalid so we don't count it in the count.
    int numberOfMarkerIcons = ((int)[[Constants mapMarkersSelected] count]) - 1;
    
    if (selected) {
        // if the number count is 1-9, choose the corresponding marker.
        if ([articleContainer.articles count] < numberOfMarkerIcons) {
            imageName = (NSString *)[[Constants mapMarkersSelected] objectAtIndex:[articleContainer.articles count]];
        }
        // otherwise, choose 9+ (which sits at the end of the array).
        else {
            imageName = (NSString *)[[Constants mapMarkersSelected] objectAtIndex:numberOfMarkerIcons];
        }
    }
    else {
        // if the number count is 1-9, choose the corresponding marker.
        if ([articleContainer.articles count] < numberOfMarkerIcons) {
            imageName = (NSString *)[[Constants mapMarkersDefault] objectAtIndex:[articleContainer.articles count]];
        }
        // otherwise, choose 9+ (which sits at the end of the array).
        else {
            imageName = (NSString *)[[Constants mapMarkersDefault] objectAtIndex:numberOfMarkerIcons];
        }
    }

    //NSLog(@"imageName: %@", imageName);
    return [[UIImage imageNamed:imageName] imageWithAlignmentRectInsets:UIEdgeInsetsFromString(map_marker_insets)];
}

#pragma mark - ArticleOverlayViewDelegate

- (void)setArticleOverlayView:(ArticleOverlayView *)articleOverlayView
{
    if ([articleOverlayView.superview isKindOfClass:[NewsMapTableViewCell class]]) {
        NewsMapTableViewCell *newsMapTableViewCell = (NewsMapTableViewCell *)articleOverlayView.superview;
        newsMapTableViewCell.articleView = articleOverlayView;
    }
    
    // record which index is now the current visible article in the article container.
    ArticleContainer *articleContainer = articleOverlayView.article.container;
    articleContainer.indexOfDisplayedTeaser = (int)[articleContainer.articles indexOfObject:articleOverlayView.article];
}

// we save all the pan GRs so that we can deactivate them when the table view starts scrolling vertically.
- (void)articleOverlayView:(ArticleOverlayView *)articleOverlayView saveGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    [self.tableViewPanGestureRecognizers addObject:gestureRecognizer];
}

// delete the panned-out article's gesture recognizer from the array of table view GRs.
- (void)articleOverlayView:(ArticleOverlayView *)articleOverlayView deleteGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    [self.tableViewPanGestureRecognizers removeObject:gestureRecognizer];
}

#pragma mark - SearchFiltersTVCDelegate

- (void)updateSearchFilters:(NSArray *)displayOrders articleAges:(NSArray *)articleAges articleTags:(NSArray *)articleTags
{
    self.displayOrders = displayOrders;
    self.articleAges = articleAges;
    self.articleTags = articleTags;
    [self fetchData];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    self.currentLocationMarker = nil;
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:@"Failed to Get Your Location"
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *mostRecentlyReportedLocation = [locations lastObject];
    NSLog(@"location: %@", mostRecentlyReportedLocation);

    // create the current location marker if it doesn't exist; update its location if it does. don't actually display it on the map here (by setting its map parameter), instead doing that when the other markers are displayed. we don't touch the map view at all in this method.
    if (!self.currentLocationMarker) {
        self.currentLocationMarker = [GMSMarker markerWithPosition:mostRecentlyReportedLocation.coordinate];
        self.currentLocationMarker.icon = [UIImage imageNamed:map_marker_currentLocation];
    }
    else {
        self.currentLocationMarker.position = mostRecentlyReportedLocation.coordinate;
    }
    
    [self.locationManager stopUpdatingLocation];

    //[self setLocationWithLatitude:mostRecentlyReportedLocation.coordinate.latitude andLongitude:mostRecentlyReportedLocation.coordinate.longitude zoom:DEFAULT_ZOOM_LEVEL];
    
    [self.fetcher numberOfResultsAtLatitude:mostRecentlyReportedLocation.coordinate.latitude
                                  longitude:mostRecentlyReportedLocation.coordinate.longitude
                                     radius:BASE_RADIUS_FROM_USER_LOCATION
                                      units:RADIUS_UNITS
                                        age:[self getSelectedArticleAge]];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"kCLAuthorizationStatusNotDetermined reported in didChangeAuthorizationStatus.");
            break;
        case kCLAuthorizationStatusRestricted:
            NSLog(@"kCLAuthorizationStatusRestricted reported in didChangeAuthorizationStatus.");
            // user didn't grant permission so proceed with fallback.
            self.locationAwarenessEnabled = NO;
            [self processLackOfLocationAwareness:PermissionDeniedRightNow];
            break;
        case kCLAuthorizationStatusDenied:
            NSLog(@"kCLAuthorizationStatusDenied reported in didChangeAuthorizationStatus.");
            // user didn't grant permission so proceed with fallback.
            self.locationAwarenessEnabled = NO;
            [self processLackOfLocationAwareness:PermissionDeniedRightNow];
            break;
        case kCLAuthorizationStatusAuthorized: // kCLAuthorizationStatusAuthorized == kCLAuthorizationStatusAuthorizedAlways
            NSLog(@"kCLAuthorizationStatusAuthorized reported in didChangeAuthorizationStatus.");
            // user granted permission so turn on location awareness.
            self.locationAwarenessEnabled = YES;
            [self.locationManager startUpdatingLocation];
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            NSLog(@"kCLAuthorizationStatusAuthorizedWhenInUse reported in didChangeAuthorizationStatus.");
            // user granted permission so turn on location awareness.
            self.locationAwarenessEnabled = YES;
            [self.locationManager startUpdatingLocation];
            break;
    }
}

@end