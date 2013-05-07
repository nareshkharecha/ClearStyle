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
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _placeholderCell = [[SHCTableViewCell alloc] init];
        _placeholderCell.backgroundColor = [UIColor redColor];
    }
    return self;
}

@end
