//
//  SaveFavoriteLocation.m
//  UrbanTurf
//
//  Created by Will Smith on 3/11/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "SaveFavoriteLocation.h"

@interface SaveFavoriteLocation ()
@property (weak, nonatomic) IBOutlet UILabel *latlonLabel;
@end

@implementation SaveFavoriteLocation

- (void)viewDidLoad {
    [super viewDidLoad];
    self.latlonLabel.text = [NSString stringWithFormat:@"%f, %f", self.currentLocation.latitude, self.currentLocation.longitude];
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
