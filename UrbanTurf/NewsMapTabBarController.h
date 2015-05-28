//
//  NewsMapTabBarController.h
//  UrbanTurf
//
//  Created by Will Smith on 2/10/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface NewsMapTabBarController : UITabBarController <UITabBarControllerDelegate>

- (void)prepareAndLoadNewsMap:(CLLocationCoordinate2D)location;

@end
