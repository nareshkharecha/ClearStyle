//
//  SHCTableViewDragAddNew.m
//  ClearStyle
//
//  Created by Naresh Kharecha on 07/05/13.
//  Copyright (c) 2013 NeXT. All rights reserved.
//

#import "SHCTableViewDragAddNew.h"
#import "SHCTableViewCell.h"

@implementation SHCTableViewDragAddNew {
    // a cell that is rendered as a   placeholder to indicate where a new item is added
    SHCTableViewCell *_placeholderCell;
    
    // indicates the state of this behavior
    BOOL _pullDownnInProgress;
    
    // the table that this gesture is associated with
    SHCTableView *_tableView;
}

- (id)initWithTableView:(SHCTableView *)tableView
{
    self = [super init];
    if (self) {
        _placeholderCell = [[SHCTableViewCell alloc] init];
        _placeholderCell.backgroundColor = [UIColor redColor];
        
        _tableView = tableView;
        _tableView.delegate = self;
    }
    return self;
}

#pragma mark - UISCrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // this behaviour starts when a user pulls down while at the top of the table
    _pullDownnInProgress = scrollView.contentOffset.y <= 0.0f;
    if (_pullDownnInProgress) {
        // add your placeholder
        [_tableView insertSubview:_placeholderCell atIndex:0];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_pullDownnInProgress && _tableView.scrollView.contentOffset.y <= 0.0f) {
        // maintain the location of the placeholder
        _placeholderCell.frame = CGRectMake(0, - _tableView.scrollView.contentOffset.y - SHC_ROW_HEIGHT, _tableView.frame.size.width, SHC_ROW_HEIGHT);
        _placeholderCell.label.text = -_tableView.scrollView.contentOffset.y  > SHC_ROW_HEIGHT ? @"Release to Add Item" : @"Pull to Add Item";
        _placeholderCell.alpha = MIN(1.0f, - _tableView.scrollView.contentOffset.y / SHC_ROW_HEIGHT);
    }else{
        _pullDownnInProgress = false;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // check whether the user pulled far enough
    if (_pullDownnInProgress && - _tableView.scrollView.contentOffset.y > SHC_ROW_HEIGHT) {
        // TODO - add a new item
        [_tableView.dataSource itemAdded];
    }
    _pullDownnInProgress = false;
    [_placeholderCell removeFromSuperview];
}

@end
