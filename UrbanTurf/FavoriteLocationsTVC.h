//
//  FavoriteLocationsTVC.h
//  UrbanTurf
//
//  Created by Will Smith on 3/10/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface FavoriteLocationsTVC : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) CLLocationCoordinate2D currentLocation;

@end