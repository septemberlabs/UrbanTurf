//
//  NewsMapTableViewCell.h
//  UrbanTurf
//
//  Created by Will Smith on 6/6/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArticleOverlayView.h"

@interface NewsMapTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet ArticleOverlayView *articleView;
@end
