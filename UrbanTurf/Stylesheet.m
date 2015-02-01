//
//  Stylesheet.m
//  UrbanTurf
//
//  Created by Will Smith on 12/28/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import "Stylesheet.h"

@implementation Stylesheet

#pragma mark Cache

static UIColor* _color1 = nil;
static UIColor* _color2 = nil;

/*
 font of article headline in full article view:
 font-size: 36px;
 font-family: "Helvetica Neue";
 color: rgb(54, 63, 73);
 line-height: 1.333;

 font of article body in full article view:
 font-size: 28px;
 font-family: "Helvetica Neue";
 color: rgb(54, 63, 73);
 line-height: 1.429;

 font of article meta info in full article view:
 font-size: 24px;
 font-family: "Helvetica Neue";
 color: rgb(54, 63, 73);
 line-height: 1.2;

 "Read the Full Story" text on button
 font-size: 34px;
 font-family: "Helvetica Neue";
 color: rgb(255, 255, 255);
 line-height: 1.2;

 "Read the Full Story" button color
 background-color: rgb(76, 183, 73);
 
 #4cb749
 
 
 */

#pragma mark Initialization

+ (void)initialize
{
    // Colors Initialization
    _color1 = [UIColor colorWithRed:(76/255.f) green:(183/255.f) blue:(73/255.f) alpha: 1]; // RGB: 76, 183, 73. Green used throughout.
    _color2 = [UIColor colorWithRed:(155/255.f) green:(158/255.f) blue:(161/255.f) alpha: 1]; // RGB: 155, 158, 161. Grey used for date on main article listing.
}

#pragma mark Colors

+ (UIColor*)color1 { return _color1; }
+ (UIColor*)color2 { return _color2; }

@end