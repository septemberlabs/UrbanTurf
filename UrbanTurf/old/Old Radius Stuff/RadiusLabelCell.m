//
//  RadiusLabelCell.m
//  UrbanTurf
//
//  Created by Will Smith on 4/2/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "RadiusLabelCell.h"
#import "Constants.h"

@implementation RadiusLabelCell

- (void)awakeFromNib {
    NSLog(@"user defaults: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    float currentRadius = [[NSUserDefaults standardUserDefaults] floatForKey:userDefaultsRadiusKey];
    self.radiusLabel.text = [NSString stringWithFormat:@"%.1f mi", currentRadius];
}

@end
