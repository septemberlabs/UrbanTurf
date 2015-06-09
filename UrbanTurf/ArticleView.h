//
//  ArticleView.h
//  UrbanTurf
//
//  Created by Will Smith on 6/7/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleView : UIView

- (CGFloat)dynamicallyCalculatedHeight;

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *headline;
@property (weak, nonatomic) IBOutlet UILabel *introduction;
@property (weak, nonatomic) IBOutlet UILabel *metaInfo;
@property (weak, nonatomic) IBOutlet UIButton *viewArticleButton;

// vertical spacing constraints, used to calculate height in sizeThatFits
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *betweenSuperviewAndImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *betweenImageAndHeadline;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headlineHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *betweenHeadlineAndIntro;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *introHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *betweenIntroAndMetaInfo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *metaInfoHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *betweenMetaInfoAndButton;
@property (weak, nonatomic) IBOutlet UIButton *goToURLButton;

@end
