//
//  ArticleWebViewVC.m
//  UrbanTurf
//
//  Created by Will Smith on 8/13/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "ArticleWebViewVC.h"

@interface ArticleWebViewVC ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation ArticleWebViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.webView.scalesPageToFit = YES;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlToLoad]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
