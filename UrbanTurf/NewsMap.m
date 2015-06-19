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
#import "Article.h"
#import "Stylesheet.h"
#import "GooglePlacesClient.h"
#import "UIImageView+AFNetworking.h"
#import "ArticleOverlayView.h"
#import "NewsMapTableViewCell.h"
#import "ArticleViewController.h"
#import "UIView+AddBorders.h"

@interface NewsMap ()
@property (weak, nonatomic) IBOutlet UIButton *toggleViewButton;
@property (weak, nonatomic) IBOutlet UIButton *searchFiltersButton;
@property (strong, nonatomic) Fetcher *fetcher; // fetches data
@property (strong, nonatomic) NSArray *searchResults;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) NSArray *articles; // of Articles
@property (strong, nonatomic) Article *articleWithFocus; // article with current focus, if any
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSTimer *timer;
@property CGFloat originalMapViewBottomEdgeY;
@property (nonatomic, strong) CALayer *borderBetweenMapAndTable;
@property (strong, nonatomic) UIImageView *crosshairs;
@property (strong, nonatomic) NSMutableArray *recentSearches; // of NSString
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewHeightConstraint;
@property (nonatomic) BOOL gestureInitiatedMapMove;

// various states and constraints of the UI related to the article overlay effect in full-map mode.
@property (nonatomic) BOOL listView;
@property (nonatomic) BOOL articleOverlaid;
@property (strong, nonatomic) GMSMarker *tappedMarker;
@property (strong, nonatomic) IBOutlet UIView *articleOverlay;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *articleOverlayTopEdgeConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *articleOverlayHeightConstraint;
@end

@implementation NewsMap

#define CHARACTERS_BEFORE_SEARCHING 3

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
    //self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
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
    
    self.searchDisplayController.searchBar.tintColor = [Stylesheet color1];
    
    self.listView = YES;
    self.articleOverlaid = NO;
    self.tappedMarker = nil;
    self.originalMapViewBottomEdgeY = self.tableView.frame.origin.y;
    
    // hairline border between map and articles
    self.borderBetweenMapAndTable = [CALayer layer];
    self.borderBetweenMapAndTable.borderColor = [UIColor lightGrayColor].CGColor;
    self.borderBetweenMapAndTable.borderWidth = 0.25f;
    self.borderBetweenMapAndTable.frame = CGRectMake(0, CGRectGetHeight(self.mapView.frame) - 1.0, CGRectGetWidth(self.mapView.frame) - 1, 0.25f);
    [self.mapView.layer addSublayer:self.borderBetweenMapAndTable];
    
    self.mapView.delegate = self;
    self.mapView.settings.myLocationButton = NO;
    self.mapView.indoorEnabled = NO; // disabled this to suppress the random error "Encountered indoor level with missing enclosing_building field" we were getting.
    
    // instatiate the crosshairs image, but wait to position on the screen until viewWillLayoutSubviews
    self.crosshairs = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cursor-crosshair"]];
    
    self.latitude = office.latitude;
    self.longitude = office.longitude;
    
    self.gestureInitiatedMapMove = NO;
    
    // this sets the back button text of the subsequent vc, not the visible vc. confusing.
    // thank you: https://dbrajkovic.wordpress.com/2012/10/31/customize-the-back-button-of-uinavigationitem-in-the-navigation-bar/
    //self.navigationBar.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self fetchData];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // not sure exactly how this works, but got the technique from SO:
    // http://stackoverflow.com/questions/29109541/uiview-width-height-not-adjusting-to-constraints
    [self.mapView addSubview:self.crosshairs];
    [self.crosshairs setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.mapView addConstraint:[NSLayoutConstraint constraintWithItem:self.mapView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.crosshairs attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self.mapView addConstraint:[NSLayoutConstraint constraintWithItem:self.mapView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.crosshairs attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
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

- (NSArray *)searchResults
{
    if (!_searchResults) {
        _searchResults = [NSArray array];
    }
    return _searchResults;
}

- (void)setSearchResults:(NSArray *)searchResults
{
    _searchResults = searchResults;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.searchDisplayController.searchResultsTableView reloadData];
    });
}

