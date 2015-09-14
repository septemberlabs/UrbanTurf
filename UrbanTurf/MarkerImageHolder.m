//
//  MarkerImageHolder.m
//  UrbanTurf
//
//  Created by Will Smith on 8/30/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "MarkerImageHolder.h"
#import "Constants.h"

@interface MarkerImageHolder ()
@property (strong, nonatomic) NSMutableDictionary *markerImages; // of UIImage
@end

@implementation MarkerImageHolder

- (NSMutableDictionary *)markerImages
{
    if (!_markerImages) {
        _markerImages = [[NSMutableDictionary alloc] init];
    }
    return _markerImages;
}

- (UIImage *)getMarkerForArticleContainer:(ArticleContainer *)articleContainer selected:(BOOL)selected
{
    NSString *imageName;
    // we have to fiddle with this a little because the first position is invalid so we don't count it in the count.
    int numberOfMarkerIcons = ((int)[[Constants mapMarkersSelected] count]) - 1;
    
    if (selected) {
        // if the number count is 1-9, choose the corresponding marker.
        if ([articleContainer.articles count] < numberOfMarkerIcons) {
            imageName = (NSString *)[[Constants mapMarkersSelected] objectAtIndex:[articleContainer.articles count]];
        }
        // otherwise, choose 9+ (which sits at the end of the array).
        else {
            imageName = (NSString *)[[Constants mapMarkersSelected] objectAtIndex:numberOfMarkerIcons];
        }
    }
    else {
        // if the number count is 1-9, choose the corresponding marker.
        if ([articleContainer.articles count] < numberOfMarkerIcons) {
            imageName = (NSString *)[[Constants mapMarkersDefault] objectAtIndex:[articleContainer.articles count]];
        }
        // otherwise, choose 9+ (which sits at the end of the array).
        else {
            imageName = (NSString *)[[Constants mapMarkersDefault] objectAtIndex:numberOfMarkerIcons];
        }
    }
    
    UIImage *markerImageToUse;
    if ([self.markerImages objectForKey:imageName] != nil) {
        markerImageToUse = (UIImage *)[self.markerImages objectForKey:imageName];
    }
    else {
        
        // these insets avoid the transparent-ish rim around the markers from registering taps.
        UIEdgeInsets insets;
        insets.top = 11.0;
        insets.bottom = 7.0;
        insets.right = 8.0;
        insets.left = 10.0;

        markerImageToUse = [[UIImage imageNamed:imageName] imageWithAlignmentRectInsets:insets];
        [self.markerImages setObject:markerImageToUse forKey:imageName];
    }
    
    return markerImageToUse;
}


@end
