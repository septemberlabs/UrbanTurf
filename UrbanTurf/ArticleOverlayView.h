//
//  ArticleOverlayView.h
//  UrbanTurf
//
//  Created by Will Smith on 6/3/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"

@interface ArticleOverlayView : UIView

- (CGFloat)dynamicallyCalculatedHeight;

@property (strong, nonatomic) Article *article; // store a reference to the article being displayed to be able to identify which article it is.

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *headlineLabel;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet UILabel *metaInfoLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *betweenImageViewAndSuperview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *betweenHeadlineAndSuperview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *betweenIntroAndHeadline;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *betweenMetaInfoAndIntro;
@property (strong, nonatomic) NSArray *constraintsWithSuperview;

@end
