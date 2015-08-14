//
//  ArticleOverlayView.h
//  UrbanTurf
//
//  Created by Will Smith on 6/3/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"

@protocol ArticleOverlayViewDelegate; // forward declaration

@interface ArticleOverlayView : UIView <UIGestureRecognizerDelegate>
@property (nonatomic, weak) id<ArticleOverlayViewDelegate> delegate;
@property (strong, nonatomic) Article *article; // store a reference to the article being displayed to be able to identify which article it is.
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *placementInArrayLabel;
@property (weak, nonatomic) IBOutlet UILabel *headlineLabel;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet UILabel *metaInfoLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *betweenImageViewAndSuperview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *betweenHeadlineAndSuperview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *betweenIntroAndHeadline;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *betweenMetaInfoAndIntro;

- (CGFloat)dynamicallyCalculatedHeight;
- (void)setEdgesToSuperview:(UIView *)superview leading:(CGFloat)leadingConstant trailing:(CGFloat)trailingConstant top:(CGFloat)topConstant bottom:(CGFloat)bottomConstant;
- (void)configureTeaserForArticle:(Article *)article;
- (UIPanGestureRecognizer *)addPanGestureRecognizer;
- (UISwipeGestureRecognizer *)addSwipeGestureRecognizer;

@end

// delegate protocol
@protocol ArticleOverlayViewDelegate <NSObject>
@required
- (void)setArticleOverlayView:(ArticleOverlayView *)articleOverlayView;
- (void)articleOverlayView:(ArticleOverlayView *)articleOverlayView saveGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;
- (void)articleOverlayView:(ArticleOverlayView *)articleOverlayView deleteGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;
@end // end of delegate protocol
