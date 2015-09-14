//
//  UIImage+ColorOverlay.m
//  UrbanTurf
//
//  Created by Will Smith on 9/10/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "UIImage+ColorOverlay.h"

@implementation UIImage (ColorOverlay)

// used by TabBarController to correctly color unselected tab text and icons, which apparently is quite difficult to do. thank you: http://stackoverflow.com/questions/11512783/unselected-uitabbar-color/24106632#24106632
- (UIImage *)imageWithColor:(UIColor *)color1
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color1 setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
