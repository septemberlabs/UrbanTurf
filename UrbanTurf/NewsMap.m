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

@interface NewsMap ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarRightBoundary;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarLeftBoundary;
@property (weak, nonatomic) IBOutlet UIButton *toggleViewButton;
@property (weak, nonatomic) IBOutlet UIButton *searchFiltersButton;
@property (strong, nonatomic) Fetcher *fetcher; // fetches data
@property (strong, nonatomic) NSArray *searchResults;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) NSArray *articles; // of Articles
@property (strong, nonatomic) NSNumber *indexOfArticleWithFocus; // index within articles array and table view
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSTimer *timer;
@property CGFloat originalTableViewOriginY;
@property (nonatomic) BOOL listView;
@property (nonatomic, strong) CALayer *borderBetweenMapAndTable;
@property (strong, nonatomic) UIImageView *crosshairs;
@end

@implementation NewsMap

@synthesize searchResults = _searchResults;

- (void)viewDidLoad {
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
    self.originalTableViewOriginY = self.tableView.frame.origin.y;
    
    // hairline border between map and articles
    self.borderBetweenMapAndTable = [CALayer layer];
    self.borderBetweenMapAndTable.borderColor = [UIColor lightGrayColor].CGColor;
    self.borderBetweenMapAndTable.borderWidth = 0.25f;
    self.borderBetweenMapAndTable.frame = CGRectMake(0, CGRectGetHeight(self.mapView.frame) - 1.0, CGRectGetWidth(self.mapView.frame) - 1, 0.25f);
    [self.mapView.layer addSublayer:self.borderBetweenMapAndTable];
    
    self.mapView.delegate = self;
    self.mapView.settings.myLocationButton = NO;
    
    // instatiate the crosshairs image, but wait to position on the screen until viewWillLayoutSubviews
    self.crosshairs = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cursor-crosshair"]];
    
    self.latitude = office.latitude;
    self.longitude = office.longitude;
    
    self.indexOfArticleWithFocus = nil;
    
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
    [self fetchData];
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
    [self.tableView reloadData];
    
    if ([self.articles count]) {
        Article *firstItemToDisplay = (Article *)self.articles[0];
    }
    // ***** UNCOMMENT ONCE THIS method IMPLEMENTED *****
    //[self reorientMapWithAnnotation:firstItemToDisplay];
}

#pragma mark - TVC methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // if the table view sending the message is the articles table view
    if (tableView == self.tableView) {
        return 1;
    }
    
    // if the table view sending the message is the search controller TVC
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    }

    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // if the table view sending the message is the articles table view
    if (tableView == self.tableView) {
        return [self.articles count];
    }

    // if the table view sending the message is the search controller TVC
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchResults count];
    }

    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // if the table view sending the message is the articles table view
    if (tableView == self.tableView) {
        //return TOP_CAPTION_HEIGHT + IMAGE_HEIGHT + BOTTOM_CAPTION_HEIGHT + VERTICAL_MARGIN;
        return 140;
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
        
    }
    
    // if the table view sending the message is the search controller TVC
    if (tableView == self.searchDisplayController.searchResultsTableView) {
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

    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // if the table view sending the message is the search controller TVC
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        // deselect the row and remove the search controller apparatus (search box, results tableview, etc.)
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        [self.searchDisplayController setActive:NO animated:YES];
        
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
    // create the coordinate structure with the returned JSON
    CLLocationCoordinate2D selectedLocation = CLLocationCoordinate2DMake([[fetchedPlace valueForKeyPath:@"result.geometry.location.lat"] doubleValue], [[fetchedPlace valueForKeyPath:@"result.geometry.location.lng"] doubleValue]);
    
    // store it in an instance variable, which will trigger a fetch of articles at that location
    [self setLocationWithLatitude:selectedLocation.latitude andLongitude:selectedLocation.longitude];
    
    // on the main queue, update the map to that coordinate
    dispatch_async(dispatch_get_main_queue(), ^{
        // return the table to the top
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [self.mapView clear]; // clear off existing markers
        [self.mapView moveCamera:[GMSCameraUpdate setTarget:selectedLocation zoom:DEFAULT_ZOOM_LEVEL]];
        GMSMarker *marker = [GMSMarker markerWithPosition:selectedLocation];
        marker.snippet = @"Hello World";
        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.map = self.mapView;
        //NSLog(@"I'm on the main thread.");
    });

}

