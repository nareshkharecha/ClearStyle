//
//  SHCViewController.h
//  ClearStyle
//
//  Created by Naresh Kharecha on 03/05/13.
//  Copyright (c) 2013 NeXT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHCTableViewCellDelegate.h"
#import "SHCTableView.h"
#import "SHCTableViewDragAddNew.h"

@interface SHCViewController : UIViewController <SHCTableViewDataSource, SHCTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet SHCTableView *tableView;

@end
