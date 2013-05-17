//
//  SHCTableViewPinchToAdd.m
//  ClearStyle
//
//  Created by Naresh Kharecha on 08/05/13.
//  Copyright (c) 2013 NeXT. All rights reserved.
//

#import "SHCTableViewPinchToAdd.h"
#import "SHCTableViewCell.h"

// represents the upper and lower points of a pinch
struct SHCTouchPoints
{
    CGPoint upper;
    CGPoint lower;
};
typedef struct SHCTouchPoints SHCTouchPoints;

@implementation SHCTableViewPinchToAdd
{
    // the table that this class extends and adds behavior to
    SHCTableView *_tableView;
    // a cell which is rendered as a placeholder to indicate where a new item is added
    SHCTableViewCell *_placeholderCell;
    
    // the indices of the upper and lower cells that are being pinched
    int _pointOneCellIndex;
    int _pointTwoCellIndex;
    
    // the location of the touch points when the pinch began
    SHCTouchPoints _initialTouchPoints;
    
    // indicates that the pinch is in progress
    BOOL _pinchInProgress;
    
    // indicates that the pinch was big enough to cause a new item to be added
    BOOL _pinchExceededRequiredDistance;
}

- (id)initWithTableView:(SHCTableView *)tableView
{
    self = [super init];
    if (self) {
        _placeholderCell = [[SHCTableViewCell alloc] init];
        _placeholderCell.backgroundColor = [UIColor redColor];
        _tableView = tableView;
        
        // add a pinch gesture recognizer
        UIGestureRecognizer *recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        [_tableView addGestureRecognizer:recognizer];
    }
    return self;
}

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer
{
    // TODO: clever code goes here
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self pinchStarted:recognizer];
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged && _pinchInProgress && recognizer.numberOfTouches == 2)
    {
        [self pinchChanged:recognizer];
    }
    
    if (recognizer.state ==  UIGestureRecognizerStateEnded) {
        [self pinchEnded:recognizer];
    }
}

- (void)pinchStarted:(UIPinchGestureRecognizer *)recognizer
{
    // find the touch - points
    _initialTouchPoints = [self getNormalisedTouchPoints:recognizer];
    
    // locate the cells that these points touch
    _pointOneCellIndex = -100;
    _pointTwoCellIndex = -100;
    
    NSArray *visibleCells = _tableView.visibleCells;
    for (int i=0; i < visibleCells.count; i++) {
        UIView *cell = (UIView *)visibleCells[i];
        if ([self viewContainsPoint:cell withPoint:_initialTouchPoints.upper]) {
            _pointOneCellIndex = i;
            // highlight the cell - just for debuging!
            //cell.backgroundColor = [UIColor purpleColor];
        }
        if ([self viewContainsPoint:cell withPoint:_initialTouchPoints.lower]) {
            _pointTwoCellIndex = i;
            // highlight the cell - just for debuging!
            //cell.backgroundColor = [UIColor purpleColor];
        }
    }
    
    // chck whether they are neighbours
    if (abs(_pointOneCellIndex - _pointTwoCellIndex) == 1) {
        // if so - intiate the pinch
        _pinchInProgress = YES;
        _pinchExceededRequiredDistance = NO;
        
        // show your placeholder cell
        SHCTableViewCell *precedingCell = (SHCTableViewCell *)(_tableView.visibleCells)[_pointOneCellIndex];
        _placeholderCell.frame = CGRectOffset(precedingCell.frame, 0.0f, SHC_ROW_HEIGHT / 2.0f);
        [_tableView.scrollView insertSubview:_placeholderCell atIndex:0];
    }
}

- (void)pinchChanged:(UIPinchGestureRecognizer *)recognizer
{
    // find the touch points
    SHCTouchPoints currentTouchPoints = [self getNormalisedTouchPoints:recognizer];
    
    // determine by how much each touch point has changed, add take the minimum delta
    float upperDelta = currentTouchPoints.upper.y - _initialTouchPoints.upper.y;
    float lowerDelta = _initialTouchPoints.lower.y - currentTouchPoints.lower.y;
    float delta = -MIN(0,MIN(upperDelta, lowerDelta));
    
    // offset the cells, negative for cells above, positive for those below
    NSArray *visibleCells = _tableView.visibleCells;
    for (int i =0; i < visibleCells.count; i++) {
        UIView *cell = (UIView *)visibleCells[i];
        if (i <= _pointOneCellIndex) {
            cell.transform = CGAffineTransformMakeTranslation(0, -delta);
        }
        if (i >= _pointTwoCellIndex) {
            cell.transform = CGAffineTransformMakeTranslation(0, delta);
        }
    }
    
    // scale the placeholder cell
    float gapSize = delta * 2;
    float cappedGapSize = MIN(gapSize, SHC_ROW_HEIGHT);
    _placeholderCell.transform = CGAffineTransformMakeScale(1.0f, cappedGapSize / SHC_ROW_HEIGHT);
    
    _placeholderCell.label.text = gapSize > SHC_ROW_HEIGHT ? @"Release to Add Item" : @"Pull to Add Item";
    
    _placeholderCell.alpha = MIN(1.0f, gapSize / SHC_ROW_HEIGHT);
    
    // determine wether they have pinched far enough
    _pinchExceededRequiredDistance = gapSize > SHC_ROW_HEIGHT;
}

- (void)pinchEnded:(UIPinchGestureRecognizer *)recognizer
{
    _pinchInProgress = false;
    
    // remove the placeholder cell
    _placeholderCell.transform = CGAffineTransformIdentity;
    [_placeholderCell removeFromSuperview];
    
    if (_pinchExceededRequiredDistance) {
        // add a new item
        int indexOffset = floor(_tableView.scrollView.contentOffset.y / SHC_ROW_HEIGHT);
        [_tableView.dataSource itemAddedAtIndex:_pointTwoCellIndex + indexOffset];
    }else {
        // otherwise animate back to position
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            NSArray *visibleCells = _tableView.visibleCells;
            for (SHCTableView *cell in visibleCells) {
                cell.transform = CGAffineTransformIdentity;
            }
        }
        completion:nil];
    }
}

// return the two touchpoints, ordering them to ensure that upper and lower are correctly indentified.
- (SHCTouchPoints) getNormalisedTouchPoints:(UIGestureRecognizer *)recogniser
{
    CGPoint pointOne = [recogniser locationOfTouch:0 inView:_tableView];
    CGPoint pointTwo = [recogniser locationOfTouch:1 inView:_tableView];
    
    // offset based on scroll
    pointOne.y += _tableView.scrollView.contentOffset.y;
    pointTwo.y += _tableView.scrollView.contentOffset.y;
    
    // ensure pointOne is the top_most
    if (pointOne.y > pointTwo.y) {
        CGPoint temp = pointOne;
        pointOne = pointTwo;
        pointTwo = temp;
    }
    SHCTouchPoints points = {pointOne, pointTwo};
    return points;
}

- (BOOL)viewContainsPoint:(UIView *)view withPoint:(CGPoint)point
{
    CGRect frame = view.frame;
    return (frame.origin.y < point.y) && (frame.origin.y + frame.size.height) > point.y;
}

@end