- (void)setLocationWithLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude
{
    self.latitude = latitude;
    self.longitude = longitude;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mapView moveCamera:[GMSCameraUpdate setTarget:CLLocationCoordinate2DMake(latitude, longitude) zoom:DEFAULT_ZOOM_LEVEL]];
    });
    [self fetchData];
}

- (NSMutableArray *)recentSearches
{
    if (!_recentSearches) {
        _recentSearches = [[NSMutableArray alloc] init];
    }
    return _recentSearches;
}

#pragma mark - Fetching

- (void)fetchData
{
    [self.fetcher fetchDataWithLatitude:self.latitude longitude:self.longitude];
}

- (void)receiveData:(NSArray *)fetchedResults
{
    NSLog(@"fetchedResults called.");
    NSMutableArray *processedFromJSON = [NSMutableArray arrayWithCapacity:[fetchedResults count]];
    //NSLog(@"results: %@", fetchedResults);
    for (NSDictionary *article in fetchedResults) {
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake([article[@"latitude"] doubleValue], [article[@"longitude"] doubleValue]);
        Article *processedArticle = [[Article alloc] initWithTitle:article[@"headline"] Location:location];
        processedArticle.url = article[@"website"];
        processedArticle.imageURL = article[@"image_url"];
        processedArticle.introduction = article[@"intro"];
        processedArticle.publication = article[@"website_name"];
        processedArticle.date = article[@"article_date"];
        [processedFromJSON addObject:processedArticle];
    }
    //NSLog(@"processedForTVC: %@", processedForTVC);
    self.articles = [processedFromJSON copy];
    
    // make all UI updates on on the main queue, namely reloading the tableview and updating the map to add markers for the results of the new fetch.
    dispatch_async(dispatch_get_main_queue(), ^{

        // update the tableview
        [self.tableView reloadData];
        
        // add all the markers to the map
        [self.mapView clear]; // clear off existing markers
        for (Article *article in self.articles) {
            GMSMarker *marker = [GMSMarker markerWithPosition:article.coordinate];
            marker.snippet = @"Hello World";
            marker.appearAnimation = kGMSMarkerAnimationPop;
            marker.map = self.mapView;
            marker.userData = article;
            article.marker = marker;
        }
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
    if (tableView == self.tableView) {
        return [self.articles count] + 1; // the extra one is for the last cell, a spacer cell.
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
    // if the table view sending the message is the articles table view
    if (tableView == self.tableView) {
        if (indexPath.row == [self.articles count]) {
            return 300;
        }
        else {
            //return TOP_CAPTION_HEIGHT + IMAGE_HEIGHT + BOTTOM_CAPTION_HEIGHT + VERTICAL_MARGIN;
            return 130;
        }
    }
    
    // if the table view sending the message is the search controller TVC
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return tableView.rowHeight;
    }
    
    return 0;
}

#define IMAGE_TAG 1
#define HEADLINELABEL_TAG 2
#define INTROLABEL_TAG 3
#define METAINFOLABEL_TAG 4

#define MARGIN 16
#define FONT_POINT_SIZE 12.0

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // if the table view sending the message is the articles table view
    if (tableView == self.tableView) {
        
        // this is a unique cell, the last one, and doesn't need much configuration.
        if (indexPath.row == [self.articles count]) {
            static NSString *LastCellIdentifier = @"Last Cell - Spacer";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LastCellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LastCellIdentifier];
            }
            return cell;
        }
        
        // The way this works is we have a custom UITableViewCell class called NewsMapTableViewCell. The tableview's prototype cell's custom class in the storyboard is set to this class, as is its identifier. The NewsMapTableViewCell class is simply a container view of a single ArticleOverlayView subview called articleView. ArticleOverlayView is the owner of the correspondingly named xib. In this way we have one custom view designed in a xib (ArticleOverlayView.xib) that can be used both in the table view and as the view that slides up when a marker is tapped in full screen map mode. (The reason we don't simply make the prototype cell's custom class ArticleOverlayView is that that would force ArticleOverlayView to be subclassed from UITableViewCell, which we don't want.) Thank you: http://www.pumpmybicep.com/2014/07/21/designing-a-custom-uitableviewcell-in-interface-builder/
        NewsMapTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsMapTableViewCell" forIndexPath:indexPath];
        ArticleOverlayView *articleOverlaySubview = [[ArticleOverlayView alloc] initWithFrame:cell.articleView.bounds];
        articleOverlaySubview.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.articleView addSubview:articleOverlaySubview];
        [self pinEdgesOfSubview:articleOverlaySubview toSuperview:cell.articleView]; // pin the top, trailing, bottom, and leading edges
        
        Article *article = (Article *)self.articles[indexPath.row];
        [self configureArticleTeaserForSubview:articleOverlaySubview withArticle:article];
        
        // this ensures that the background color is reset, lest it be colored due to reuse of a scroll-selected cell.
        cell.backgroundColor = nil;
        
        return cell;
        
        /******************** BEGIN - WORKING ******************** commented out 6/6/15 to use custom cell from xib.
        
        // this is a unique cell, the last one, and doesn't need much configuration.
        if (indexPath.row == [self.articles count]) {
            static NSString *LastCellIdentifier = @"Last Cell - Spacer";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LastCellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LastCellIdentifier];
            }
            return cell;
        }

        static NSString *CellIdentifier = @"Article Cell";

        UILabel *headlineLabel, *introLabel, *metaInfoLabel;
        UIImageView *image;

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            CGFloat borderWidth = 2.0f;
            cell.contentView.frame = CGRectInset(cell.contentView.frame, -borderWidth, -borderWidth);
            cell.contentView.layer.borderColor = [UIColor yellowColor].CGColor;
            cell.contentView.layer.borderWidth = borderWidth;
            
            CGFloat superviewWidth = cell.contentView.frame.size.width;
            //CGFloat superviewHeight = cell.contentView.frame.size.height;
            
            CGFloat photoWidth = superviewWidth / 3.5;
            CGFloat photoHeight = photoWidth;
            
            // there are three text blocks alongside the image. the top two are two lines high, the third one line high.
            CGFloat heightOfHeadline = (photoHeight / 5) * 2;
            CGFloat heightOfIntro = (photoHeight / 5) * 2;
            CGFloat heightOfMetaInfo = photoHeight / 5;
            
            image = [[UIImageView alloc] initWithFrame:CGRectMake(MARGIN, MARGIN, photoWidth, photoHeight)];
            image.tag = IMAGE_TAG;
            image.backgroundColor = [UIColor redColor];
            [cell.contentView addSubview:image];
            
            CGFloat headlineLabelOriginX = MARGIN + photoWidth + MARGIN;
            CGRect headlineLabelRect = CGRectMake(headlineLabelOriginX, MARGIN, (superviewWidth - photoWidth - (3*MARGIN)), heightOfHeadline);
            headlineLabel = [[UILabel alloc] initWithFrame:headlineLabelRect];
            headlineLabel.tag = HEADLINELABEL_TAG;
            //headlineLabel.font = [UIFont systemFontOfSize:10.0];
            headlineLabel.font = [[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] fontWithSize:FONT_POINT_SIZE];
            headlineLabel.numberOfLines = 2;
            //headlineLabel.textColor = [UIColor blackColor];
            //headlineLabel.backgroundColor = [UIColor greenColor];
            [cell.contentView addSubview:headlineLabel];
            
            CGRect introLabelRect = CGRectMake(headlineLabel.frame.origin.x, headlineLabel.frame.origin.y + heightOfHeadline, headlineLabel.frame.size.width, heightOfIntro);
            introLabel = [[UILabel alloc] initWithFrame:introLabelRect];
            introLabel.tag = INTROLABEL_TAG;
            introLabel.font = [[UIFont preferredFontForTextStyle:UIFontTextStyleBody] fontWithSize:FONT_POINT_SIZE];
            introLabel.numberOfLines = 2;
            //introLabel.textColor = [UIColor darkGrayColor];
            //introLabel.backgroundColor = [UIColor blueColor];
            [cell.contentView addSubview:introLabel];
            
            CGRect metaInfoLabelRect = CGRectMake(introLabel.frame.origin.x, introLabel.frame.origin.y + heightOfIntro, introLabel.frame.size.width, heightOfMetaInfo);
            metaInfoLabel = [[UILabel alloc] initWithFrame:metaInfoLabelRect];
            metaInfoLabel.tag = METAINFOLABEL_TAG;
            metaInfoLabel.font = [[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] fontWithSize:FONT_POINT_SIZE];
            //metaInfoLabel.textColor = [UIColor darkGrayColor];
            //metaInfoLabel.backgroundColor = [UIColor purpleColor];
            [cell.contentView addSubview:metaInfoLabel];
            
        }
        else {
            image = (UIImageView *)[cell.contentView viewWithTag:IMAGE_TAG];
            headlineLabel = (UILabel *)[cell.contentView viewWithTag:HEADLINELABEL_TAG];
            introLabel = (UILabel *)[cell.contentView viewWithTag:INTROLABEL_TAG];
            metaInfoLabel = (UILabel *)[cell.contentView viewWithTag:METAINFOLABEL_TAG];
        }
        
        Article *article = (Article *)self.articles[indexPath.row];
        headlineLabel.text = article.title;
        introLabel.text = [article.introduction substringWithRange:NSMakeRange(0, 100)];
        //introLabel.text = [NSString stringWithFormat:@"%d. %@", (int)indexPath.row, [article.introduction substringWithRange:NSMakeRange(0, 100)]];
        metaInfoLabel.text = article.publication;
        NSDictionary *publicationAttributes = @{
                                                NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:FONT_POINT_SIZE], // this is a magic font; couldn't figure out how to bold this programmatically, resorted to hard coding the font name.
                                                NSForegroundColorAttributeName: [Stylesheet color1]
                                                };
        
        NSDictionary *dateAttributes = @{
                                         NSFontAttributeName: [[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] fontWithSize:FONT_POINT_SIZE],
                                         NSForegroundColorAttributeName: [Stylesheet color2]
                                         };
        
        // concatenate the publication name and date, separating them with •
        NSMutableString *metaInfoString = [article.publication mutableCopy];
        [metaInfoString appendString:[NSString stringWithFormat:@" • %@", article.date]];

        // make it attributed with publicationAttributes for the whole string
        NSMutableAttributedString *metaInfoAttributedString = [[[NSAttributedString alloc] initWithString:metaInfoString attributes:publicationAttributes] mutableCopy];
        
        // re-attribute the date, which begins at the end of the publication string and continues through to the end
        NSRange rangeOfDateInfo = NSMakeRange([article.publication length], ([metaInfoString length] - [article.publication length]));
        [metaInfoAttributedString setAttributes:dateAttributes range:rangeOfDateInfo];
        
        // set the label with the value
        metaInfoLabel.attributedText = metaInfoAttributedString;
        
        [image setImageWithURL:[NSURL URLWithString:article.imageURL]];

        // this ensures that the background color is reset, lest it be colored due to reuse of a scroll-selected cell.
        cell.backgroundColor = nil;
        
        return cell;
         
         ******************** END - WORKING ********************/
        
        
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
    
    // if the table view sending the message is the articles table view
    if (tableView == self.tableView) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
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
    [self setLocationWithLatitude:selectedLocation.latitude andLongitude:selectedLocation.longitude];
    
    // on the main queue update the UI (map and table view).
    dispatch_async(dispatch_get_main_queue(), ^{
        // return the table to the top
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [self.mapView clear]; // clear off existing markers
        //[self.mapView moveCamera:[GMSCameraUpdate setTarget:selectedLocation zoom:DEFAULT_ZOOM_LEVEL]];
        if (self.crosshairs.hidden) [self showCrosshairs];
    });

}

