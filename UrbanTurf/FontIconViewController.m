//
//  FontIconViewController.m
//  UrbanTurf
//
//  Created by Will Smith on 1/29/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "FontIconViewController.h"

@interface FontIconViewController ()
@property (weak, nonatomic) IBOutlet UILabel *iconLabel;
@property (weak, nonatomic) IBOutlet UIButton *iconButton;
@end

@implementation FontIconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // HERE. figuring out how to load from fontello.ttf
    [self.iconLabel setFont:[UIFont fontWithName:@"fontello" size:30]];
    [self.iconLabel setText:[NSString stringWithUTF8String:"\ue806"]];
    
    [self.iconButton.titleLabel setFont:[UIFont fontWithName:@"fontello" size:30]];
    [self.iconButton setTitle:[NSString stringWithUTF8String:"\ue806"] forState:UIControlStateNormal];
    //[self.iconButton.titleLabel setText:@"NOT BUTTON"];
    
    //self.iconLabel.layer.borderColor = [UIColor redColor].CGColor;
    //self.iconLabel.layer.borderWidth = 1.0;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
