//
//  HoodieVC.m
//  UrbanTurf
//
//  Created by Will Smith on 11/20/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import "Primary.h"
#import "UrbanTurfFetcher.h"
#import "Article.h"
#import "ArticleViewController.h"
#import "Stylesheet.h"
#import "Constants.h"

@interface Primary ()
@property (strong, nonatomic) Fetcher *fetcher; // fetches data
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *toggleListViewButton;
@property (weak, nonatomic) IBOutlet UIButton *searchFiltersButton;
@property (strong, nonatomic) NSArray *articles; // of Articles
@property (weak, nonatomic) IBOutlet UIImageView *mapTargetImage;
@property (weak, nonatomic) IBOutlet UIButton *redoSearchButton;
@property (strong, nonatomic) NSTimer *timer;
@property CGFloat originalTableViewOriginY;
@property (nonatomic) BOOL listView;
@property (strong, nonatomic) NSArray *searchResults; // of MKPlacemark
@end

@implementation Primary

@synthesize searchResults = _searchResults;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // configure the table view
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //self.mapTargetImage.hidden = YES;
    //self.redoSearchButton.hidden = YES;

    // map view button
    [self.toggleListViewButton.titleLabel setFont:[UIFont fontWithName:[Stylesheet fonticons] size:[Stylesheet searchBarFontIconSize]]];
    [self.toggleListViewButton setTitleColor:[Stylesheet color1] forState:UIControlStateNormal];
    [self.toggleListViewButton setTitle:[NSString stringWithUTF8String:"\ue80f"] forState:UIControlStateNormal];

    // search filters button
    [self.searchFiltersButton.titleLabel setFont:[UIFont fontWithName:[Stylesheet fonticons] size:[Stylesheet searchBarFontIconSize]]];
    [self.searchFiltersButton setTitleColor:[Stylesheet color1] forState:UIControlStateNormal];
    [self.searchFiltersButton setTitle:[NSString stringWithUTF8String:"\ue804"] forState:UIControlStateNormal];
    
    self.searchDisplayController.searchBar.tintColor = [Stylesheet color1];
    
    self.listView = YES;
    self.originalTableViewOriginY = self.tableView.frame.origin.y;
    
    self.latitude = office.latitude;
    self.longitude = office.longitude;
    
    [self fetchData];
    
    self.mapView.delegate = self;
    
    // https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TableView_iPhone/CreateConfigureTableView/CreateConfigureTableView.html
    // perhaps only if the table view is instantiated in code instead of in storyboard?
    //self.view = self.tableView;
    
    //NSLog(@"mapTargetImage: %@", self.mapTargetImage);
    //NSLog(@"redoSearchButton: %@", self.redoSearchButton);
    
}

- (Fetcher *)fetcher
{
    if (!_fetcher) {
        _fetcher = [[UrbanTurfFetcher alloc] init];
        _fetcher.delegate = self;
    }
    return _fetcher;
}

- (void)setLocationWithLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude
{
    self.latitude = latitude;
    self.longitude = longitude;
    [self fetchData];
}

- (void)fetchData
{
    [self.fetcher fetchDataWithLatitude:self.latitude longitude:self.longitude];
}

- (void)receiveData:(NSArray *)fetchedResults
{
    NSMutableArray *processedFromJSON = [NSMutableArray arrayWithCapacity:[fetchedResults count]];
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
    [self reorientMapWithAnnotation:firstItemToDisplay];
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

// give the option to suppress "United States" from the formatted address string.
- (NSString *)prepareAddressString:(MKPlacemark *)placemark withoutUS:(BOOL)withoutUS
{
    NSMutableArray *linesOfAddress = placemark.addressDictionary[ @"FormattedAddressLines"];
    if (withoutUS) {
        // the last object in the array is the country.
        NSString *country = [linesOfAddress lastObject];
        if ([country isEqualToString:@"United States"]) {
            [linesOfAddress removeLastObject];
        }
    }
    NSString *addressString = [linesOfAddress componentsJoinedByString:@", "];
    return addressString;
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
        MKPlacemark *placemark = (MKPlacemark *)[self.searchResults objectAtIndex:indexPath.row];
        
        cell.textLabel.text = placemark.name;
        
        // make the detail text the fully formatted address of the place.
        cell.detailTextLabel.text = [self prepareAddressString:placemark withoutUS:YES];
        
        return cell;
        
    }

    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // if the table view sending the message is the articles table view
    if (tableView == self.tableView) {
        [self performSegueWithIdentifier:@"showArticleSegue" sender:self];
    }
    
    // if the table view sending the message is the search controller TVC
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        [self.searchDisplayController setActive:NO animated:YES];
        
        MKPlacemark *selectedSearchResult = self.searchResults[indexPath.row];
        NSLog(@"selectedSearchResult: %@", [selectedSearchResult description]);
        
        [self setLocationWithLatitude:selectedSearchResult.coordinate.latitude andLongitude:selectedSearchResult.coordinate.longitude];
        
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
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)executeSearch:(NSString *)searchString
{
    // Create and initialize a search request object.
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = searchString;
    // TO DO: set the region to the DMV
    CLLocationCoordinate2D zeroMilestone = CLLocationCoordinate2DMake(38.895108, -77.036548);
    request.region = MKCoordinateRegionMakeWithDistance(zeroMilestone, 50.0, 50.0);
    
    // Create and initialize a search object.
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    
    // Start the search and display the results as annotations on the map.
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if (!error) {
            NSMutableArray *placemarks = [NSMutableArray array];
            for (MKMapItem *item in response.mapItems) {
                [placemarks addObject:item.placemark];
            }
            self.searchResults = placemarks;
        }
        else {
            NSLog(@"Search failed: %@", error.localizedDescription);
        }
    }];
}

