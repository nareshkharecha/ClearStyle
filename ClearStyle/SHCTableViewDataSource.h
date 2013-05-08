//
//  SHCTableViewDataSource.h
//  ClearStyle
//
//  Created by Naresh Kharecha on 05/05/13.
//  Copyright (c) 2013 NeXT. All rights reserved.
//

#import <Foundation/Foundation.h>

// The SHCTableViewDataSource is adopted by a class that is source of data for a SHCTableView

@protocol SHCTableViewDataSource <NSObject>

// indicates the number of rows in the table
- (NSInteger)numberOfRows;

// obtain the cell for the given row
- (UIView *)cellForRow:(NSInteger)row;

- (void)itemAdded;

@end
