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
#import "Constants.h"
#import "Stylesheet.h"
#import "UIImageView+AFNetworking.h"

@interface ArticleOverlayView ()

@property (strong, nonatomic) UIView *customViewFromXib;
@property (strong, nonatomic) NSArray *constraintsWithSuperview;

// related to panning when there are multiple articles at a single location.
@property (nonatomic) BOOL shouldRecognizeSimultaneouslyWithGestureRecognizer;
@property (nonatomic) BOOL panTriggered;
// subviews to the left/right when panning with multiple articles. just used during active pan and should be nil at all other times.
@property (strong, nonatomic) ArticleOverlayView *leftArticleSubview;
@property (strong, nonatomic) ArticleOverlayView *rightArticleSubview;
// the subview being swiped-in for swipe gestures.
@property (strong, nonatomic) ArticleOverlayView *enteringArticleSubview;

typedef NS_ENUM(NSInteger, ArticlePanDirection) {
    Left,
    Right,
    SnapBack
};

typedef NS_ENUM(NSInteger, SuperviewFeature) {
    TableCellSeparator
};

@end

@implementation ArticleOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }

    NSBundle *mainBundle = [NSBundle mainBundle];
    NSArray *nibViewsArray = [mainBundle loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    UIView *subview = nibViewsArray[0];
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:subview];
    
    // Thank you http://stackoverflow.com/a/16158361/4681708, item 5. Before this, the constraints that are set programmatically when this class is instantiated were not working properly.
    NSDictionary *views = NSDictionaryOfVariableBindings(subview);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subview]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subview]|" options:0 metrics:nil views:views]];
    
    [self configureUI];
    
    // save a pointer to the custom view loaded from the xib.
    self.customViewFromXib = subview;
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSArray *nibViewsArray = [mainBundle loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    UIView *subview = nibViewsArray[0];
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:subview];
    
    // Thank you http://stackoverflow.com/a/16158361/4681708, item 5. Before this, the constraints that are set programmatically when this class is instantiated were not working properly.
    NSDictionary *views = NSDictionaryOfVariableBindings(subview);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subview]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subview]|" options:0 metrics:nil views:views]];

    [self configureUI];

    // save a pointer to the custom view loaded from the xib.
    self.customViewFromXib = subview;
    
    return self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    self.customViewFromXib.backgroundColor = backgroundColor;
}

- (void)configureUI
{
    // reset the background colors to white in case some other color used in IB for debugging.
    self.placementInArrayLabel.backgroundColor = [UIColor clearColor];
    self.headlineLabel.backgroundColor = [UIColor clearColor];
    self.metaInfoLabel.backgroundColor = [UIColor clearColor];
    self.introLabel.backgroundColor = [UIColor clearColor];
    
    // add a light border around the images.
    self.imageView.layer.borderWidth = 1.0f;
    self.imageView.layer.borderColor = [Stylesheet color2].CGColor;
    
    // by default the view should recognize all GRs.
    self.shouldRecognizeSimultaneouslyWithGestureRecognizer = YES;
}

// the height of the view is calculated by summing the height of the right-side components (labels & such) and left-side components (mostly just the image view) and returning whichever is taller.
- (CGFloat)dynamicallyCalculatedHeight
{
    // all the labels and the spacing constraints between them constitute the right side content.
    CGFloat heightOfRightSideContent =
    self.betweenHeadlineAndSuperview.constant +
    self.headlineLabel.frame.size.height +
    self.betweenIntroAndHeadline.constant +
    self.introLabel.frame.size.height +
    self.betweenMetaInfoAndIntro.constant +
    self.metaInfoLabel.frame.size.height;
    
    // the image view and its spacing constraint at the top constitute the left side content.
    CGFloat heightOfLeftSideContent =
    self.betweenImageViewAndSuperview.constant +
    self.imageViewHeight.constant;
    
    NSLog(@"heightOfRightSideContent: %f", heightOfRightSideContent);
    NSLog(@"heightOfLeftSideContent: %f", heightOfLeftSideContent);
    
    // return whichever is taller.
    if (heightOfRightSideContent > heightOfLeftSideContent) {
        return heightOfRightSideContent;
    }
    else {
        return heightOfLeftSideContent;
    }
}

- (void)setEdgesToSuperview:(UIView *)superview leading:(CGFloat)leadingConstant trailing:(CGFloat)trailingConstant top:(CGFloat)topConstant bottom:(CGFloat)bottomConstant
{
    [self setEdgesToSuperview:superview leading:leadingConstant trailing:trailingConstant top:topConstant bottom:bottomConstant superviewFeature:0];
}

