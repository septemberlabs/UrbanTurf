//
//  UIView+AddBorders.h
//  UrbanTurf
//
//  Created by Will Smith on 6/18/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AddBorders)
- (CALayer *)addBorder:(UIRectEdge)edge color:(UIColor *)color thickness:(CGFloat)thickness;
@end
