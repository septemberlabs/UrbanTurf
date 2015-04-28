//
//  GoogleMap.m
//  UrbanTurf
//
//  Created by Will Smith on 3/25/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "GoogleMap.h"
#import "Constants.h"
#import <GoogleMaps/GoogleMaps.h>
#import "UrbanTurfFetcher.h"
#import "Article.h"
#import "Stylesheet.h"

@interface GoogleMap ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarRightBoundary;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarLeftBoundary;
@property (weak, nonatomic) IBOutlet UIButton *toggleViewButton;
@property (weak, nonatomic) IBOutlet UIButton *searchFiltersButton;
@property (strong, nonatomic) Fetcher *fetcher; // fetches data
@property (strong, nonatomic) NSArray *searchResults;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) NSArray *articles; // of Articles
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property CGFloat originalTableViewOriginY;
@property (nonatomic) BOOL listView;
@property (nonatomic, strong) CALayer *borderBetweenMapAndTable;
@end

@implementation GoogleMap

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

    self.latitude = office.latitude;
    self.longitude = office.longitude;
    
    [self fetchData];
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
    
    Article *firstItemToDisplay = (Article *)self.articles[0];
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
        
        // if the image data exists display it immediately. if not, add a block off the main queue to go grab and store it.
        if (article.actualImage != nil) {
            image.image = article.actualImage;
        }
        else {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:article.imageURL]];
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
            NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
                if (!error) {
                    //NSLog(@"request.URL: %@", [request.URL absoluteString]);
                    //NSLog(@"photo.thumbnailURL: %@", photo.thumbnailURL);
                    article.actualImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:localfile]];
                }
                else {
                    NSLog(@"Image download failed: %@", error.localizedDescription);
                }
            }];
            [task resume];
        }
        
        return cell;
        
    }
    
    // if the table view sending the message is the search controller TVC
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        static NSString *reusableCellIdentifier = @"searchResultsTableCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reusableCellIdentifier];
        }
        //MKPlacemark *placemark = (MKPlacemark *)[self.searchResults objectAtIndex:indexPath.row];
        
        //cell.textLabel.text = placemark.name;
        
        // make the detail text the fully formatted address of the place.
        //cell.detailTextLabel.text = [self prepareAddressString:placemark withoutUS:YES];
        
        NSDictionary *place = [self.searchResults objectAtIndex:indexPath.row];
        NSArray *terms = [place objectForKey:@"terms"];
        
        NSLog(@"place: %@", [place description]);
        NSLog(@"terms: %@", [terms description]);
        NSString *number = [terms[0] valueForKey:@"value"];
        NSLog(@"terms[0]: %@", number);
        NSString *street = [terms[1] valueForKey:@"value"];
        NSLog(@"terms[1]: %@", street);
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", number, street];
        
        return cell;
        
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // if the table view sending the message is the search controller TVC
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        [self.searchDisplayController setActive:NO animated:YES];
        
        NSDictionary *selectedSearchResult = (NSDictionary *)self.searchResults[indexPath.row];
        NSLog(@"selectedSearchResult: %@", [selectedSearchResult description]);
        
        NSString *placedID = [selectedSearchResult objectForKey:@"place_id"];
        NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=%@", placedID, googleAPIKeyForBrowserApplications];
        NSLog(@"URL we're loading: %@", url);
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
            if (!error) {
                NSDictionary *fetchedPlace;
                NSData *fetchedJSONData = [NSData dataWithContentsOfURL:localFile]; // will block if url is not local!
                if (fetchedJSONData) {
                    fetchedPlace = [NSJSONSerialization JSONObjectWithData:fetchedJSONData options:0 error:NULL];
                    NSLog(@"retrieved data: %@", fetchedPlace);
                }
                NSLog(@"place: %@", fetchedPlace);
                
                // create the coordinate structure with the returned JSON
                CLLocationCoordinate2D selectedLocation = CLLocationCoordinate2DMake([[fetchedPlace valueForKeyPath:@"result.geometry.location.lat"] doubleValue], [[fetchedPlace valueForKeyPath:@"result.geometry.location.lng"] doubleValue]);
                
                // store it in an instance variable
                [self setLocationWithLatitude:selectedLocation.latitude andLongitude:selectedLocation.longitude];
                
                // on the main queue, update the map to that coordinate
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.mapView moveCamera:[GMSCameraUpdate setTarget:selectedLocation zoom:16.0]];
                    
                    GMSMarker *marker = [GMSMarker markerWithPosition:selectedLocation];
                    marker.snippet = @"Hello World";
                    marker.appearAnimation = kGMSMarkerAnimationPop;
                    marker.map = self.mapView;
                    
                    NSLog(@"Im on the main thread");
                });
            }
            else {
                NSLog(@"Fetch failed: %@", error.localizedDescription);
                NSLog(@"Fetch failed: %@", error.userInfo);
            }
        }];
        [task resume];
        
        /*
         
         NSString *formattedAddressString = [self prepareAddressString:selectedSearchResult withoutUS:YES];
         
         // create a new annotation in order to set title and subtitle how we want. using MKPlacemark as the annotation doesn't permit that flexibility.
         MKPointAnnotation *annotation2 = [[MKPointAnnotation alloc] init];
         annotation2.title = selectedSearchResult.name;
         annotation2.subtitle = formattedAddressString;
         [annotation2 setCoordinate:selectedSearchResult.coordinate];
         
         self.searchDisplayController.searchBar.text = formattedAddressString;
         
         // clear existing annotations and add our new one.
         [self.mapView removeAnnotations:[self.mapView annotations]];
         [self.mapView addAnnotation:annotation2];
         [self.mapView showAnnotations:[self.mapView annotations] animated:YES];
         */
        
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
    
    NSString *encodedSearchString = [searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&location=%f,%f&radius=%@&sensor=true&key=%@", encodedSearchString, locationToSearchAround.latitude, locationToSearchAround.longitude, [NSString stringWithFormat:@"%i", 10000], googleAPIKeyForBrowserApplications];
    NSLog(@"URL we're loading: %@", url);
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSDictionary *fetchedPlacesList;
            NSData *fetchedJSONData = [NSData dataWithContentsOfURL:localFile]; // will block if url is not local!
            if (fetchedJSONData) {
                fetchedPlacesList = [NSJSONSerialization JSONObjectWithData:fetchedJSONData options:0 error:NULL];
                NSLog(@"retrieved data: %@", fetchedPlacesList);
            }
            NSArray *places = [fetchedPlacesList valueForKeyPath:@"predictions"];
            NSLog(@"places: %@", places);
            self.searchResults = places;
        }
        else {
            NSLog(@"Fetch failed: %@", error.localizedDescription);
            NSLog(@"Fetch failed: %@", error.userInfo);
        }
    }];
    [task resume];
    
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

/*

 HERE HERE HERE.
 
 - (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // execute the autocomplete search only once the user has entered at least three characters.
    if ([searchText length] >= 3) {
        [self executeSearch:searchText];
    }
    else {
        self.searchResults = [NSArray array];
    }
}
 */

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    // execute the autocomplete search only once the user has entered at least three characters.
    if ([searchString length] >= 3) {
        [self executeSearch:searchString];
    }
    else {
        self.searchResults = [NSArray array];
    }
    
    // the autocomplete data is downloaded asynchronously, and the table is reloaded upon completion then, so shouldn't be now.
    return NO;
}

@end
