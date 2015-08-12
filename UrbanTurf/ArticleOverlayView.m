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

typedef NS_ENUM(NSInteger, ArticlePanDirection) {
    Left,
    Right,
    SnapBack
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
    self.headlineLabel.backgroundColor = [UIColor clearColor];
    self.metaInfoLabel.backgroundColor = [UIColor clearColor];
    self.introLabel.backgroundColor = [UIColor clearColor];
    
    // add a light border around the images.
    self.imageView.layer.borderWidth = 1.0f;
    self.imageView.layer.borderColor = [Stylesheet color2].CGColor;
}

- (void)setEdgesToSuperview:(UIView *)superview leading:(CGFloat)leadingConstant trailing:(CGFloat)trailingConstant top:(CGFloat)topConstant bottom:(CGFloat)bottomConstant
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
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:superview
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0
                                                                         constant:bottomConstant];
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

#pragma mark - Gestures

- (UIPanGestureRecognizer *)addPanGestureRecognizer
{
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panArticleTeaser:)];
    [self addGestureRecognizer:panRecognizer];
    panRecognizer.delegate = self;
    return panRecognizer;
}

- (void)panArticleTeaser:(UIPanGestureRecognizer *)gestureRecognizer
{
    //NSLog(@"registered pan: %ld", (long)gestureRecognizer.state);
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.panTriggered = FALSE;
        self.leftArticleSubview = nil;
        self.rightArticleSubview = nil;
        NSLog(@"superview's subviews: %@", self.superview.subviews);
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        // wait to execute the actual panning until the user's finger has moved right/left panThreshold pixels. only then allow the pan (ie, flip the panThreshold toggle).
        if (!self.panTriggered && (fabs([gestureRecognizer translationInView:self.superview].x) >= PAN_THRESHOLD)) {
            self.panTriggered = TRUE;
            [gestureRecognizer setTranslation:CGPointMake(0,0) inView:self.superview];
            self.shouldRecognizeSimultaneouslyWithGestureRecognizer = NO;
        }
        
        if (self.panTriggered) {
            
            // if pan is triggered, setup neighboring article views, on each side.
            // move each along with the translation of the main view.
            // when pan ends, calculate whichever has more than 50% of screen space, and slide that one in, and update state.
            
            // if self.leftArticleSubview hasn't been set, we need to set it and the right article subview. (could have checked for rightArticleSubview instead.)
            if (!self.leftArticleSubview) {
                
                Article *articleToPanOut = self.article;
                GMSMarker *marker = articleToPanOut.marker;
                NSArray *articlesArray = (NSArray *)marker.userData;
                NSUInteger indexOfArticleToPanOut = [articlesArray indexOfObject:articleToPanOut];
                
                // create two new article displays offscreen, one to the left and one to the right.
                self.leftArticleSubview = [self generateArticleOverlayView:0
                                                                 withFrame:self.superview.frame
                                                               inSuperview:self.superview
                                                    indexOfArticleToPanOut:indexOfArticleToPanOut
                                                             articlesArray:articlesArray];
                self.rightArticleSubview = [self generateArticleOverlayView:1
                                                                  withFrame:self.superview.frame
                                                                inSuperview:self.superview
                                                     indexOfArticleToPanOut:indexOfArticleToPanOut
                                                              articlesArray:articlesArray];
            }
            
            // move the target subview and its left and right neighbors
            self.center = CGPointMake(self.center.x + [gestureRecognizer translationInView:self.superview].x, self.center.y);
            self.leftArticleSubview.center = CGPointMake(self.leftArticleSubview.center.x + [gestureRecognizer translationInView:self.superview].x, self.leftArticleSubview.center.y);
            self.rightArticleSubview.center = CGPointMake(self.rightArticleSubview.center.x + [gestureRecognizer translationInView:self.superview].x, self.rightArticleSubview.center.y);
            [gestureRecognizer setTranslation:CGPointMake(0,0) inView:self.superview];
        }
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        /*
         if moved to the left or right 50+ percent
         animate fully off the screen the current articleView
         animate fully on the screen the neighboring articleView
         save state to indicate what the new displayed article is
         else
         animate the current articleView back to its original position
         animate the neighboring articleView back to its original position
         */
        
        ArticlePanDirection panDirection = -1;
        // if the center point of the panned article is less than 0, it means it's off screen and the article to the right is more than half panned in, and should now be fully animated in.
        if (self.center.x < 0) {
            panDirection = Left;
        }
        // if the center point of the panned article is greater than the width of the table cell (its superview), it means it's off screen and the article to the left is more than half panned in, and should now be fully animated in.
        else if (self.center.x > self.superview.frame.size.width) {
            panDirection = Right;
        }
        else {
            panDirection = SnapBack;
        }
        
        
        if (panDirection == Left) {
            
            NSLog(@"slide to the left");
            
            // force this here to catch up the layout in case it needs catching up since we'll be changing it below.
            [self.superview layoutIfNeeded];
            
            // slide the panned-out article a cell width. it's negative to shift it left.
            CGFloat panDistance = -self.superview.frame.size.width;
            [self setEdgesToSuperview:self.superview leading:panDistance trailing:panDistance top:0 bottom:-1.0]; // make this 1 pixel shy of the bottom so the cell dividers show.
            [self.rightArticleSubview setEdgesToSuperview:self.superview leading:0 trailing:0 top:0 bottom:-1.0]; // make this 1 pixel shy of the bottom so the cell dividers show.
            
            // save the right-side article as the now visible article in the cell.
            //self.pannedCell.articleView = self.rightArticleSubview;
            [self.delegate setArticleOverlayView:self.rightArticleSubview];
            
        }
        else if (panDirection == Right) {
            
            NSLog(@"slide to the right");
            
            // force this here to catch up the layout in case it needs catching up since we'll be changing it below.
            [self.superview layoutIfNeeded];
            
            // slide the panned-out article a cell width. it's positive to shift it right.
            CGFloat panDistance = self.superview.frame.size.width;
            [self setEdgesToSuperview:self.superview leading:panDistance trailing:panDistance top:0 bottom:-1.0]; // make this 1 pixel shy of the bottom so the cell dividers show.
            [self.leftArticleSubview setEdgesToSuperview:self.superview leading:0 trailing:0 top:0 bottom:-1.0]; // make this 1 pixel shy of the bottom so the cell dividers show.
            
            // save the left-side article as the now visible article in the cell.
            //self.pannedCell.articleView = self.leftArticleSubview;
            [self.delegate setArticleOverlayView:self.leftArticleSubview];
            
        }
        // if neither of the two conditions evaluated true, then the article hasn't been panned more than halfway off the screen to the right or left, and should be kept as visible article.
        else {
            // we're not changing to the left or right article, instead keeping the article that was already visible. so we don't modify any constraints but do still force a layoutIfNeeded. the final effect is simply a "snap back" to the original visible state.
            [self.superview layoutIfNeeded];
        }
        
        // finally, to animate the swipe set the new constraints by calling layoutIfNeeded as the body of the animation.
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self.superview layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                         }];
        
        
        // upon completion of the animation, dispose of the two article views that are not visible. if a new article was panned in, delete the old pan gesture recognizer and add a new one on the panned-in article.
        if (panDirection == Left) {
            
            NSLog(@"called 1???");
            
            [self.leftArticleSubview removeFromSuperview];
            [self removeFromSuperview];
            
            // delete the panned-out article's gesture recognizer from the array of table view GRs.
            [self.delegate articleOverlayView:self deleteGestureRecognizer:gestureRecognizer];
            // create a new pan GR for the newly panned-in article.
            UIPanGestureRecognizer *newPanGestureRecognizer = [self.rightArticleSubview addPanGestureRecognizer];
            // we save all the pan GRs so that we can deactivate them when the table view starts scrolling vertically.
            [self.delegate articleOverlayView:self saveGestureRecognizer:newPanGestureRecognizer];
            
        }
        else if (panDirection == Right) {
            
            NSLog(@"called 2???");
            
            [self.rightArticleSubview removeFromSuperview];
            [self removeFromSuperview];
            
            // delete the panned-out article's gesture recognizer from the array of table view GRs.
            [self.delegate articleOverlayView:self deleteGestureRecognizer:gestureRecognizer];
            // create a new pan GR for the newly panned-in article.
            UIPanGestureRecognizer *newPanGestureRecognizer = [self.leftArticleSubview addPanGestureRecognizer];
            // we save all the pan GRs so that we can deactivate them when the table view starts scrolling vertically.
            [self.delegate articleOverlayView:self saveGestureRecognizer:newPanGestureRecognizer];
            
        }
        else {
            [self.leftArticleSubview removeFromSuperview];
            [self.rightArticleSubview removeFromSuperview];
        }
        
        self.shouldRecognizeSimultaneouslyWithGestureRecognizer = YES;
        self.panTriggered = FALSE;
        self.leftArticleSubview = nil;
        self.rightArticleSubview = nil;
    }
    
}

