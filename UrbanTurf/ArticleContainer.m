//
//  ArticleContainer.m
//  UrbanTurf
//
//  Created by Will Smith on 8/20/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "ArticleContainer.h"
#import "Article.h"

@implementation ArticleContainer

- (Article *)articleOfDisplayedTeaser
{
    return (Article *)[self.articles objectAtIndex:self.indexOfDisplayedTeaser];
}

// Method C here: http://www.geomidpoint.com/methods.html. Good enough for our purposes.
-(CLLocationCoordinate2D)geographicMidpointOfArticleLocations
{
    CGFloat latitude, longitude = 0;
    for (Article *article in self.articles) {
        latitude += article.coordinate.latitude;
        longitude += article.coordinate.longitude;
    }
    latitude /= [self.articles count];
    longitude /= [self.articles count];
    return CLLocationCoordinate2DMake(latitude, longitude);
}

@end
