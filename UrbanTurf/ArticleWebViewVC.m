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
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic) int componentsOfPageBeingLoaded; // the counter keeping track of how many components are currently being loaded.
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation ArticleWebViewVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlToLoad]]];
    
    self.spinner.hidesWhenStopped = YES;
    [self.spinner startAnimating];
    
    self.componentsOfPageBeingLoaded = 0;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.componentsOfPageBeingLoaded++;
    
    // if a timer exists remove it because we've just started loading another web object.
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.componentsOfPageBeingLoaded--;
    
    // if no objects are now loading start a timer. if that timer ends before other objects start loading, it likely means all the objects on the page have loaded and we stop the spinner.
    if (self.componentsOfPageBeingLoaded == 0) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(turnOffSpinner:) userInfo:nil repeats:NO];
    }
}

- (void)turnOffSpinner:(NSTimer *)timer
{
    [self.spinner stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Web page load failed: %@", error);
}

@end