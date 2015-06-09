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

@implementation ArticleViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"viewDidLoad");

    NSLog(@"scroll view frame size: %@", NSStringFromCGSize(self.articleScrollView.frame.size));
    NSLog(@"scroll view contentSize: %@", NSStringFromCGSize(self.articleScrollView.contentSize));
    /*
    self.articleView = [[ArticleView alloc] initWithFrame:CGRectMake(0, 0, 1000, 2000)];
    [self.articleScrollView addSubview:self.articleView];
     */
    
    /*
    self.articleView = [[ArticleView alloc] initWithFrame:CGRectMake(0, 0, self.articleScrollView.frame.size.width, self.articleScrollView.frame.size.height)];
    NSLog(@"frame size: %@", NSStringFromCGSize(self.articleScrollView.frame.size));
    [self.articleScrollView addSubview:self.articleView];
    self.articleScrollView.contentSize = self.articleView.frame.size;
    NSLog(@"frame size: %@", NSStringFromCGSize(self.articleView.frame.size));
     */

    /*
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.articleView
                                                                      attribute:NSLayoutAttributeLeading
                                                                      relatedBy:0
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1.0
                                                                       constant:0];
    [self.view addConstraint:leftConstraint];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.articleView
                                                                       attribute:NSLayoutAttributeTrailing
                                                                       relatedBy:0
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1.0
                                                                        constant:0];
    [self.view addConstraint:rightConstraint];
     */

}

- (void)viewWillLayoutSubviews
{
    NSLog(@"viewWillLayoutSubviews");
    NSLog(@"scroll view frame size: %@", NSStringFromCGSize(self.articleScrollView.frame.size));
    NSLog(@"scroll view contentSize: %@", NSStringFromCGSize(self.articleScrollView.contentSize));

    //self.articleView = [[ArticleView alloc] initWithFrame:CGRectMake(0, 0, self.articleScrollView.frame.size.width, self.articleScrollView.frame.size.height)];
    //[self.articleScrollView addSubview:self.articleView];
    //self.articleScrollView.contentSize = self.articleView.frame.size;

    NSLog(@"article view frame size: %@", NSStringFromCGSize(self.articleView.frame.size));
    
    //CGSize calculatedArticleViewSize = [self.articleView sizeThatFits:self.articleScrollView.frame.size];
    self.articleViewHeight.constant = [self.articleView dynamicallyCalculatedHeight];
    //CGFloat newHeight = [self.articleView dynamicallyCalculatedHeight];
    //self.articleViewHeight.constant = [self.articleView dynamicallyCalculatedHeight];

}

- (void)viewDidLayoutSubviews
{
    /*
    NSLog(@"viewDidLayoutSubviews");
    NSLog(@"scroll view frame size: %@", NSStringFromCGSize(self.articleScrollView.frame.size));
    NSLog(@"scroll view contentSize: %@", NSStringFromCGSize(self.articleScrollView.contentSize));
    //self.articleScrollView.contentSize = CGSizeMake(1000.00, 1000.0);
    NSLog(@"scroll view frame size: %@", NSStringFromCGSize(self.articleScrollView.frame.size));
    NSLog(@"scroll view contentSize: %@", NSStringFromCGSize(self.articleScrollView.contentSize));
     */
}

- (void)setArticle:(Article *)article
{
    _article = article;
    [self.articleView.image setImageWithURL:[NSURL URLWithString:article.imageURL]];
    self.articleView.headline.text = @"Headline!";
    self.articleView.introduction.text = @"Introduction!";
    self.articleView.metaInfo.text = @"Meta Info!";
}

@end
