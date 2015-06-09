//
//  ArticleViewController.m
//  UrbanTurf
//
//  Created by Will Smith on 12/26/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import "ArticleViewController.h"
#import "ArticleView.h"
#import "UIImageView+AFNetworking.h"

@interface ArticleViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *articleScrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *articleViewHeight;
@property (strong, nonatomic) IBOutlet ArticleView *articleView;
@end

/*
 Took a while to get scroll view working with the ArticleView nib. Finally, this was how:
 * Added typical constraints to scroll view in Interface Builder (leading, trailing, top, bottom all 0).
 * Added a UIView as a subview of the scroll view and set its custom class to be ArticleView. Added typical constraints to it (leading, trailing, top, bottom all 0).
 * Added two more key constraints: 1) Set the ArticleView width equal to the view controller view's width (NOT the scroll view's width) and 2) set the ArticleView height to an arbitrary value of 800. Then in viewWillLayoutSubviews (below), I changed that height constraint to a dynamically-calculated value returned from a custom method in the ArticleView class that sums the heights of all the UI elements including spacing constraints.
 
 The key idea here is that for the scroll view and Auto Layout to work in concert, the scroll view needed a well-defined width and height on which to base its own sizing. We used the view controller's view for the width and an arbitrary value of 800 for the height, with the idea that at runtime we would replace that height value with the actual value.
 */

@implementation ArticleViewController

- (void)viewWillLayoutSubviews
{
    self.articleViewHeight.constant = [self.articleView dynamicallyCalculatedHeight];
}

- (void)viewDidLayoutSubviews
{
    //[self listSubviewsOfView:self.view];
    //NSLog(@"%@", self.view);
    //NSLog(@"%@", self.navigationController.view);
}

- (void)setArticle:(Article *)article
{
    _article = article;
    [self.articleView.image setImageWithURL:[NSURL URLWithString:article.imageURL]];
    self.articleView.headline.text = @"Headline!";
    self.articleView.introduction.text = @"Introduction!";
    self.articleView.metaInfo.text = @"Meta Info!";
}

- (void)listSubviewsOfView:(UIView *)view
{
    NSArray *subviews = [view subviews]; // Get the subviews of the view.
    for (UIView *subview in subviews) {
        NSLog(@"%@", subview);
        [self listSubviewsOfView:subview]; // recursion.
    }
}

@end