#pragma mark - GMSMapViewDelegate

- (void) mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position
{
    if (self.gestureInitiatedMapMove) {
        self.gestureInitiatedMapMove = NO;
        [self setLocationWithLatitude:position.target.latitude andLongitude:position.target.longitude];
    }
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
        self.tappedMarker = nil;
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
    
    // we are in list mode, meaning the table view of articles is visible beneath the map.
    if (self.listView) {
        if (!self.crosshairs.hidden) [self hideCrosshairs]; // hide the crosshairs if they're not already hidden.
        NSLog(@"index: %lu", (unsigned long)[self.articles indexOfObject:marker.userData]);
        [self setFocusOnArticle:(Article *)marker.userData];
    }

    // we are in full-map mode.
    else {

        // if no article is already overlaid, display the tapped one.
        if (!self.articleOverlaid) {
           
            // instantiate the subview and set constraints on it to fill the bounds of the placeholder superview self.articleOverlay.
            ArticleOverlayView *articleOverlaySubview = [[ArticleOverlayView alloc] initWithFrame:self.articleOverlay.bounds];
            articleOverlaySubview.translatesAutoresizingMaskIntoConstraints = NO;
            [self.articleOverlay addSubview:articleOverlaySubview];
            [self pinEdgesOfSubview:articleOverlaySubview toSuperview:self.articleOverlay]; // pin the top, trailing, bottom, and leading edges.
            [self configureArticleTeaserForSubview:articleOverlaySubview withArticle:(Article *)marker.userData]; // set the values for the article overlay view's various components.
            [articleOverlaySubview addBorder:UIRectEdgeTop color:[Stylesheet color5] thickness:1.0f]; // set the top border.
            [articleOverlaySubview addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadArticle:)]]; // add the tap gesture recognizer.
            
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

            // update the state of the article overlay.
            self.articleOverlaid = YES;
            self.tappedMarker = marker;
            
        }
        // an article is already overlaid.
        else {
            // if the tapped article is NOT the one already overlaid, we display the tapped article. (else, do nothing.)
            if (![marker isEqual:self.tappedMarker]) {
            
                ArticleOverlayView *newArticleOverlaySubview = [[ArticleOverlayView alloc] initWithFrame:self.articleOverlay.bounds];
                // set the background color to whichever color the current subview's background color isn't.
                // debugging stuff - delete soon:
                // if (CGColorEqualToColor(((UIView *)[self.articleOverlay.subviews objectAtIndex:0]).backgroundColor.CGColor, [UIColor blueColor].CGColor)) newArticleOverlaySubview.backgroundColor = [UIColor purpleColor];
                // else newArticleOverlaySubview.backgroundColor = [UIColor blueColor];
                [self.articleOverlay addSubview:newArticleOverlaySubview];
                [self configureArticleTeaserForSubview:newArticleOverlaySubview withArticle:(Article *)marker.userData]; // set the values for the article overlay view's various components.
                [newArticleOverlaySubview addBorder:UIRectEdgeTop color:[Stylesheet color5] thickness:1.0f]; // set the top border.
                [newArticleOverlaySubview addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadArticle:)]]; // add the tap gesture recognizer.

                [UIView transitionWithView:self.articleOverlay
                                  duration:0.5
                                   options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionTransitionFlipFromRight
                                animations:^{
                                    [[self.articleOverlay.subviews objectAtIndex:0] removeFromSuperview];
                                    [self.articleOverlay addSubview:newArticleOverlaySubview];
                                }
                                completion:nil];
                
                // update the state of the article overlay, namely which marker was last tapped.
                self.tappedMarker = marker;

            }
        }
    }

    return YES;
}

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture
{
    if (gesture) {
        // re-display the crosshairs if the map is moving due to a user gesture.
        if (self.crosshairs.hidden) [self showCrosshairs];
        
        // record the fact that a gesture started the move so we know that in idleAtCameraPosition.
        self.gestureInitiatedMapMove = YES;
    }
    else {
        self.gestureInitiatedMapMove = NO;
    }
}

