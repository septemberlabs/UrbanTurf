//
//  ArticleOverlayView.m
//  UrbanTurf
//
//  Created by Will Smith on 6/3/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//
//
//  Thank you: http://qnoid.com/2013/03/20/How-to-implement-a-reusable-UIView.html
//

#import "ArticleOverlayView.h"

@implementation ArticleOverlayView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSArray *views = [mainBundle loadNibNamed:NSStringFromClass([self class])
                                        owner:nil
                                      options:nil];
    [self addSubview:views[0]];
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSArray *views = [mainBundle loadNibNamed:NSStringFromClass([self class])
                                        owner:nil
                                      options:nil];
    [self addSubview:views[0]];
    
    return self;
}

@end