#pragma mark - GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"tapped at: %f, %f", coordinate.latitude, coordinate.longitude);
    /*
    if (self.crosshairs.hidden) {
        self.crosshairs.alpha = 0.0; // make it totally transparent before unhiding it just in case for some reason it isn't already.
        self.crosshairs.hidden = NO; // unhide it.
        // increase the alpha from totally transparent to totally opaque.
        [UIView animateWithDuration:0.5
                         animations:^{
                             self.crosshairs.alpha = 1.0;
                         }];
    }
     */
}

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture
{
    // only re-display the crosshairs if the map is moving due to a user gesture.
    if (gesture) {
        if (self.crosshairs.hidden) {
            self.crosshairs.hidden = NO;
            self.crosshairs.alpha = 1.0;
        }
    }
}


#pragma mark - Article scrolling behavior

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // decrease the alpha from totally opaque to totally transparent, and upon completion hide the view altogether.
    if (!self.crosshairs.hidden) {
        // decrease the alpha from totally opaque to totally transparent, and upon completion hide the view altogether.
        [UIView animateWithDuration:0.5
                         animations:^{
                             self.crosshairs.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             self.crosshairs.hidden = YES;
                         }];
    }
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
    NSIndexPath *indexPathOfCellToFocus;
    if (verticalMidpoint >= topEdgeOfTable) {
        indexPathOfCellToFocus = [NSIndexPath indexPathForRow:topmostIndexPath.row inSection:topmostIndexPath.section];
    }
    // otherwise the top edge of the table is lower than the midpoint of the top cell, meaning only the bottom half or less are exposed, and we should scroll to display the cell beneath it.
    else {
        indexPathOfCellToFocus = [NSIndexPath indexPathForRow:(topmostIndexPath.row + 1) inSection:topmostIndexPath.section];
    }
    
    NSDictionary *userInfo = @{ @"indexPathOfCellToFocus" : indexPathOfCellToFocus };
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                  target:self
                                                selector:@selector(reorientMapWithTimer:)
                                                userInfo:userInfo
                                                 repeats:NO];
}