- (void)hideCrosshairs
{
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.crosshairs.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         self.crosshairs.hidden = YES;
                     }];
}

- (void)showCrosshairs
{
    self.crosshairs.hidden = NO;
    self.crosshairs.alpha = 1.0;
    
    /* COULDN'T GET THIS FADE-IN EFFECT TO WORK --
    self.crosshairs.alpha = 0.0; // make it totally transparent before unhiding it just in case for some reason it isn't already.
    self.crosshairs.hidden = NO; // unhide it.
    // increase the alpha from totally transparent to totally opaque.
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.crosshairs.alpha = 1.0;
                     }];
     */
}

#pragma mark - Article scrolling behavior

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // decrease the alpha from totally opaque to totally transparent, and upon completion hide the view altogether.
    if (!self.crosshairs.hidden) [self hideCrosshairs];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self startMapReorientation];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
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
    Article *articleToReceiveFocus;
    if (verticalMidpoint >= topEdgeOfTable) {
        if (topmostIndexPath.row < [self.articles count]) {
            articleToReceiveFocus = (Article *)[self.articles objectAtIndex:topmostIndexPath.row];
        }
        else {
            articleToReceiveFocus = (Article *)[self.articles lastObject];
        }
    }
    // otherwise the top edge of the table is lower than the midpoint of the top cell, meaning only the bottom half or less are exposed, and we should scroll to display the cell beneath it.
    else {
        if ((topmostIndexPath.row + 1) < [self.articles count]) {
            articleToReceiveFocus = (Article *)[self.articles objectAtIndex:(topmostIndexPath.row + 1)];
        }
        else {
            articleToReceiveFocus = (Article *)[self.articles lastObject];
        }
    }
    
    NSDictionary *userInfo = @{ @"articleToReceiveFocus" : articleToReceiveFocus };
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                  target:self
                                                selector:@selector(setFocusOnArticleWithTimer:)
                                                userInfo:userInfo
                                                 repeats:NO];
}

