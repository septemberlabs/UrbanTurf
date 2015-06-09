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

- (CGFloat)dynamicallyCalculatedHeight
{
    CGFloat height =
    self.betweenSuperviewAndImage.constant +
    self.imageHeight.constant +
    self.betweenImageAndHeadline.constant +
    self.headlineHeight.constant +
    self.betweenHeadlineAndIntro.constant +
    self.introHeight.constant +
    self.betweenIntroAndMetaInfo.constant +
    self.metaInfoHeight.constant +
    self.betweenMetaInfoAndButton.constant +
    self.goToURLButton.frame.size.height;
    
    return height;
}


/*
- (CGSize)sizeThatFits:(CGSize)size
{
    NSLog(@"current size: %@", NSStringFromCGSize(self.frame.size));
    
    CGFloat width = self.frame.size.width;
    
    CGFloat height =
        self.betweenSuperviewAndImage.constant +
        self.imageHeight.constant +
        self.betweenImageAndHeadline.constant +
        self.headlineHeight.constant +
        self.betweenHeadlineAndIntro.constant +
        self.introHeight.constant +
        self.betweenIntroAndMetaInfo.constant +
        self.metaInfoHeight.constant +
        self.betweenMetaInfoAndButton.constant +
        self.goToURLButton.frame.size.height;

    NSLog(@"new size: %@", NSStringFromCGSize(self.frame.size));
    
    return CGSizeMake(width, height);
}
*/
 
@end
