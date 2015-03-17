//
//  SaveFavoriteLocation.h
//  UrbanTurf
//
//  Created by Will Smith on 3/11/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface SaveFavoriteLocation : UIViewController <GMSMapViewDelegate>

@property (nonatomic) CLLocationCoordinate2D currentLocation;

@end
