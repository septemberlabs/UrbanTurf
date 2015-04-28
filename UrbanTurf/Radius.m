//
//  Radius.m
//  UrbanTurf
//
//  Created by Will Smith on 4/1/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "Radius.h"
#import "Constants.h"
#import "RadiusLabelCell.h"
#import "RadiusSliderCell.h"

@interface Radius ()
@property (weak, nonatomic) UISlider *radiusSlider;
@property (strong, nonatomic) UILabel *radiusLabel;
@end

@implementation Radius

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerNib:[UINib nibWithNibName:@"RadiusLabelCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"RadiusLabelCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"RadiusSliderCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"RadiusSliderCell"];
    
    self.tableView.layer.borderWidth = 1.0f;
    self.tableView.layer.borderColor = [[UIColor whiteColor] CGColor];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // the radius value can change, so refresh it every time the view appears
    NSLog(@"user defaults: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    float currentRadius = [[NSUserDefaults standardUserDefaults] floatForKey:userDefaultsRadiusKey];
    if (self.radiusLabel) self.radiusLabel.text = [NSString stringWithFormat:@"%.1f mi", currentRadius];
    if (self.radiusSlider) self.radiusSlider.value = currentRadius;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return RADIUS_TABLE_HEADER;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return RADIUS_TABLE_FOOTER;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        static NSString *CellIdentifier = @"RadiusLabelCell";
        RadiusLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        self.radiusLabel = cell.radiusLabel;
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"RadiusSliderCell";
        RadiusSliderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.delegate = self;
        self.radiusSlider = cell.radiusSlider;
        return cell;
    }
}

- (void)sliderMoved:(float)radiusSliderValue
{
    if (self.radiusLabel) {
        self.radiusLabel.text = [NSString stringWithFormat:@"%.1f mi", radiusSliderValue];
    }
}

- (void)sliderReleased:(float)radiusSliderValue
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:radiusSliderValue forKey:userDefaultsRadiusKey];
    [defaults synchronize];
    NSLog(@"user defaults: %@", [defaults dictionaryRepresentation]);
    /*
    NSLog(@"table height: %f", self.tableView.contentSize.height);
    NSLog(@"actual table height: %f", [self tableHeightBasedOnContents]);
     */
}

@end