//
//  ArticleOverlayView.m
//  UrbanTurf
//
//  Created by Will Smith on 6/3/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//
//
//  Thank you: http://qnoid.com/2013/03/20/How-to-implement-a-reusable-UIView.html
//

#import "ArticleOverlayView.h"
#import "Stylesheet.h"

@interface ArticleOverlayView ()
@property (strong, nonatomic) UIView *customViewFromXib;
@end

@implementation ArticleOverlayView

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
    
    [self configureUI];
    
    // save a pointer to the custom view loaded from the xib.
    self.customViewFromXib = subview;
    
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

    [self configureUI];

    // save a pointer to the custom view loaded from the xib.
    self.customViewFromXib = subview;
    
    return self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    self.customViewFromXib.backgroundColor = backgroundColor;
}

- (void)configureUI
{
    // reset the background colors to white in case some other color used in IB for debugging.
    self.headlineLabel.backgroundColor = [UIColor clearColor];
    self.metaInfoLabel.backgroundColor = [UIColor clearColor];
    self.introLabel.backgroundColor = [UIColor clearColor];
    
    // add a light border around the images.
    self.imageView.layer.borderWidth = 1.0f;
    self.imageView.layer.borderColor = [Stylesheet color2].CGColor;
}

// the height of the view is calculated by summing the height of the right-side components (labels & such) and left-side components (mostly just the image view) and returning whichever is taller.
- (CGFloat)dynamicallyCalculatedHeight
{
    // all the labels and the spacing constraints between them constitute the right side content.
    CGFloat heightOfRightSideContent =
    self.betweenHeadlineAndSuperview.constant +
    self.headlineLabel.frame.size.height +
    self.betweenIntroAndHeadline.constant +
    self.introLabel.frame.size.height +
    self.betweenMetaInfoAndIntro.constant +
    self.metaInfoLabel.frame.size.height;
    
    // the image view and its spacing constraint at the top constitute the left side content.
    CGFloat heightOfLeftSideContent =
    self.betweenImageViewAndSuperview.constant +
    self.imageViewHeight.constant;
    
    NSLog(@"heightOfRightSideContent: %f", heightOfRightSideContent);
    NSLog(@"heightOfLeftSideContent: %f", heightOfLeftSideContent);
    
    // return whichever is taller.
    if (heightOfRightSideContent > heightOfLeftSideContent) {
        return heightOfRightSideContent;
    }
    else {
        return heightOfLeftSideContent;
    }
}

@end
