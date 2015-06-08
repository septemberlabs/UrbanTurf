//
//  ArticleView.h
//  UrbanTurf
//
//  Created by Will Smith on 6/7/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *headline;
@property (weak, nonatomic) IBOutlet UILabel *introduction;
@property (weak, nonatomic) IBOutlet UILabel *metaInfo;
@property (weak, nonatomic) IBOutlet UIButton *viewArticleButton;
@end
