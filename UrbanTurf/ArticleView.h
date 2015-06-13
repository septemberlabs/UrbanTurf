//
//  ArticleView.h
//  UrbanTurf
//
//  Created by Will Smith on 6/7/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface ArticleView : UIView

- (CGFloat)dynamicallyCalculatedHeight;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *mapImageView;
@property (weak, nonatomic) IBOutlet UILabel *headlineLabel;
@property (weak, nonatomic) IBOutlet UILabel *metaInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *introductionLabel;
@property (weak, nonatomic) IBOutlet UIButton *viewArticleButton;
@property (weak, nonatomic) IBOutlet UIView *bottomPaddingView;

// vertical spacing constraints, used to calculate height in sizeThatFits
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *betweenSuperviewAndImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *betweenImageAndMap;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *betweenMapAndHeadline;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headlineHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *betweenHeadlineAndMetaInfo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *metaInfoHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *betweenMetaInfoAndIntro;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *introHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *betweenIntroAndButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *betweenButtonAndPaddingView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *paddingViewHeight;
@end
