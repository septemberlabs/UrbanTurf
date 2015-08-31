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
#import "NewsMap.h"
#import "ArticleWebViewVC.h"

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
    // set self to the delegate so we can capture and act on the action of the user tapping Back.
    self.navigationController.delegate = self;
    
    self.title = @"Article Preview";

    // image.
    [self.articleView.imageView setImageWithURL:[NSURL URLWithString:self.article.imageURL]];
    // the only way I found to make the image fill the full width (or height, if portrait layout) of the image view, then have the image view shrink its height to fit the exact height of the image is to 1) set the content mode to UIViewContentModeScaleAspectFit here, then 2) in viewWillLayoutSubviews change the height of the image view height to the image's new height after being adjusted by setting the content mode below, then 3) change the content mode of the image view to UIViewContentModeScaleToFill.
    self.articleView.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    // map.
    self.articleView.mapImageView.layer.borderWidth = 1.0f;
    self.articleView.mapImageView.layer.borderColor = [Stylesheet color4].CGColor;
   
    // headline.
    self.articleView.headlineLabel.backgroundColor = [UIColor clearColor]; // reset to clear in case some other color for debugging.
    self.articleView.headlineLabel.font = [[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] fontWithSize:18.0];
    //self.articleView.headlineLabel.numberOfLines = 2;
    self.articleView.headlineLabel.text = self.article.title;
    
    // introduction.
    self.articleView.introductionLabel.backgroundColor = [UIColor clearColor]; // reset to clear in case some other color for debugging.
    self.articleView.introductionLabel.font = [[UIFont preferredFontForTextStyle:UIFontTextStyleBody] fontWithSize:FONT_POINT_SIZE];
    //self.articleView.introductionLabel.numberOfLines = 2;
    self.articleView.introductionLabel.text = self.article.introduction;
    
    // meta info.
    [self metaInfoAttributedString];
    
    // button.
    self.articleView.viewArticleButton.backgroundColor = [Stylesheet color1];
    NSString *buttonTitle = [@"Read full article\nat " stringByAppendingString:self.article.publication];
    self.articleView.viewArticleButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.articleView.viewArticleButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.articleView.viewArticleButton setTitle:buttonTitle forState:UIControlStateNormal];

    // padding view.
    self.articleView.bottomPaddingView.backgroundColor = [UIColor clearColor];
    
    // get notified when the user taps the button to load the article's original source on the web. i couldn't figure out another way to have this VC react to the press of a button that is embedded in a nib and therefore the VC can't directly receive events for.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadArticleOnWeb:)
                                                 name:@"LoadArticleOnWebButtonTapped"
                                               object:self.articleView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadArticleOnWebButtonTapped" object:self.articleView];
}

- (void)viewWillLayoutSubviews
{
    [self processImage];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    // wait to load the map image until here since the map views's frame size won't be known earlier, and it is a required parameter for the URL.
    [self.articleView.mapImageView setImageWithURL:[self googleStaticMapURL]];

    // calculate the final article view height now that all the dynamic content has been loaded, and force one more layout.
    self.articleViewHeight.constant = [self.articleView dynamicallyCalculatedHeight];
    [self.view layoutIfNeeded];
}

- (void)processImage
{
    //NSLog(@"width: %f, height: %f", self.articleView.imageView.image.size.width, self.articleView.imageView.image.size.height);
    self.articleView.imageHeight.constant = self.articleView.imageView.image.size.height;
    self.articleView.imageView.contentMode = UIViewContentModeScaleToFill;
}

- (void)metaInfoAttributedString
{
    // set the background color to clear since it may be some other color used for storyboard layout.
    self.articleView.metaInfoLabel.backgroundColor = [UIColor clearColor];
    
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
    [metaInfoString appendString:[NSString stringWithFormat:@" • %@", [[Constants dateFormatter] stringFromDate:self.article.date]]];
    
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
                             @"zoom" : @"14",
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
    //NSLog(@"google static map url: %@", mapImageURL);
    return [NSURL URLWithString:mapImageURL];
}

// below we set the focus of the NewsMap to the article currently displayed in this VC.
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // verify that the VC about to be shown is the NewsMap.
    if ([viewController isKindOfClass:[NewsMap class]]) {
        NewsMap *newsMap = (NewsMap *)viewController;
        [newsMap setFocusOnArticleContainer:self.article.container];
        
        // unset this VC from being the nav bar's delegate since it has no need to be the delegate anymore so we should nullify that relationship.
        self.navigationController.delegate = nil;
    }
}

- (void)listSubviewsOfView:(UIView *)view
{
    NSArray *subviews = [view subviews]; // Get the subviews of the view.
    for (UIView *subview in subviews) {
        NSLog(@"%@", subview);
        [self listSubviewsOfView:subview]; // recursion.
    }
}

- (void)loadArticleOnWeb:(NSNotification *)userInfo
{
    [self performSegueWithIdentifier:@"DisplayArticleOriginalSource" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"DisplayArticleOriginalSource"]) {
        if ([segue.destinationViewController isKindOfClass:[ArticleWebViewVC class]]) {
            ArticleWebViewVC *articleWebViewVC = (ArticleWebViewVC *)segue.destinationViewController;
            articleWebViewVC.urlToLoad = self.article.url;
        }
    }
}

@end