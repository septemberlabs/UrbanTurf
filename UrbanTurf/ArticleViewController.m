//
//  ArticleViewController.m
//  UrbanTurf
//
//  Created by Will Smith on 12/26/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import "ArticleViewController.h"
#import <MapKit/MapKit.h>

@interface ArticleViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *articleImage;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextView *articleHeadline;
@property (weak, nonatomic) IBOutlet UITextView *articleMetaInfo;
@property (weak, nonatomic) IBOutlet UITextView *articleBody;
@property (weak, nonatomic) IBOutlet UIButton *viewArticleButton;

@end

@implementation ArticleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setArticle:(Article *)article
{
    _article = article;
/*
    self.articleImage = ;
    self.articleHeadline = article[@"headline"];
    self.articleMetaInfo = article[@"publication"];
    self.articleBody = article[@"introduction"];
 */
}

@end
