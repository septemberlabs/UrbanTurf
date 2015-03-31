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

@interface GoogleMap ()
@property (strong, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) NSURLSession *urlSession;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) NSArray *articles; // of Articles
@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;
@end

@implementation GoogleMap

@synthesize searchResults = _searchResults;

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - TVC methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // if the table view sending the message is the search controller TVC
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // if the table view sending the message is the search controller TVC
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchResults count];
    }
    return 0;
}

- (NSArray *)searchResults
{
    if (!_searchResults) {
        _searchResults = [NSArray array];
        self.searchResults = _searchResults;
    }
    return _searchResults;
}

- (void)setSearchResults:(NSArray *)searchResults
{
    _searchResults = searchResults;
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (NSURLSession *)urlSession
{
    if (!_urlSession) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfig.allowsCellularAccess = YES;
        _urlSession = [NSURLSession sessionWithConfiguration:sessionConfig];
    }
    return _urlSession;
}

- (void)executeSearch:(NSString *)searchString
{
    // TO DO: set the region to the DMV
    CLLocationCoordinate2D locationToSearchAround = CLLocationCoordinate2DMake(38.895108, -77.036548);
    
    NSString *encodedSearchString = [searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&location=%f,%f&radius=%@&sensor=true&key=%@", encodedSearchString, locationToSearchAround.latitude, locationToSearchAround.longitude, [NSString stringWithFormat:@"%i", 10000], googleAPIKeyForBrowserApplications];
    NSLog(@"URL we're loading: %@", url);
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    NSURLSessionDownloadTask *task = [self.urlSession downloadTaskWithRequest:request completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
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

- (void)setLocationWithLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude
{
    self.latitude = latitude;
    self.longitude = longitude;
}

#pragma mark - Search Bar

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self executeSearch:searchBar.text];
}

#pragma mark - UISearchDisplayDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // execute the autocomplete search only once the user has entered at least three characters.
    if ([searchText length] >= 3) {
        [self executeSearch:searchText];
    }
    else {
        self.searchResults = [NSArray array];
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    // the autocomplete data is downloaded asynchronously, and the table is reloaded upon completion then, so shouldn't be now.
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
        NSURLSessionDownloadTask *task = [self.urlSession downloadTaskWithRequest:request completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
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

@end
