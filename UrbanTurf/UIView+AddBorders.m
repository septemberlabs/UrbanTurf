//
//  UIView+AddBorders.m
//  UrbanTurf
//
//  Created by Will Smith on 6/18/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "UIView+AddBorders.h"

@implementation UIView (AddBorders)

// Thank you: http://stackoverflow.com/questions/17355280/how-to-add-a-border-just-on-the-top-side-of-a-uiview
- (CALayer *)addBorder:(UIRectEdge)edge color:(UIColor *)color thickness:(CGFloat)thickness
{
    CALayer *border = [CALayer layer];
    
    switch (edge) {
        case UIRectEdgeTop:
            border.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), thickness);
            break;
        case UIRectEdgeBottom:
            border.frame = CGRectMake(0, CGRectGetHeight(self.frame) - thickness, CGRectGetWidth(self.frame), thickness);
            break;
        case UIRectEdgeLeft:
            border.frame = CGRectMake(0, 0, thickness, CGRectGetHeight(self.frame));
            break;
        case UIRectEdgeRight:
            border.frame = CGRectMake(CGRectGetWidth(self.frame) - thickness, 0, thickness, CGRectGetHeight(self.frame));
            break;
        default:
            break;
    }
    
    border.backgroundColor = color.CGColor;
    
    [self.layer addSublayer:border];
    
    return border;
}

@end
