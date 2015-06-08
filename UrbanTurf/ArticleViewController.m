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
@property (weak, nonatomic) IBOutlet ArticleView *articleView;
@end

@implementation ArticleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
