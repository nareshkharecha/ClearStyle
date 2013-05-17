//
//  SHCViewController.m
//  ClearStyle
//
//  Created by Naresh Kharecha on 03/05/13.
//  Copyright (c) 2013 NeXT. All rights reserved.
//

#import "SHCViewController.h"
#import "SHCToDoItem.h"
#import "SHCTableViewCell.h"
#import "SHCTableViewDragAddNew.h"
#import "SHCTableViewPinchToAdd.h"

@interface SHCViewController ()

@end

@implementation SHCViewController
{
    // a array of to-do items
    NSMutableArray *_toDoItems;
    
    // the offcet applied to cell when entering "edit mode"
    float _editingOffset;
    SHCTableViewDragAddNew *_dragAddNew;
    
    SHCTableViewPinchToAdd *_pinchAddNew;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Create a dummy to-do list.
        _toDoItems = [[NSMutableArray alloc] init];
        [_toDoItems addObject:[SHCToDoItem toDoItemWithText:@"Feed Tha Cat"]];
        [_toDoItems addObject:[SHCToDoItem toDoItemWithText:@"Buy Eggs"]];
        [_toDoItems addObject:[SHCToDoItem toDoItemWithText:@"Pack Bags For WWDC"]];
        [_toDoItems addObject:[SHCToDoItem toDoItemWithText:@"Rule The Web"]];
        [_toDoItems addObject:[SHCToDoItem toDoItemWithText:@"Buy iPhon5"]];
        [_toDoItems addObject:[SHCToDoItem toDoItemWithText:@"Find Missing Socks"]];
        [_toDoItems addObject:[SHCToDoItem toDoItemWithText:@"Write a New Tutorial"]];
        [_toDoItems addObject:[SHCToDoItem toDoItemWithText:@"Master Objective-C"]];
        [_toDoItems addObject:[SHCToDoItem toDoItemWithText:@"Remember Your Birthday Treat"]];
        [_toDoItems addObject:[SHCToDoItem toDoItemWithText:@"Drink Less Beer"]];
        [_toDoItems addObject:[SHCToDoItem toDoItemWithText:@"Learn to Programming"]];
        [_toDoItems addObject:[SHCToDoItem toDoItemWithText:@"Take The Car to The garage"]];
        [_toDoItems addObject:[SHCToDoItem toDoItemWithText:@"Sell Things on ebay"]];
        [_toDoItems addObject:[SHCToDoItem toDoItemWithText:@"Launch The App on App Store"]];
        [_toDoItems addObject:[SHCToDoItem toDoItemWithText:@"Give Up"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor blackColor];
    
    [self.tableView registerClassForCells:[SHCTableViewCell class]];
    
    _dragAddNew = [[SHCTableViewDragAddNew alloc] initWithTableView:self.tableView];
    
    _pinchAddNew = [[SHCTableViewPinchToAdd alloc] initWithTableView:self.tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIColor *)colorForIndex:(NSInteger)index
{
    NSUInteger itemCount = _toDoItems.count - 1;
    float val = ((float)index / (float)itemCount) * 0.6;
    return [UIColor colorWithRed:1.0 green:val blue:0.0 alpha:1.0];
}

#pragma mark - SHCTableViewDataSource methods
- (NSInteger)numberOfRows
{
    return _toDoItems.count;
}

- (UITableViewCell *)cellForRow:(NSInteger)row
{
    SHCTableViewCell *cell = (SHCTableViewCell *)[self.tableView dequeueReusableCell];
    SHCToDoItem *item = _toDoItems[row];
    cell.todoItem = item;
    cell.delegate = self;
    cell.backgroundColor = [self colorForIndex:row];
    return cell;
}

- (void)itemAdded
{
    [self itemAddedAtIndex:0];
}

- (void)itemAddedAtIndex:(NSInteger)index
{
    // create the new item
    SHCToDoItem *toDoItem = [[SHCToDoItem alloc] init];
    [_toDoItems insertObject:toDoItem atIndex:index];
    
    // refresh the table
    [_tableView reloadData];
    
    // enter edit mode
    SHCTableViewCell *editCell;
    for (SHCTableViewCell *cell in _tableView.visibleCells) {
        if (cell.todoItem == toDoItem) {
            editCell = cell;
            break;
        }
    }
    [editCell.label becomeFirstResponder];
}

- (void)toDoItemDeleted:(SHCToDoItem *)todoItem
{
    float delay = 0.0;
    
    // remove the model object
    [_toDoItems removeObject:todoItem];
    
    // find the visible cells
    NSArray *visibleCells = [self.tableView visibleCells];
    
    UIView *lastView = [visibleCells lastObject];
    bool startAnimating = false;
    
    // iterate over all of the cells
    for (SHCTableViewCell *cell in visibleCells) {
        if (startAnimating) {
            [UIView animateWithDuration:0.3 delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                cell.frame = CGRectOffset(cell.frame, 0.0f, -cell.frame.size.height);
            }completion:^(BOOL finished){
                if (cell == lastView) {
                    [self.tableView reloadData];
                }
            }];
            delay+=0.03;
        }
        
        // if you have reached the item that was deleted, start animating
        if (cell.todoItem == todoItem) {
            startAnimating = true;
            cell.hidden = YES;
        }
    }
}

- (void)cellDidBeginEditing:(SHCTableViewCell *)editingCell
{
    _editingOffset = _tableView.scrollView.contentOffset.y - editingCell.frame.origin.y;
    for (SHCTableViewCell *cell in [_tableView visibleCells]) {
        [UIView animateWithDuration:0.3 animations:^{
            cell.frame = CGRectOffset(cell.frame, 0, _editingOffset);
            if (cell != editingCell) {
                cell.alpha = 0.3;
            }}];
    }
}

- (void)CellDidEndEditing:(SHCTableViewCell *)editingCell
{
    for (SHCTableViewCell *cell in [_tableView visibleCells]) {
        [UIView animateWithDuration:0.3 animations:^{
            cell.frame = CGRectOffset(cell.frame, 0, -_editingOffset);
            if (cell != editingCell) {
                cell.alpha = 1.0;
            }}];
    }
}

@end
