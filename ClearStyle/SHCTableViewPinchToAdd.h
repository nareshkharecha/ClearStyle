//
//  SHCTableViewPinchToAdd.h
//  ClearStyle
//
//  Created by Naresh Kharecha on 08/05/13.
//  Copyright (c) 2013 NeXT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHCTableView.h"

// A behavior that adds the facility to pinch the list in order to insert a new item at any location

@interface SHCTableViewPinchToAdd : NSObject

// associates this behavior with the given table
- (id)initWithTableView:(SHCTableView *)tableView;

@end