- (ArticleOverlayView *)generateArticleOverlayView:(int)position withFrame:(CGRect)frame inSuperview:(UIView *)superview indexOfArticleToPanOut:(NSUInteger)indexOfArticleToPanOut articlesArray:(NSArray *)articlesArray
{
    // LEFT: position == 0
    // RIGHT: position == 1
    
    ArticleOverlayView *articleSubview = [[ArticleOverlayView alloc] initWithFrame:frame];
    articleSubview.translatesAutoresizingMaskIntoConstraints = NO;
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
                                 bottom:-1.0]; // make this 1 pixel shy of the bottom so the cell dividers show.
    
    // calculate the index of the new article, addressing special cases for if the article being panned out is at one end or the other of the array.
    NSUInteger articleIndex;
    if (position == 0) { // LEFT
        // if left article is being generated but we're already at the first article in the array, set the index to the last index in the array.
        if (indexOfArticleToPanOut == 0) {
            articleIndex = ([articlesArray count] - 1);
        }
        // otherwise, just decrement the index and use that article.
        else {
            articleIndex = indexOfArticleToPanOut - 1;
        }
    }
    else { // RIGHT
        // if right article is being generated but we're already at the last article in the array, set the index to the first index in the array (0).
        if (indexOfArticleToPanOut == ([articlesArray count] - 1)) {
            articleIndex = 0;
        }
        // otherwise, just increment the index and use that article.
        else {
            articleIndex = indexOfArticleToPanOut + 1;
        }
    }
    
    [articleSubview configureTeaserForArticle:[articlesArray objectAtIndex:articleIndex]];
    if (position == 0) articleSubview.backgroundColor = [UIColor greenColor];//self.pannedCell.articleView.backgroundColor;
    else articleSubview.backgroundColor = [UIColor purpleColor];//self.pannedCell.articleView.backgroundColor;
    
    return articleSubview;
    
}