- (void)setEdgesToSuperview:(UIView *)superview leading:(CGFloat)leadingConstant trailing:(CGFloat)trailingConstant top:(CGFloat)topConstant bottom:(CGFloat)bottomConstant superviewFeature:(SuperviewFeature)superviewFeature
{
    // remove existing constraints if they are there.
    if (self.constraintsWithSuperview) {
        for (NSLayoutConstraint *constraint in self.constraintsWithSuperview) {
            [superview removeConstraint:constraint];
        }
    }
    
    NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                         attribute:NSLayoutAttributeLeading
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:superview
                                                                         attribute:NSLayoutAttributeLeading
                                                                        multiplier:1.0
                                                                          constant:leadingConstant];
    
    NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                          attribute:NSLayoutAttributeTrailing
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:superview
                                                                          attribute:NSLayoutAttributeTrailing
                                                                         multiplier:1.0
                                                                           constant:trailingConstant];
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:superview
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0
                                                                      constant:topConstant];
    
    // this allows the user to account for the one-pixel line at the bottom of table view cells.
    CGFloat finalConstant = bottomConstant;
    if (superviewFeature == TableCellSeparator) {
        finalConstant = bottomConstant - 1.0;
    }
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:superview
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0
                                                                         constant:finalConstant];
    /*
     For reference elsewhere:
     index 0: leading
     index 1: trailing
     index 2: top
     index 3: bottom
     */
    NSArray *arrayOfConstraints = [NSArray arrayWithObjects:leadingConstraint, trailingConstraint, topConstraint, bottomConstraint, nil];
    
    for (NSLayoutConstraint *constraint in arrayOfConstraints) {
        [superview addConstraint:constraint];
    }
    
    self.constraintsWithSuperview = arrayOfConstraints;
}

- (void)configureTeaserForArticle:(Article *)article
{
    self.article = article;
    [self.imageView setImageWithURL:[NSURL URLWithString:article.imageURL]]; // image
    self.headlineLabel.text = article.title; // headline
    self.introLabel.text = [article.introduction substringWithRange:NSMakeRange(0, 100)]; // body
    [self prepareMetaInfoStringForArticle:article]; // meta info
    
    GMSMarker *marker = article.marker;
    // there are multiple articles at this location.
    if ([marker.userData isKindOfClass:[NSMutableArray class]]) {
        NSArray *articlesArray = (NSArray *)marker.userData;
        NSUInteger indexOfArticle = [articlesArray indexOfObject:article];
        self.placementInArrayLabel.text = [NSString stringWithFormat:@"Article %d of %d", (int)(indexOfArticle+1), (int)[articlesArray count]];
    }
    // if marker.userData is not an array, this is the only article.
    else {
        self.placementInArrayLabel.text = @"";
    }

    [self layoutIfNeeded];
}

- (void)prepareMetaInfoStringForArticle:(Article *)article
{
    self.metaInfoLabel.text = article.publication;
    
    NSDictionary *publicationAttributes = @{
                                            NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:FONT_POINT_SIZE], // this is a magic font; couldn't figure out how to bold this programmatically, resorted to hard coding the font name.
                                            NSForegroundColorAttributeName: [Stylesheet color1]
                                            };
    NSDictionary *dateAttributes = @{
                                     NSFontAttributeName: [[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] fontWithSize:FONT_POINT_SIZE],
                                     NSForegroundColorAttributeName: [Stylesheet color2]
                                     };
    
    // concatenate the publication name and date, separating them with •
    NSMutableString *metaInfoString = [article.publication mutableCopy];
    [metaInfoString appendString:[NSString stringWithFormat:@" • %@", article.date]];
    
    // make it attributed with publicationAttributes for the whole string
    NSMutableAttributedString *metaInfoAttributedString = [[[NSAttributedString alloc] initWithString:metaInfoString attributes:publicationAttributes] mutableCopy];
    
    // re-attribute the date, which begins at the end of the publication string and continues through to the end
    NSRange rangeOfDateInfo = NSMakeRange([article.publication length], ([metaInfoString length] - [article.publication length]));
    [metaInfoAttributedString setAttributes:dateAttributes range:rangeOfDateInfo];
    
    // set the label with the value
    self.metaInfoLabel.attributedText = metaInfoAttributedString;
}

#pragma mark - Pan Gesture

- (UIPanGestureRecognizer *)addPanGestureRecognizer
{
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panArticleTeaser:)];
    [self addGestureRecognizer:panRecognizer];
    panRecognizer.delegate = self;

    // save the pan GR in the delegate in case it needs to use it.
    [self.delegate articleOverlayView:self saveGestureRecognizer:panRecognizer];

    return panRecognizer;
}

