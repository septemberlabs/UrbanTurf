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

static UIColor *_color1 = nil;
static UIColor *_color2 = nil;
static UIColor *_color3 = nil;
static UIColor *_color4 = nil;
static UIColor *_color5 = nil;
static UIColor *_color6 = nil;
static UIColor *_color7 = nil;
static UIColor *_color8 = nil;

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
    
    // RGB: 76, 183, 73. Hex: #4CB749. Green used throughout.
    _color1 = [UIColor colorWithRed:(76/255.f) green:(183/255.f) blue:(73/255.f) alpha: 1];
    
    // RGB: 155, 158, 161. Grey used for date on main article listing.
    _color2 = [UIColor colorWithRed:(155/255.f) green:(158/255.f) blue:(161/255.f) alpha: 1];
    
    // RGB: 229, 255, 226. Hex: #E5FFE2. Green used for scroll-selecting articles.
    // lightened color1 using this: http://www.cssfontstack.com/oldsites/hexcolortool/
    _color3 = [UIColor colorWithRed:(229/255.f) green:(255/255.f) blue:(226/255.f) alpha: 1];
    
    // RGB: 236, 236, 237. Hex: #ECECED. Light grey used for border on map in article view.
    _color4 = [UIColor colorWithRed:(211/255.f) green:(211/255.f) blue:(212/255.f) alpha: 1];
    
    // Light grey used for border between map and views beneath.
    _color5 = [UIColor lightGrayColor];
    
    // RGB: 81, 136, 33. Green used in title bar.
    //_color6 = [UIColor colorWithRed:(76/255.f) green:(183/255.f) blue:(73/255.f) alpha: 1];
    _color6 = [UIColor colorWithRed:(81/255.f) green:(136/255.f) blue:(33/255.f) alpha: 1];
    
    // White. For text in title bar.
    _color7 = [UIColor whiteColor];

    // Text field color in search bar.
    _color8 = [UIColor colorWithRed:(134/255.f) green:(172/255.f) blue:(100/255.f) alpha: 1];
    
}

#pragma mark Colors

+ (UIColor*)color1 { return _color1; }
+ (UIColor*)color2 { return _color2; }
+ (UIColor*)color3 { return _color3; }
+ (UIColor*)color4 { return _color4; }
+ (UIColor*)color5 { return _color5; }
+ (UIColor*)color6 { return _color6; }
+ (UIColor*)color7 { return _color7; }
+ (UIColor*)color8 { return _color8; }

@end