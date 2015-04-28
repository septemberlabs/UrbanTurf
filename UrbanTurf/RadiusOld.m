//
//  RadiusOld.m
//  UrbanTurf
//
//  Created by Will Smith on 3/22/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "RadiusOld.h"
#import "Constants.h"

@interface RadiusOld ()
@property (weak, nonatomic) IBOutlet UILabel *radiusLabel;
@property (weak, nonatomic) IBOutlet UISlider *radiusSlider;
@property (weak, nonatomic) IBOutlet UILabel *minLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxLabel;
@end

@implementation RadiusOld

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // these values are fixed, so set them here
    self.radiusSlider.minimumValue = minRadius;
    self.minLabel.text = [NSString stringWithFormat:@"%.1f mi", minRadius];
    self.radiusSlider.maximumValue = maxRadius;
    self.maxLabel.text = [NSString stringWithFormat:@"%.1f mi", maxRadius];
    
    [self.radiusSlider addTarget:self action:@selector(updateLabel:) forControlEvents:UIControlEventValueChanged];
    [self.radiusSlider addTarget:self action:@selector(saveRadius:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // the radius value can change, so refresh it every time the view appears
    NSLog(@"user defaults: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    float currentRadius = [[NSUserDefaults standardUserDefaults] floatForKey:userDefaultsRadiusKey];
    self.radiusLabel.text = [NSString stringWithFormat:@"%.1f mi", currentRadius];
    self.radiusSlider.value = currentRadius;
}

- (void)updateLabel:(id)sender {
    self.radiusLabel.text = [NSString stringWithFormat:@"%.1f mi", self.radiusSlider.value];
}

- (void)saveRadius:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:self.radiusSlider.value forKey:userDefaultsRadiusKey];
    [defaults synchronize];
    
    NSLog(@"user defaults: %@", [defaults dictionaryRepresentation]);
}

@end
