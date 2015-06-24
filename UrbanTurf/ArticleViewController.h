//
//  ArticleViewController.h
//  UrbanTurf
//
//  Created by Will Smith on 12/26/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import "Article.h"

@interface ArticleViewController : UIViewController <UINavigationControllerDelegate>
@property (strong, nonatomic) Article *article;
@end
