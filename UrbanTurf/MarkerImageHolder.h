//
//  MarkerImageHolder.h
//  UrbanTurf
//
//  Created by Will Smith on 8/30/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArticleContainer.h"

@interface MarkerImageHolder : NSObject

- (UIImage *)getMarkerForArticleContainer:(ArticleContainer *)articleContainer selected:(BOOL)selected;

@end
