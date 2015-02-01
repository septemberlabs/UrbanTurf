//
//  ArticleTableViewCell.h
//  UrbanTurf
//
//  Created by Will Smith on 12/26/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *articleImageView;
@property (weak, nonatomic) IBOutlet UILabel *articleHeadline;
@property (weak, nonatomic) IBOutlet UILabel *articleCopy;
@property (weak, nonatomic) IBOutlet UILabel *articleMetaInfo;

@end
