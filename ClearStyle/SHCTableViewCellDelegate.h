//
//  SHCTableViewCellDelegate.h
//  ClearStyle
//
//  Created by Naresh Kharecha on 04/05/13.
//  Copyright (c) 2013 NeXT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHCToDoItem.h"

@class SHCTableViewCell;

// A protocol that the SHCTableViewCell uses to inform of state change
@protocol SHCTableViewCellDelegate <NSObject>

// indicates that the given item has been deleted
- (void) toDoItemDeleted:(SHCToDoItem *) todoItem;

// indicating that the edit process has begun for the given cell
- (void) cellDidBeginEditing:(SHCTableViewCell *)cell;

// indicates that the edit process has commited for the given cell
- (void) CellDidEndEditing:(SHCTableViewCell *)cell;

@end