- (void)panArticleTeaser:(UIPanGestureRecognizer *)gestureRecognizer
{
    //NSLog(@"registered pan: %ld", (long)gestureRecognizer.state);
    NSLog(@"velocityInView: %@", NSStringFromCGPoint([gestureRecognizer velocityInView:self.superview]));
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        // zero out the state variables just in case.
        self.shouldRecognizeSimultaneouslyWithGestureRecognizer = YES;
        self.panTriggered = NO;
        self.leftArticleSubview = nil;
        self.rightArticleSubview = nil;
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        // wait to execute the actual panning until the user's finger has moved right/left panThreshold pixels. only then allow the pan (ie, flip the panThreshold toggle).
        if (!self.panTriggered && (fabs([gestureRecognizer translationInView:self.superview].x) >= PAN_THRESHOLD)) {
            self.shouldRecognizeSimultaneouslyWithGestureRecognizer = NO;
            self.panTriggered = YES;
            [gestureRecognizer setTranslation:CGPointMake(0,0) inView:self.superview];
            //[self.delegate articleOverlayView:self otherGestureRecognizersEnabled:NO]; // turn this off so that other gestures are not recognized until the pan finishes.
        }
        
        // if pan is triggered, setup neighboring article views on each side.
        // move each along with the translation of the main view.
        // when pan ends, calculate whichever has more than 50% of screen space, slide that one in, and update state.
        if (self.panTriggered) {
            
            // if self.leftArticleSubview hasn't been set, we need to set it and the right article subview. (could have checked for rightArticleSubview instead.)
            if (!self.leftArticleSubview) {
                
                Article *articleExiting = self.article;
                GMSMarker *marker = articleExiting.marker;
                NSArray *articlesArray = (NSArray *)marker.userData;
                NSUInteger indexOfArticleExiting = [articlesArray indexOfObject:articleExiting];
                
                // create two new article displays offscreen, one to the left and one to the right.
                self.leftArticleSubview = [self generateNeighboringArticleOverlayView:0 // 0 for left
                                                                 withFrame:self.superview.frame
                                                               inSuperview:self.superview
                                                    indexOfArticleExiting:indexOfArticleExiting
                                                             articlesArray:articlesArray];
                self.rightArticleSubview = [self generateNeighboringArticleOverlayView:1 // 1 for right
                                                                  withFrame:self.superview.frame
                                                                inSuperview:self.superview
                                                     indexOfArticleExiting:indexOfArticleExiting
                                                              articlesArray:articlesArray];
            }
            
            // move the target subview and its left and right neighbors.
            self.center = CGPointMake(self.center.x + [gestureRecognizer translationInView:self.superview].x, self.center.y);
            self.leftArticleSubview.center = CGPointMake(self.leftArticleSubview.center.x + [gestureRecognizer translationInView:self.superview].x, self.leftArticleSubview.center.y);
            self.rightArticleSubview.center = CGPointMake(self.rightArticleSubview.center.x + [gestureRecognizer translationInView:self.superview].x, self.rightArticleSubview.center.y);
            [gestureRecognizer setTranslation:CGPointMake(0,0) inView:self.superview];
        }
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        ArticlePanDirection panDirection = -1;
        // if the center point of the panned article is less than 0, it means it's off screen and the article to the right is more than half panned in, and should now be fully animated in.
        if (self.frame.origin.x < (-1 * self.frame.size.width * PANNED_DISTANCE_THRESHOLD)) {
            panDirection = Left;
        }
        // if the center point of the panned article is greater than the width of the table cell (its superview), it means it's off screen and the article to the left is more than half panned in, and should now be fully animated in.
        else if (self.frame.origin.x > (self.frame.size.width * PANNED_DISTANCE_THRESHOLD)) {
            panDirection = Right;
        }
        // if neither of the two conditions are true, snap back to the original article.
        else {
            panDirection = SnapBack;
        }
        
        if (panDirection == Left) {
            
            // force this here to catch up the layout in case it needs catching up since we'll be changing it below.
            [self.superview layoutIfNeeded];
            
            // slide the panned-out article a cell width. (negative value shifts it left.)
            CGFloat panDistance = -self.superview.frame.size.width;
            [self setEdgesToSuperview:self.superview leading:panDistance trailing:panDistance top:0 bottom:0 superviewFeature:TableCellSeparator];
            [self.rightArticleSubview setEdgesToSuperview:self.superview leading:0 trailing:0 top:0 bottom:0 superviewFeature:TableCellSeparator];
            
            // save the right-side article as the now visible article in the cell.
            //self.pannedCell.articleView = self.rightArticleSubview;
            [self.delegate setArticleOverlayView:self.rightArticleSubview];
            
        }
        else if (panDirection == Right) {
            
            // force this here to catch up the layout in case it needs catching up since we'll be changing it below.
            [self.superview layoutIfNeeded];
            
            // slide the panned-out article a cell width. (positive value shifts it right.)
            CGFloat panDistance = self.superview.frame.size.width;
            [self setEdgesToSuperview:self.superview leading:panDistance trailing:panDistance top:0 bottom:0 superviewFeature:TableCellSeparator];
            [self.leftArticleSubview setEdgesToSuperview:self.superview leading:0 trailing:0 top:0 bottom:0 superviewFeature:TableCellSeparator];
            
            // save the left-side article as the now visible article in the cell.
            //self.pannedCell.articleView = self.leftArticleSubview;
            [self.delegate setArticleOverlayView:self.leftArticleSubview];
            
        }
        // if neither of the two conditions evaluated true, then the article hasn't been panned more than halfway off the screen to the right or left, and should be kept as visible article.
        else {
            // we're not changing to the left or right article, instead keeping the article that was already visible. so we don't modify any constraints but do still force a layoutIfNeeded. the final effect is simply a "snap back" to the original visible state.
            [self.superview layoutIfNeeded];
            
            [self setEdgesToSuperview:self.superview leading:0 trailing:0 top:0 bottom:0 superviewFeature:TableCellSeparator];
            [self.leftArticleSubview setEdgesToSuperview:self.superview leading:-self.superview.frame.size.width trailing:-self.superview.frame.size.width top:0 bottom:0 superviewFeature:TableCellSeparator];
            [self.rightArticleSubview setEdgesToSuperview:self.superview leading:self.superview.frame.size.width trailing:self.superview.frame.size.width top:0 bottom:0 superviewFeature:TableCellSeparator];
        }
        
        // finally, to animate the swipe set the new constraints by calling layoutIfNeeded as the body of the animation.
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self.superview layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                         }];
        
        
        // upon completion of the animation, dispose of the two article views that are not visible. if a new article was panned in, delete the old pan gesture recognizer and add a new one on the panned-in article.
        if (panDirection == Left) {
            
            [self.delegate articleOverlayView:self deleteGestureRecognizer:gestureRecognizer]; // delete the panned-out article's gesture recognizer from the array of table view GRs.
            // create new pan & swipe GRs for the newly panned-in article.
            [self.rightArticleSubview addPanGestureRecognizer];
            [self.rightArticleSubview addSwipeGestureRecognizer];

            [self.leftArticleSubview removeFromSuperview];
            [self removeFromSuperview];
        }
        else if (panDirection == Right) {
            
            [self.delegate articleOverlayView:self deleteGestureRecognizer:gestureRecognizer]; // delete the panned-out article's gesture recognizer from the array of table view GRs.
            // create new pan & swipe GRs for the newly panned-in article.
            [self.leftArticleSubview addPanGestureRecognizer];
            [self.leftArticleSubview addSwipeGestureRecognizer];

            [self.rightArticleSubview removeFromSuperview];
            [self removeFromSuperview];
        }
        else {
            [self.leftArticleSubview removeFromSuperview];
            [self.rightArticleSubview removeFromSuperview];
        }
        
        //[self.delegate articleOverlayView:self otherGestureRecognizersEnabled:YES]; // turn other gestures back on.
        self.shouldRecognizeSimultaneouslyWithGestureRecognizer = YES;
        self.panTriggered = NO;
        self.leftArticleSubview = nil;
        self.rightArticleSubview = nil;
    }
    
}

