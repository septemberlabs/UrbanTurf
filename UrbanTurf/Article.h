//
//  Article.h
//  UrbanTurf
//
//  Created by Will Smith on 11/18/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "ArticleContainer.h"

@interface Article : NSObject

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title; // this is the article headline. called title to comply with MKAnnotation protocol.
@property (nonatomic, copy) NSString *subtitle; // this isn't used. only here to comply with MKAnnotation protocol.
@property (nonatomic, strong) UIImage *actualImage;
@property (nonatomic, strong) NSString *article_id;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *headline;
@property (nonatomic, strong) NSString *publication;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *introduction;
@property (nonatomic, weak) ArticleContainer *container; // make this weak to avoid a retain cycle since the marker will point back to this.

- (id)initWithTitle:(NSString *)newTitle Location:(CLLocationCoordinate2D)location;

@end
