//
//  ArticleViewController.m
//  UrbanTurf
//
//  Created by Will Smith on 12/26/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import "ArticleViewController.h"
#import "ArticleView.h"
#import "AFHTTPSessionManager.h"
#import "UIImageView+AFNetworking.h"
#import "Constants.h"
#import "Stylesheet.h"

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // turn on the navigation bar, which we want for the Back button.
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self.articleView.imageView setImageWithURL:[NSURL URLWithString:self.article.imageURL]];
    self.articleView.imageView.contentMode = UIViewContentModeScaleAspectFit;
    NSLog(@"width: %f, height: %f", self.articleView.imageView.image.size.width, self.articleView.imageView.image.size.height);
    
    // headline.
    self.articleView.headlineLabel.backgroundColor = [UIColor whiteColor]; // reset to white in case some other color for debugging.
    self.articleView.headlineLabel.font = [[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] fontWithSize:FONT_POINT_SIZE];
    self.articleView.headlineLabel.numberOfLines = 2;
    self.articleView.headlineLabel.text = self.article.title;
    NSLog(@"headline: %@", self.article.title);
    
    // introduction.
    self.articleView.introductionLabel.backgroundColor = [UIColor whiteColor]; // reset to white in case some other color for debugging.
    self.articleView.introductionLabel.font = [[UIFont preferredFontForTextStyle:UIFontTextStyleBody] fontWithSize:FONT_POINT_SIZE];
    //self.articleView.introductionLabel.numberOfLines = 2;
    self.articleView.introductionLabel.text = self.article.introduction;
    
    // meta info.
    [self metaInfoAttributedString];
    
    // padding view.
    self.articleView.bottomPaddingView.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillLayoutSubviews
{
    self.articleViewHeight.constant = [self.articleView dynamicallyCalculatedHeight];
    [self processImage];
}

- (void)viewDidLayoutSubviews
{
    [self.articleView.mapImageView setImageWithURL:[self googleStaticMapURL]];
}

- (void)processImage
{
    
    
    NSLog(@"width: %f, height: %f", self.articleView.imageView.image.size.width, self.articleView.imageView.image.size.height);
    //NSLog(@"constant height: %f", self.articleView.imageHeight.constant);
    self.articleView.imageHeight.constant = self.articleView.imageView.image.size.height;
    self.articleView.imageView.contentMode = UIViewContentModeScaleToFill;
    //NSLog(@"constant height: %f", self.articleView.imageHeight.constant);
}

- (void)metaInfoAttributedString
{
    // set the background color to white since it may be some other color used for storyboard layout.
    self.articleView.metaInfoLabel.backgroundColor = [UIColor whiteColor];
    
    self.articleView.metaInfoLabel.font = [[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] fontWithSize:FONT_POINT_SIZE];
    // UNCOMMENT THIS? self.articleView.metaInfo.text = self.article.publication;
    NSDictionary *publicationAttributes = @{
                                            NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:FONT_POINT_SIZE], // this is a magic font; couldn't figure out how to bold this programmatically, resorted to hard coding the font name.
                                            NSForegroundColorAttributeName: [Stylesheet color1]
                                            };
    
    NSDictionary *dateAttributes = @{
                                     NSFontAttributeName: [[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] fontWithSize:FONT_POINT_SIZE],
                                     NSForegroundColorAttributeName: [Stylesheet color2]
                                     };
    
    // concatenate the publication name and date, separating them with •
    NSMutableString *metaInfoString = [self.article.publication mutableCopy];
    [metaInfoString appendString:[NSString stringWithFormat:@" • %@", self.article.date]];
    
    // make it attributed with publicationAttributes for the whole string.
    NSMutableAttributedString *metaInfoAttributedString = [[[NSAttributedString alloc] initWithString:metaInfoString attributes:publicationAttributes] mutableCopy];
    
    // re-attribute the date, which begins at the end of the publication string and continues through to the end.
    NSRange rangeOfDateInfo = NSMakeRange([self.article.publication length], ([metaInfoString length] - [self.article.publication length]));
    [metaInfoAttributedString setAttributes:dateAttributes range:rangeOfDateInfo];
    
    // set the label with the value
    self.articleView.metaInfoLabel.attributedText = metaInfoAttributedString;
}

- (NSURL *)googleStaticMapURL
{
    // format here: https://developers.google.com/maps/documentation/staticmaps/
    NSString *latlonString = [NSString stringWithFormat:@"%f,%f", self.article.coordinate.latitude, self.article.coordinate.longitude];
    NSString *mapDimensions = [NSString stringWithFormat:@"%dx%d", (int)self.articleView.mapImageView.frame.size.width, (int)self.articleView.mapImageView.frame.size.height];
    NSDictionary *params = @{
                             @"center" : latlonString,
                             @"zoom" : @"15",
                             @"size" : mapDimensions,
                             @"maptype" : @"roadmap",
                             @"markers" : latlonString,
                             @"scale" : @"2"
                             };
    NSString *mapImageURL = googleStaticMapBaseURL;
    for (NSString *paramKey in [params allKeys]) {
        NSString *paramValue = (NSString *)[params objectForKey:paramKey];
        mapImageURL = [mapImageURL stringByAppendingFormat:@"%@=%@&", paramKey, [paramValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    return [NSURL URLWithString:mapImageURL];
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