//
//  SHCToDoItem.m
//  ClearStyle
//
//  Created by Naresh Kharecha on 03/05/13.
//  Copyright (c) 2013 NeXT. All rights reserved.
//

#import "SHCToDoItem.h"

@implementation SHCToDoItem

- (id)initWithText:(NSString*)text {
    if (self = [super init]) {
		self.text = text;
    }
    return self;
}

+ (id)toDoItemWithText:(NSString *)text {
    return [[SHCToDoItem alloc] initWithText:text];
}

@end