#pragma mark - Swipe Gesture

- (UISwipeGestureRecognizer *)addSwipeGestureRecognizer
{
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeArticleTeaser:)];
    //[self addGestureRecognizer:swipeRecognizer];
    //swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight|UISwipeGestureRecognizerDirectionLeft;
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRecognizer.delegate = self;
    return swipeRecognizer;
}

- (void)swipeArticleTeaser:(UISwipeGestureRecognizer *)gestureRecognizer
{
    NSLog(@"registered swipe: %ld", (long)gestureRecognizer.state);
    
    if (gestureRecognizer.state == UIGestureRecognizerStateRecognized) { // FYI UIGestureRecognizerStateRecognized == UIGestureRecognizerStateEnded == 3
        
        self.shouldRecognizeSimultaneouslyWithGestureRecognizer = NO;
        
        Article *articleExiting = self.article;
        GMSMarker *marker = articleExiting.marker;
        NSArray *articlesArray = (NSArray *)marker.userData;
        NSUInteger indexOfArticleExiting = [articlesArray indexOfObject:articleExiting];
        
        int position = -1;
        
        // slide the panned-out article a cell width. (positive value shifts it right.)
        CGFloat swipeDistance;
        if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
            position = 0; // swiping right so need left subview.
            swipeDistance = self.superview.frame.size.width; // positive value for rightward movement.
        }
        else {
            position = 1; // swiping left so need right subview.
            swipeDistance = -self.superview.frame.size.width; // negative value for leftward movement.
        }
        // create new article display offscreen.
        self.enteringArticleSubview = [self generateNeighboringArticleOverlayView:position // 0 for left subview, 1 for right.
                                                                        withFrame:self.superview.frame
                                                                      inSuperview:self.superview
                                                            indexOfArticleExiting:indexOfArticleExiting
                                                                    articlesArray:articlesArray];
        
        // force this here to catch up the layout in case it needs catching up since we'll be changing it below.
        [self.superview layoutIfNeeded];
        
        // set the new constraints that will cause the animation.
        [self setEdgesToSuperview:self.superview leading:swipeDistance trailing:swipeDistance top:0 bottom:0 superviewFeature:TableCellSeparator];
        [self.enteringArticleSubview setEdgesToSuperview:self.superview leading:0 trailing:0 top:0 bottom:0 superviewFeature:TableCellSeparator];
        
        // set the delegate's article to the new one.
        [self.delegate setArticleOverlayView:self.enteringArticleSubview];
        
        // finally, to animate the swipe set the new constraints by calling layoutIfNeeded as the body of the animation.
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self.superview layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                             [self removeFromSuperview]; // remove the swiped-out subview (which is self).
                         }];
        
        [self.enteringArticleSubview addSwipeGestureRecognizer]; // create a new swipe GR for the newly swiped-in article.
     
        self.shouldRecognizeSimultaneouslyWithGestureRecognizer = NO;
    }
}

