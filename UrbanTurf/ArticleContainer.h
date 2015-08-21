//
//  ArticleContainer.h
//  UrbanTurf
//
//  Created by Will Smith on 8/20/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>

@interface ArticleContainer : NSObject

@property (strong, nonatomic) NSArray *articles;
@property (strong, nonatomic) GMSMarker *marker;
@property (nonatomic) int indexOfCurrentlyVisibleArticle;

@end