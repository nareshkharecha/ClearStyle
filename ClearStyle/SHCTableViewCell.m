//
//  SHCTableViewCell.m
//  ClearStyle
//
//  Created by Naresh Kharecha on 04/05/13.
//  Copyright (c) 2013 NeXT. All rights reserved.
//

#import "SHCTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "SHCStrikethroughLabel.h"

@implementation SHCTableViewCell {
    
    // Primary UI components
    CAGradientLayer *_gradientLayer;
	CALayer *_itemCompleteLayer;
    SHCStrikethroughLabel *_label;
    
    // Transient state
	BOOL _deleteOnDragRelease;
    BOOL _markCompleteOnDragRelease;
    CGPoint _originalCenter;
    
    // Contextual cues
	UILabel *_tickLabel;
	UILabel *_crossLabel;
}

const float LABEL_LEFT_MARGIN = 15.0f;
const float UI_CUES_MARGIN = 10.0f;
const float UI_CUES_WIDTH = 50.0f;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // add a tick and cross
        _tickLabel = [self createCueLabel];
        _tickLabel.text = @"\u2713";
        _tickLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_tickLabel];
        
        _crossLabel = [self createCueLabel];
        _crossLabel.text = @"\u2717";
        _crossLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_crossLabel];
        
		// create a label that renders the todo item text
		_label = [[SHCStrikethroughLabel alloc] initWithFrame:CGRectNull];
        _label.delegate = self;
        _label.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		_label.textColor = [UIColor whiteColor];
		_label.font = [UIFont boldSystemFontOfSize:16];
		_label.backgroundColor = [UIColor clearColor];
		[self addSubview:_label];
        
		// remove the default blue highlight for selected cells
		self.selectionStyle = UITableViewCellSelectionStyleNone;
        // add a layer that overlays the cell adding a subtle gradient effect
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = self.bounds;
        _gradientLayer.colors = @[(id)[[UIColor colorWithWhite:1.0f alpha:0.2f] CGColor],
                                  (id)[[UIColor colorWithWhite:1.0f alpha:0.1f] CGColor],
                                  (id)[[UIColor clearColor] CGColor],
                                  (id)[[UIColor colorWithWhite:0.5f alpha:0.1f] CGColor]];
        _gradientLayer.locations = @[@0.00f, @0.01f, @0.95f, @1.00f];
        [self.layer insertSublayer:_gradientLayer atIndex:0];
        
		// add a layer that renders a green background when an item is complete
		_itemCompleteLayer = [CALayer layer];
		_itemCompleteLayer.backgroundColor = [[[UIColor alloc] initWithRed:0.0 green:0.7 blue:0.0 alpha:1.0] CGColor];
		_itemCompleteLayer.hidden = YES;
		[self.layer insertSublayer:_itemCompleteLayer atIndex:0];
        
		// add a pan recognizer
		UIGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
		recognizer.delegate = self;
		[self addGestureRecognizer:recognizer];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    // ensure the gradient layers occupies the full bounds
    _gradientLayer.frame = self.bounds;
    _itemCompleteLayer.frame = self.bounds;
    _label.frame = CGRectMake(LABEL_LEFT_MARGIN, 0,
                              self.bounds.size.width - LABEL_LEFT_MARGIN,self.bounds.size.height);
    _tickLabel.frame = CGRectMake(-UI_CUES_WIDTH - UI_CUES_MARGIN, 0,
                                  UI_CUES_WIDTH, self.bounds.size.height);
    _crossLabel.frame = CGRectMake(self.bounds.size.width + UI_CUES_MARGIN, 0,
                                   UI_CUES_WIDTH, self.bounds.size.height);
}

-(void)setTodoItem:(SHCToDoItem *)todoItem {
    _todoItem = todoItem;
    // we must update all the visual state associated with the model item
    _label.text = todoItem.text;
    _label.strikethrough = todoItem.completed;
    _itemCompleteLayer.hidden = !todoItem.completed;
}

// utility method for creating the contextual cues
-(UILabel*) createCueLabel {
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectNull];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:40.0];
    label.backgroundColor = [UIColor clearColor];
    return label;
}

#pragma mark - horizontal pan gesture methods
-(BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [gestureRecognizer translationInView:[self superview]];
    // Check for horizontal gesture
    if (fabsf(translation.x) > fabsf(translation.y)) {
        return YES;
    }
    return NO;
}

-(void)handlePan:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
		// if the gesture has just started, record the current centre location
        _originalCenter = self.center;
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        // translate the center
        CGPoint translation = [recognizer translationInView:self];
        self.center = CGPointMake(_originalCenter.x + translation.x, _originalCenter.y);
        
        // determine whether the item has been dragged far enough to initiate a delete / complete
        _markCompleteOnDragRelease = self.frame.origin.x > self.frame.size.width / 2;
        _deleteOnDragRelease = self.frame.origin.x < -self.frame.size.width / 2;
        
		// Context cues
		// fade the contextual cues
		float cueAlpha = fabsf(self.frame.origin.x) / (self.frame.size.width / 2);
		_tickLabel.alpha = cueAlpha;
		_crossLabel.alpha = cueAlpha;
        
		// indicate when the item have been pulled far enough to invoke the given action
		_tickLabel.textColor = _markCompleteOnDragRelease ?
        [UIColor greenColor] : [UIColor whiteColor];
		_crossLabel.textColor = _deleteOnDragRelease ?
        [UIColor redColor] : [UIColor whiteColor];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        // the frame this cell would have had before being dragged
        CGRect originalFrame = CGRectMake(0, self.frame.origin.y,
                                          self.bounds.size.width, self.bounds.size.height);
        if (!_deleteOnDragRelease) {
            // if the item is not being deleted, snap back to the original location
            [UIView animateWithDuration:0.15
                             animations:^{
                                 self.frame = originalFrame;
                             }
             ];
        }
		if (_deleteOnDragRelease) {
			// notify the delegate that this item should be deleted
			[self.delegate toDoItemDeleted:self.todoItem];
		}
        
        /*if (!_markCompleteOnDragRelease) {
            self.todoItem.completed = NO;
            _itemCompleteLayer.hidden = YES;
            _label.strikethrough = NO;
        }*/
        
        if (_markCompleteOnDragRelease) {
            // mark the item as complete and update the UI state
            self.todoItem.completed = YES;
            _itemCompleteLayer.hidden = NO;
            _label.strikethrough = YES;
        }
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // close the keyboard on enter
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    // disable editing on completed to do items
    return !self.todoItem.completed;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.delegate CellDidEndEditing:self];

    // set the model object state when an edit has complete
    self.todoItem.text = textField.text;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.delegate cellDidBeginEditing:self];
}
@end
