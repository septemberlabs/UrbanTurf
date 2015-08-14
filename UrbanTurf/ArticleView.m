//
//  ArticleView.m
//  UrbanTurf
//
//  Created by Will Smith on 6/7/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "ArticleView.h"

@implementation ArticleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSArray *nibViewsArray = [mainBundle loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    UIView *subview = nibViewsArray[0];
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:subview];
    
    // Thank you http://stackoverflow.com/a/16158361/4681708, item 5. Before this, the constraints that are set programmatically when this class is instantiated were not working properly.
    NSDictionary *views = NSDictionaryOfVariableBindings(subview);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subview]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subview]|" options:0 metrics:nil views:views]];
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSArray *nibViewsArray = [mainBundle loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    UIView *subview = nibViewsArray[0];
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:subview];
    
    // Thank you http://stackoverflow.com/a/16158361/4681708, item 5. Before this, the constraints that are set programmatically when this class is instantiated were not working properly.
    NSDictionary *views = NSDictionaryOfVariableBindings(subview);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subview]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subview]|" options:0 metrics:nil views:views]];
    
    return self;
}

// since this view doesn't know about its containing VC, use notifications (which the VC registered for) to disseminate the news that the button was clicked.
- (IBAction)loadArticleButtonPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadArticleOnWebButtonTapped" object:self];
}

- (CGFloat)dynamicallyCalculatedHeight
{
    return
    self.betweenSuperviewAndImage.constant +
    self.imageView.frame.size.height +
    self.betweenImageAndMap.constant +
    self.mapHeight.constant +
    self.betweenMapAndHeadline.constant +
    self.headlineLabel.frame.size.height +
    self.betweenHeadlineAndMetaInfo.constant +
    self.metaInfoLabel.frame.size.height +
    self.betweenMetaInfoAndIntro.constant +
    self.introductionLabel.frame.size.height +
    self.betweenIntroAndButton.constant +
    self.viewArticleButton.frame.size.height +
    self.betweenButtonAndPaddingView.constant +
    self.paddingViewHeight.constant;
}

@end
