//
//  RadiusSliderCell.h
//  UrbanTurf
//
//  Created by Will Smith on 4/2/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RadiusSliderController;

@interface RadiusSliderCell : UITableViewCell
@property (nonatomic, weak) id<RadiusSliderController> delegate;
@property (weak, nonatomic) IBOutlet UILabel *minLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxLabel;
@property (weak, nonatomic) IBOutlet UISlider *radiusSlider;
@end

// delegate protocol
@protocol RadiusSliderController <NSObject>
@required
- (void)sliderMoved:(float)radiusSliderValue;
- (void)sliderReleased:(float)radiusSliderValue;
@end // end of delegate protocol