- (void)setFocusOnArticle:(Article *)articleToReceiveFocus
{
    // Three things need to happen to visually focus on a new article/cell:
    // 3. Scroll the table and highlight the newly-focused cell. The actual highlighting occurs in delegate method scrollViewDidEndScrollingAnimation because to highlight a cell by changing its background, it needs to be visible first. That is, it needs to have scrolled into view and can't be off-screen.
    // 1. De-highlight the currently-focused one, if it exists.
    // 2. Move the map camera to the newly-focused article's location.
    
    // 1
    if (self.articleWithFocus) {
        NSIndexPath *indexPathWithCurrentFocus = [NSIndexPath indexPathForRow:[self.articles indexOfObject:self.articleWithFocus] inSection:0];
        UITableViewCell *cellWithCurrentFocus = [self.tableView cellForRowAtIndexPath:indexPathWithCurrentFocus];
        cellWithCurrentFocus.backgroundColor = nil;
    }
    self.articleWithFocus = articleToReceiveFocus; // save the newly focused article.
    
    // 2
    [self setFocusOnArticleAtIndexWithAnnotation:articleToReceiveFocus];

    // 3
    // when the scrolling finishes, delegate method scrollViewDidEndScrollingAnimation will do the actual highlighting.
    NSIndexPath *indexPathToReceiveFocus = [NSIndexPath indexPathForRow:[self.articles indexOfObject:articleToReceiveFocus] inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPathToReceiveFocus atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    // we need to do the following for the case when scrollToRowAtIndexPath causes no scroll because either a) articleToReceiveFocus is the topmost cell and the user got there by pull-dragging to the top or b) the exceedingly rare case where the user has stopped scrolling on the exact pixel between two cells so no further scroll is necessary. In either of those cases, the backgroundColor animation (i.e., highlighting) would not have occurred because scrollViewDidEndScrollingAnimation would never be called.
    UITableViewCell *cellToReceiveFocus = [self.tableView cellForRowAtIndexPath:indexPathToReceiveFocus];
    CGPoint cellOriginInWindowCoordinateSystem = [cellToReceiveFocus convertPoint:cellToReceiveFocus.bounds.origin toView:nil];
    CGPoint tableViewOriginInWindowCoordinateSystem = [self.tableView convertPoint:self.tableView.bounds.origin toView:nil];
    if (cellOriginInWindowCoordinateSystem.y == tableViewOriginInWindowCoordinateSystem.y) {
        [UIView animateWithDuration:0.5 animations:^{
            cellToReceiveFocus.backgroundColor = [Stylesheet color3];
        }];
    }
    
}

- (void)setFocusOnArticleWithTimer:(NSTimer *)timer
{
    [self setFocusOnArticle:(Article *)timer.userInfo[@"articleToReceiveFocus"]];
}

- (void)setFocusOnArticleAtIndexWithAnnotation:(Article *)articleToReceiveFocus
{
    // reset all the markers to the default color, red.
    for (Article *article in self.articles) {
        article.marker.icon = [GMSMarker markerImageWithColor:[UIColor redColor]];
    }
    // move the map set the newly focused article's location and set the corresponding marker to green.
    [self.mapView animateToLocation:articleToReceiveFocus.coordinate];
    articleToReceiveFocus.marker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
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
        self.mapViewHeightConstraint.constant = self.mapView.frame.size.height + self.tableView.frame.size.height;
        
        [UIView animateWithDuration:0.4
                              delay:0.0 // we can add delay here (0.3 or more seems necessary) to avoid the user seeing the grey areas of the new map rect that momentarily appear before the new map tiles load.
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                             //[self.toggleListViewButton setTitle:[NSString stringWithUTF8String:"\ue807"] forState:UIControlStateNormal];
                         }];
        
        self.listView = NO; // save the state so we know whether to expand or contract next time the button is pressed.
    }
    
    // show the list, shrink the map
    else {

        [self removeArticleOverlay];
        
        // we contract the map view by animating the change in its height constraint to its current height (i.e., the whole window) minus the difference between the table view's current y position (very bottom of window) and the original bottom edge of the map view.
        [self.view layoutIfNeeded];
        self.mapViewHeightConstraint.constant = self.mapView.frame.size.height - (self.tableView.frame.origin.y - self.originalMapViewBottomEdgeY);
        
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                             //[self.toggleListViewButton setTitle:[NSString stringWithUTF8String:"\ue803"] forState:UIControlStateNormal];
                             self.borderBetweenMapAndTable.opacity = 1.0; // display the border instantly once the animation has completed.
                         }];

        self.listView = YES; // save the state so we know whether to expand or contract next time the button is pressed.
    }
}


