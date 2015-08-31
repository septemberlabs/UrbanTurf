//
//  SearchFilters.h
//  UrbanTurf
//
//  Created by Will Smith on 8/17/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchFiltersDelegate; // forward declaration

@interface SearchFilters : UIViewController <UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate>
@property (nonatomic, weak) id<SearchFiltersDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *displayOrders;
@property (strong, nonatomic) NSMutableArray *articleAges;
@property (strong, nonatomic) NSMutableArray *articleTags;
@end

// delegate protocol
@protocol SearchFiltersDelegate <NSObject>
@required
- (void)updateSearchFilters:(SearchFilters *)searchFiltersVC displayOrders:(NSArray *)displayOrders articleAges:(NSArray *)articleAges articleTags:(NSArray *)articleTags save:(BOOL)shouldUpdate;
@end // end of delegate protocol