#pragma mark - Search Bar

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self executeSearch:searchBar.text];
}

#pragma mark - UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self executeSearch:searchString];
    return YES;
}


#pragma mark - Article scrolling behavior

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSIndexPath *topmostIndexPath = [[self.tableView indexPathsForVisibleRows] objectAtIndex:0];
    Article *topmostItem = (Article *)self.articles[topmostIndexPath.row];
    NSDictionary *userInfo = @{ @"topmostIndexPath" : topmostIndexPath , @"topmostItem" : topmostItem};
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
    NSIndexPath *topmostIndexPath = (NSIndexPath*)timer.userInfo[@"topmostIndexPath"];
    Article *currentTopmostItem = (Article *)timer.userInfo[@"topmostItem"];
    //NSLog(@"Item: %@", currentTopmostItem.title);
    [self.tableView scrollToRowAtIndexPath:topmostIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [self reorientMapWithAnnotation:currentTopmostItem];
}

- (void)reorientMapWithAnnotation:(Article *)itemToMap
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotation:itemToMap];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(itemToMap.coordinate, 1.0, 1.0);
    [self.mapView setRegion:region animated:YES];
    
    //[self.mapView setCenterCoordinate:itemToMap.coordinate animated:YES];
    //[self.mapView showAnnotations:self.mapView.annotations animated:YES];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    // courtesy: http://stackoverflow.com/questions/6808876/how-do-i-animate-mkannotationview-drop
    MKAnnotationView *aV;
    
    for (aV in views) {
        
        // Don't pin drop if annotation is user location
        if ([aV.annotation isKindOfClass:[MKUserLocation class]]) {
            continue;
        }
        
        // Check if current annotation is inside visible map rect, else go to next one
        MKMapPoint point =  MKMapPointForCoordinate(aV.annotation.coordinate);
        if (!MKMapRectContainsPoint(self.mapView.visibleMapRect, point)) {
            continue;
        }
        
        CGRect endFrame = aV.frame;
        
        // Move annotation out of view
        aV.frame = CGRectMake(aV.frame.origin.x, aV.frame.origin.y - self.view.frame.size.height, aV.frame.size.width, aV.frame.size.height);
        
        // Animate drop
        [UIView animateWithDuration:0.5 delay:0.04*[views indexOfObject:aV] options: UIViewAnimationOptionCurveLinear animations:^{
            
            aV.frame = endFrame;
            
            // Animate squash
        } completion:^(BOOL finished){
            if (finished) {
                [UIView animateWithDuration:0.05 animations:^{
                    aV.transform = CGAffineTransformMakeScale(1.0, 0.8);
                    
                } completion:^(BOOL finished){
                    if (finished) {
                        [UIView animateWithDuration:0.1 animations:^{
                            aV.transform = CGAffineTransformIdentity;
                        }];
                    }
                }];
            }
        }];
    }
}

#pragma mark - Search bar buttons

- (IBAction)pressToggleListViewButton:(id)sender
{
    // hide the list, go full screen with the map
    if (self.listView) {

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
                         }];

        self.mapTargetImage.hidden = YES;
        self.redoSearchButton.hidden = YES;
        self.listView = YES;

    }
}


- (IBAction)pressSearchFiltersButton:(id)sender
{
    NSLog(@"search filters");
}

#pragma mark - Map interaction

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    //NSLog(@"mapTargetImage: %@", self.mapTargetImage);
    //NSLog(@"redoSearchButton: %@", self.redoSearchButton);
    self.mapTargetImage.center = self.mapView.center;
    self.mapTargetImage.hidden = NO;
    self.redoSearchButton.hidden = NO;
    //NSLog(@"mapTargetImage: %@", self.mapTargetImage);
    //NSLog(@"redoSearchButton: %@", self.redoSearchButton);
}

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

@end
