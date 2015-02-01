//
//  HoodieTableViewCell.h
//  Flickr Local
//
//  Created by Will Smith on 11/28/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HoodieTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageContainerView;
@property (weak, nonatomic) IBOutlet UILabel *textBox;
@property (weak, nonatomic) IBOutlet UILabel *leftUpperLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightUpperLabel;

@end
