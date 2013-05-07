//
//  SHCTableView.h
//  ClearStyle
//
//  Created by Naresh Kharecha on 05/05/13.
//  Copyright (c) 2013 NeXT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHCTableViewDataSource.h"

@interface SHCTableView : UIView <UIScrollViewDelegate>

// the object that acts as the datasource for this table
@property (nonatomic, assign) id<SHCTableViewDataSource> dataSource;

// the UIScrollView that hosts the table contents
@property (nonatomic, assign, readonly) UIScrollView *scrollView;

// dequeues a cell that can be reused
- (UIView *)dequeueReusableCell;

// register a class for use as new cells
- (void)registerClassForCells:(Class)cellClass;

// an array of cells that are currently visible, sorted from top to bottom.
- (NSArray *)visibleCells;

// forces the table to dispose of all the cells and re-buid the table
- (void)reloadData;

@end