- (IBAction)pressSearchFiltersButton:(id)sender
{
    NSLog(@"search filters");
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    // eventually add code to animate-expand the searchbar full width, over the neighboring buttons. (then contract again when search is executed.)
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // at the end of scrolling, the topmost visible row will be the one we want to give focus.
    //NSIndexPath *indexPathOfCellToFocus = [[self.tableView indexPathsForVisibleRows] objectAtIndex:0];
    NSIndexPath *indexPathOfCellToFocus = [NSIndexPath indexPathForRow:[self.articles indexOfObject:self.articleWithFocus] inSection:0];
    UITableViewCell *cellToFocus = [self.tableView cellForRowAtIndexPath:indexPathOfCellToFocus];

    // fade in the highlighting color.
    [UIView animateWithDuration:0.5 animations:^{
        cellToFocus.backgroundColor = [Stylesheet color3];
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
            Article *articleToDisplay = (Article *)self.articles[indexPath.row];
            articleVC.article = articleToDisplay;
        }
    }
}

#pragma mark - Misc

-(void)configureArticleTeaserForSubview:(ArticleOverlayView *)articleOverlaySubview withArticle:(Article *)article
{
    [articleOverlaySubview.imageView setImageWithURL:[NSURL URLWithString:article.imageURL]]; // image
    articleOverlaySubview.headlineLabel.text = article.title; // headline
    articleOverlaySubview.introLabel.text = [article.introduction substringWithRange:NSMakeRange(0, 100)]; // body
    [self prepareMetaInfoStringForSubview:articleOverlaySubview withArticle:article]; // meta info
    [articleOverlaySubview layoutIfNeeded];
}