- (void)reorientMapWithTimer:(NSTimer *)timer
{
    //NSLog(@"Timer fired.");

    // Three things need to happen when the timer fires:
    // 1. Highlight the newly-focused cell (article) and de-highlight the currently-focused one, if it exists.
    // 2. Scroll the table so that the newly-focused cell is topmost and 100% visible.
    // 3. Move the map camera to the newly-focused article's location.
    
    // this is the cell to receive focus, i.e. the new one.
    NSIndexPath *indexPathOfCellToFocus = (NSIndexPath*)timer.userInfo[@"indexPathOfCellToFocus"];
    UITableViewCell *cellToFocus = [self.tableView cellForRowAtIndexPath:indexPathOfCellToFocus];

    // 1
    [UIView animateWithDuration:0.5 animations:^{
        
        // this turns off the highlighting for the cell that has the current focus, if it exists.
        if (self.indexOfArticleWithFocus) {
            NSIndexPath *indexPathOfCellWithCurrentFocus = [NSIndexPath indexPathForRow:[self.indexOfArticleWithFocus integerValue] inSection:0];
            UITableViewCell *cellWithCurrentFocus = [self.tableView cellForRowAtIndexPath:indexPathOfCellWithCurrentFocus];
            cellWithCurrentFocus.backgroundColor = nil;
        }
        
        // highlight the new cell and save its value to enable turning off highlighting later.
        cellToFocus.backgroundColor = [Stylesheet color3];
        self.indexOfArticleWithFocus = [NSNumber numberWithInt:(int)indexPathOfCellToFocus.row];
        
    }];
    
    // 2
    [self.tableView scrollToRowAtIndexPath:indexPathOfCellToFocus atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    // 3
    Article *articleWithFocus = (Article *)[self.articles objectAtIndex:[self.indexOfArticleWithFocus integerValue]];
    [self reorientMapWithAnnotation:articleWithFocus];
}

- (void)reorientMapWithAnnotation:(Article *)itemToMap
{
    [self.mapView clear]; // clear off existing markers
    [self.mapView moveCamera:[GMSCameraUpdate setTarget:itemToMap.coordinate zoom:DEFAULT_ZOOM_LEVEL]];
    GMSMarker *marker = [GMSMarker markerWithPosition:itemToMap.coordinate];
    marker.snippet = @"Hello World";
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = self.mapView;
}

- (IBAction)pressToggleViewButton:(id)sender
{
    // hide the list, go full screen with the map
    if (self.listView) {
        
        self.borderBetweenMapAndTable.hidden = YES;
        
        // the Y delta by which we're contracting the table view and expanding the map view is the current height of the table view.
        CGFloat dY = self.tableView.frame.size.height;
        
        // we need to save this for when we reanimate the table view back in.
        self.originalTableViewOriginY = self.tableView.frame.origin.y;
        
        CGRect newTableViewRect = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y + dY, self.tableView.frame.size.width, 0);
        [UIView animateWithDuration:0.5 animations:^{
            self.tableView.frame = newTableViewRect;
        }];
        
        CGRect newMapViewRect = CGRectMake(self.mapView.frame.origin.x, self.mapView.frame.origin.y, self.mapView.frame.size.width, self.mapView.frame.size.height + dY);
        //CGRect newMapViewRect = CGRectMake(self.mapView.frame.origin.x, self.mapView.frame.origin.y, self.mapView.frame.size.width, self.mapView.frame.size.height);
        [UIView animateWithDuration:0.5
                         animations:^{
                             self.mapView.frame = newMapViewRect;
                         }
                         completion:^(BOOL finished) {
                             //[self.toggleListViewButton setTitle:[NSString stringWithUTF8String:"\ue807"] forState:UIControlStateNormal];
                         }];
        
        self.listView = NO;
        
    }
    
    // show the list, shrink the map
    else {
        
        CGFloat newTableViewFrameY = self.tableView.frame.origin.y - self.originalTableViewOriginY;
        CGRect newTableViewRect = CGRectMake(self.tableView.frame.origin.x, self.originalTableViewOriginY, self.tableView.frame.size.width, newTableViewFrameY);
        [UIView animateWithDuration:0.5 animations:^{
            self.tableView.frame = newTableViewRect;
        }];
        
        CGFloat newMapViewFrameY = self.mapView.frame.size.height - newTableViewRect.size.height;
        CGRect newMapViewRect = CGRectMake(self.mapView.frame.origin.x, self.mapView.frame.origin.y, self.mapView.frame.size.width, newMapViewFrameY);
        //CGRect newMapViewRect = CGRectMake(self.mapView.frame.origin.x, self.mapView.frame.origin.y, self.mapView.frame.size.width, self.mapView.frame.size.height);
        [UIView animateWithDuration:0.5
                         animations:^{
                             self.mapView.frame = newMapViewRect;
                         }
                         completion:^(BOOL finished) {
                             //[self.toggleListViewButton setTitle:[NSString stringWithUTF8String:"\ue803"] forState:UIControlStateNormal];
                             self.borderBetweenMapAndTable.hidden = NO;
                         }];
        
        // UNCOMMENT ONCE THESE TWO ARE IMPLEMENTED
        //self.mapTargetImage.hidden = YES;
        //self.redoSearchButton.hidden = YES;
        self.listView = YES;
        
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

#pragma mark - UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    // execute the autocomplete search only once the user has entered at least three characters.
    if ([searchString length] >= 3) {
        [self executeSearch:searchString];
    }
    else {
        self.searchResults = [NSArray array];
    }
    
    // the autocomplete data is downloaded asynchronously, and the table is reloaded upon completion then, not now.
    return NO;
}

/*
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showArticleSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            if ([[segue.destinationViewController viewControllers][0] isKindOfClass:[ArticleViewController class]]) {
                ArticleViewController *articleVC = (ArticleViewController *)[segue.destinationViewController viewControllers][0];
                NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
                Article *articleToDisplay = (Article *)self.articles[indexPath.row];
                articleVC.article = articleToDisplay;
            }
        }
    }
}
*/
 
@end
