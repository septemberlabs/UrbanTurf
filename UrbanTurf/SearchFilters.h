//
//  SearchFilters.h
//  UrbanTurf
//
//  Created by Will Smith on 8/17/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchFiltersDelegate; // forward declaration

@interface SearchFilters : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) id<SearchFiltersDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *displayOrders;
@property (strong, nonatomic) NSMutableArray *tags;
@end

// delegate protocol
@protocol SearchFiltersDelegate <NSObject>
@required
- (void)updateSearchFilters:(NSArray *)displayOrders tags:(NSArray *)tags;
@end // end of delegate protocol