/*
- (void)swipeArticleTeaser:(UISwipeGestureRecognizer *)gestureRecognizer
{
    NSLog(@"registered swipe: %ld", (long)gestureRecognizer.state);
    
    if (gestureRecognizer.state == UIGestureRecognizerStateRecognized) { // FYI UIGestureRecognizerStateRecognized == UIGestureRecognizerStateEnded == 3
        
        BOOL executeSwipe = FALSE;
        
        // get the cell where the user swiped.
        NewsMapTableViewCell *cell = (NewsMapTableViewCell *)[self.tableView cellForRowAtIndexPath:[self.tableView indexPathForRowAtPoint:[gestureRecognizer locationInView:self.tableView]]];
        
        // look at the array of articles at the marker represented by the cell to see if one exists at the previous/next index from the article currently displayed. that is, confirm we're not at the first/last article in the array.
        Article *articleToSwipeOut = cell.articleView.article;
        GMSMarker *marker = articleToSwipeOut.marker;
        NSUInteger indexOfArticleToSwipeOut = [marker.userData indexOfObject:articleToSwipeOut];
        CGFloat leadingTrailingConstraint = 0.0; // only used if swipe is executed.
        NSUInteger indexOfArticleToSwipeIn = -1; // only used if swipe is executed.
        if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
            // swiped right so check we're not at the first article.
            if (indexOfArticleToSwipeOut > 0) {
                // proceed
                executeSwipe = TRUE;
                // if the user swiped right, the leading/trailing constraints should be the cell's width to the left (meaning, negative).
                leadingTrailingConstraint = -cell.frame.size.width;
                // and the index should be one less (we're decrementing through the array by going right).
                indexOfArticleToSwipeIn = indexOfArticleToSwipeOut - 1;
            }
        }
        else {
            // swiped left so check we're not at the last article.
            if (indexOfArticleToSwipeOut < ([marker.userData count] - 1)) {
                // proceed
                executeSwipe = TRUE;
                // if the user swiped left, the leading/trailing constraints should be the cell's width to the right (meaning, positive)
                leadingTrailingConstraint = cell.frame.size.width;
                // and the index should be one less (we're decrementing through the array by going right).
                indexOfArticleToSwipeIn = indexOfArticleToSwipeOut + 1;
            }
        }
        
        if (executeSwipe) {
            
            // create the new article display offscreen, immediately to the right or left depending on swipe direction.
            ArticleOverlayView *articleOverlaySubviewOfArticleToSwipeIn = [[ArticleOverlayView alloc] initWithFrame:cell.frame];
            articleOverlaySubviewOfArticleToSwipeIn.translatesAutoresizingMaskIntoConstraints = NO;
            [cell addSubview:articleOverlaySubviewOfArticleToSwipeIn];
            [articleOverlaySubviewOfArticleToSwipeIn setEdgesToSuperview:cell leading:leadingTrailingConstraint trailing:leadingTrailingConstraint top:0 bottom:-1.0]; // make this 1 pixel shy of the bottom so the cell dividers show.
            cell.articleView = articleOverlaySubviewOfArticleToSwipeIn;
            
            [self configureArticleTeaserForSubview:articleOverlaySubviewOfArticleToSwipeIn withArticle:[marker.userData objectAtIndex:indexOfArticleToSwipeIn]];
            articleOverlaySubviewOfArticleToSwipeIn.backgroundColor = cell.articleView.backgroundColor;
            
            // add the gesture recognizer to the new subview.
            UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeArticleTeaser:)];
            [cell.articleView addGestureRecognizer:swipeRecognizer];
            swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight|UISwipeGestureRecognizerDirectionLeft;
            swipeRecognizer.delegate = self;
            
            // we know the indices for leading/trailing from setEdgesOfSubview.
            NSLayoutConstraint *leadingConstraintSwipedOutView = [cell.articleView.constraintsWithSuperview objectAtIndex:0];
            NSLayoutConstraint *trailingConstraintSwipedOutView = [cell.articleView.constraintsWithSuperview objectAtIndex:1];
            NSLayoutConstraint *leadingConstraintSwipedInView = [articleOverlaySubviewOfArticleToSwipeIn.constraintsWithSuperview objectAtIndex:0];
            NSLayoutConstraint *trailingConstraintSwipedInView = [articleOverlaySubviewOfArticleToSwipeIn.constraintsWithSuperview objectAtIndex:1];
            
            [cell layoutIfNeeded]; // force this here to catch up the layout in case it needs catching up since we'll be changing it below.
            
            // by subtracting the leadingTrailingConstraint from each one, we are effectively adding X value to the leading/trailing boundaries in the case of a right swipe (by negating the negative leadingTrailing), and subtracting X value in the case of left swipe.
            leadingConstraintSwipedOutView.constant = leadingConstraintSwipedOutView.constant - leadingTrailingConstraint;
            trailingConstraintSwipedOutView.constant = trailingConstraintSwipedOutView.constant - leadingTrailingConstraint;
            leadingConstraintSwipedInView.constant = leadingConstraintSwipedInView.constant - leadingTrailingConstraint;
            trailingConstraintSwipedInView.constant = trailingConstraintSwipedInView.constant - leadingTrailingConstraint;
            
            // finally, to animate the swipe set the new constraints by calling layoutIfNeeded as the body of the animation.
            [UIView animateWithDuration:0.2
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 [cell layoutIfNeeded];
                             }
                             completion:^(BOOL finished) {
                                 //[self.toggleListViewButton setTitle:[NSString stringWithUTF8String:"\ue803"] forState:UIControlStateNormal];
                                 //self.borderBetweenMapAndTable.opacity = 1.0; // display the border instantly once the animation has completed.
                             }];
            
            cell.articleView = articleOverlaySubviewOfArticleToSwipeIn;
            
        }
    }
}
 */

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

@end
