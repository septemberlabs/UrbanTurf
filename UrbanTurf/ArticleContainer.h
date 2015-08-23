//
//  ArticleContainer.h
//  UrbanTurf
//
//  Created by Will Smith on 8/20/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GMSMarker;
@class Article;

@interface ArticleContainer : NSObject

@property (strong, nonatomic) NSMutableArray *articles;
@property (strong, nonatomic) GMSMarker *marker; // marker.userData points back to this articleContainer.
@property (nonatomic) int indexOfDisplayedTeaser;

- (Article *)articleOfDisplayedTeaser;

@end