#pragma mark - Gesture Support Methods

- (ArticleOverlayView *)generateNeighboringArticleOverlayView:(int)position withFrame:(CGRect)frame inSuperview:(UIView *)superview indexOfArticleExiting:(NSUInteger)indexOfArticleExiting articlesArray:(NSArray *)articlesArray
{
    // LEFT: position == 0
    // RIGHT: position == 1
    
    ArticleOverlayView *articleSubview = [[ArticleOverlayView alloc] initWithFrame:frame];
    articleSubview.translatesAutoresizingMaskIntoConstraints = NO;
    articleSubview.delegate = self.delegate;
    [superview addSubview:articleSubview];
    
    // if we're generating an overlay to the left, the leading and trailing constraints should be one cell-width to the left (off screen). if right, one cell-width to the right (also off screen).
    CGFloat leadingTrailingConstraint = 0.0;
    if (position == 0) { // LEFT
        leadingTrailingConstraint = -superview.frame.size.width;
    }
    else { // RIGHT
        leadingTrailingConstraint = superview.frame.size.width;
    }
    
    [articleSubview setEdgesToSuperview:superview
                                leading:leadingTrailingConstraint
                               trailing:leadingTrailingConstraint
                                    top:0
                                 bottom:0
                       superviewFeature:TableCellSeparator];
    
    // calculate the index of the new article, addressing special cases for if the article being panned out is at one end or the other of the array.
    NSUInteger articleIndex;
    if (position == 0) { // LEFT
        // if left article is being generated but we're already at the first article in the array, set the index to the last index in the array.
        if (indexOfArticleExiting == 0) {
            articleIndex = ([articlesArray count] - 1);
        }
        // otherwise, just decrement the index and use that article.
        else {
            articleIndex = indexOfArticleExiting - 1;
        }
    }
    else { // RIGHT
        // if right article is being generated but we're already at the last article in the array, set the index to the first index in the array (0).
        if (indexOfArticleExiting == ([articlesArray count] - 1)) {
            articleIndex = 0;
        }
        // otherwise, just increment the index and use that article.
        else {
            articleIndex = indexOfArticleExiting + 1;
        }
    }
    
    [articleSubview configureTeaserForArticle:[articlesArray objectAtIndex:articleIndex]];
    articleSubview.backgroundColor = self.customViewFromXib.backgroundColor;
    
    return articleSubview;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    //NSLog(@"shouldRecognizeSimultaneouslyWithGestureRecognizer called: %@", self.shouldRecognizeSimultaneouslyWithGestureRecognizer ? @"YES" : @"NO");
    return self.shouldRecognizeSimultaneouslyWithGestureRecognizer;
}

@end
