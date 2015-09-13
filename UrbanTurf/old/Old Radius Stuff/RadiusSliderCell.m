//
//  RadiusSliderCell.m
//  UrbanTurf
//
//  Created by Will Smith on 4/2/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "RadiusSliderCell.h"
#import "Constants.h"

@implementation RadiusSliderCell

- (void)awakeFromNib
{
    // these values are fixed, so set them here
    self.radiusSlider.minimumValue = minRadius;
    self.minLabel.text = [NSString stringWithFormat:@"%.1f mi", minRadius];
    self.radiusSlider.maximumValue = maxRadius;
    self.maxLabel.text = [NSString stringWithFormat:@"%.1f mi", maxRadius];

    [self.radiusSlider addTarget:self action:@selector(sliderMoved:) forControlEvents:UIControlEventValueChanged];
    [self.radiusSlider addTarget:self action:@selector(sliderReleased:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)sliderMoved:(id)sender
{
    [self.delegate sliderMoved:self.radiusSlider.value];
}

- (void)sliderReleased:(id)sender
{
    [self.delegate sliderReleased:self.radiusSlider.value];
}

@end
