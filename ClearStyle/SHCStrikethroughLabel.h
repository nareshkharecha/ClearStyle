//
//  SHCStrikethroughLabel.h
//  ClearStyle
//
//  Created by Naresh Kharecha on 04/05/13.
//  Copyright (c) 2013 NeXT. All rights reserved.
//

#import <UIKit/UIKit.h>

// A UILabel subclass that can optionally have a strikethrough.
@interface SHCStrikethroughLabel : UITextField

// A boolean value that determines whether the label should have a strikethrough.
@property(nonatomic) bool strikethrough;

@end