-(void)prepareMetaInfoStringForSubview:(ArticleOverlayView *)articleOverlaySubview withArticle:(Article *)article
{
    articleOverlaySubview.metaInfoLabel.text = article.publication;
    
    NSDictionary *publicationAttributes = @{
                                            NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:FONT_POINT_SIZE], // this is a magic font; couldn't figure out how to bold this programmatically, resorted to hard coding the font name.
                                            NSForegroundColorAttributeName: [Stylesheet color1]
                                            };
    
    NSDictionary *dateAttributes = @{
                                     NSFontAttributeName: [[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] fontWithSize:FONT_POINT_SIZE],
                                     NSForegroundColorAttributeName: [Stylesheet color2]
                                     };
    
    // concatenate the publication name and date, separating them with •
    NSMutableString *metaInfoString = [article.publication mutableCopy];
    [metaInfoString appendString:[NSString stringWithFormat:@" • %@", article.date]];
    
    // make it attributed with publicationAttributes for the whole string
    NSMutableAttributedString *metaInfoAttributedString = [[[NSAttributedString alloc] initWithString:metaInfoString attributes:publicationAttributes] mutableCopy];
    
    // re-attribute the date, which begins at the end of the publication string and continues through to the end
    NSRange rangeOfDateInfo = NSMakeRange([article.publication length], ([metaInfoString length] - [article.publication length]));
    [metaInfoAttributedString setAttributes:dateAttributes range:rangeOfDateInfo];
    
    // set the label with the value
    articleOverlaySubview.metaInfoLabel.attributedText = metaInfoAttributedString;
}

-(void)pinEdgesOfSubview:(UIView *)subview toSuperview:(UIView *)superview
{
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                                                    attribute:NSLayoutAttributeLeading
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:superview
                                                                    attribute:NSLayoutAttributeLeading
                                                                   multiplier:1.0
                                                                     constant:0.0]];
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                                                    attribute:NSLayoutAttributeTrailing
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:superview
                                                                    attribute:NSLayoutAttributeTrailing
                                                                   multiplier:1.0
                                                                     constant:0.0]];
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:superview
                                                                    attribute:NSLayoutAttributeTop
                                                                   multiplier:1.0
                                                                     constant:0.0]];
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                                                    attribute:NSLayoutAttributeBottom
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:superview
                                                                    attribute:NSLayoutAttributeBottom
                                                                   multiplier:1.0
                                                                     constant:0.0]];
}

- (void)loadArticle:(UITapGestureRecognizer *)gestureRecognizer
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    ArticleViewController *articleVC = (ArticleViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ArticleViewController"];
    articleVC.article = (Article *)self.tappedMarker.userData;
    [self.navigationController pushViewController:articleVC animated:YES];
}

@end