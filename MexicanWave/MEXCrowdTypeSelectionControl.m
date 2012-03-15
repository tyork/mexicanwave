//
//  MEXCrowdTypeSelectionControl.m
//  MexicanWave
//
//  Created by Tom York on 15/03/2012.
//  Copyright (c) 2012 Yell Group Plc. All rights reserved.
//

#import "MEXCrowdTypeSelectionControl.h"

@interface MEXCrowdTypeSelectionControl ()
@property (nonatomic,retain) NSArray* buttons;
@end


@implementation MEXCrowdTypeSelectionControl

@synthesize selectedSegment;
@synthesize buttons;

- (void)setSelectedSegment:(MEXCrowdTypeSelectionSegment)newSegment {
    [self.buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setSelected:(idx == (int)newSegment)];
    }];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    if(selectedSegment != newSegment) {
        selectedSegment = newSegment;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)setSelectedSegment:(MEXCrowdTypeSelectionSegment)newSegment animated:(BOOL)animated {
    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
        [self setSelectedSegment:newSegment];
    }];
}

#pragma mark - Pick up button taps and turn into value change events

- (void)didTapSegment:(id)sender {
    const NSUInteger indexOfSegment = [self.buttons indexOfObject:sender];
    if(indexOfSegment != NSNotFound) {
        [self setSelectedSegment:(MEXCrowdTypeSelectionSegment)indexOfSegment animated:YES];
    }
}

#pragma mark - Lifecycle

- (void)commonInitialization {
    selectedSegment = MEXCrowdTypeSelectionSegmentLeft;
    
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    
    UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setBackgroundImage:[[UIImage imageNamed:@"button-l"] stretchableImageWithLeftCapWidth:39 topCapHeight:0] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"icon-group"] forState:UIControlStateNormal];
    [leftButton setTitle:@"Selected" forState:UIControlStateSelected];
    [leftButton setTitle:@"Selected" forState:UIControlStateSelected|UIControlStateHighlighted];
    [leftButton setContentEdgeInsets:UIEdgeInsetsMake(0, 20.0f, 0, 5.0f)];
    [leftButton addTarget:self action:@selector(didTapSegment:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:leftButton];

    UIImageView* leftDivider = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button-separator"]] autorelease];
    [self addSubview:leftDivider];
    
    UIButton* middleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [middleButton setBackgroundImage:[UIImage imageNamed:@"button-m"] forState:UIControlStateNormal];
    [middleButton setImage:[UIImage imageNamed:@"icon-music"] forState:UIControlStateNormal];
    [middleButton setTitle:@"Selected" forState:UIControlStateSelected];
    [middleButton setTitle:@"Selected" forState:UIControlStateSelected|UIControlStateHighlighted];
    [middleButton addTarget:self action:@selector(didTapSegment:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:middleButton];

    UIImageView* rightDivider = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button-separator"]] autorelease];
    [self addSubview:rightDivider];

    UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setBackgroundImage:[[UIImage imageNamed:@"button-r"] stretchableImageWithLeftCapWidth:1 topCapHeight:0] forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"icon-stadium"] forState:UIControlStateNormal];
    [rightButton setTitle:@"Selected" forState:UIControlStateSelected|UIControlStateHighlighted];
    [rightButton setTitle:@"Selected" forState:UIControlStateSelected];
    [rightButton setContentEdgeInsets:UIEdgeInsetsMake(0, 5.0f, 0, 20.0f)];
    [rightButton addTarget:self action:@selector(didTapSegment:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:rightButton];

    buttons = [[NSArray alloc] initWithObjects:leftButton,middleButton,rightButton,nil];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if(!(self = [super initWithCoder:aDecoder])) {
        return nil;
    }
    [self commonInitialization];    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if(!(self = [super initWithFrame:frame])) {
        return nil;
    }
    [self commonInitialization];    
    return self;
}

- (void)dealloc {
    [buttons release];
    [super dealloc];
}

#pragma mark - Layout


- (void)layoutSubviews {
    [super layoutSubviews];
    // TODO: generalise/simplify
    // Size and position the left and right buttons
    UIView* leftButton = [self.buttons objectAtIndex:0];
    const CGSize leftButtonSize = [leftButton sizeThatFits:CGSizeZero];
    leftButton.frame = CGRectMake(0, 0, leftButtonSize.width, leftButtonSize.height);
    
    UIView* rightButton = [self.buttons objectAtIndex:2];
    const CGSize rightButtonSize = [rightButton sizeThatFits:CGSizeZero];
    rightButton.frame = CGRectMake(self.bounds.size.width - rightButtonSize.width, 0, rightButtonSize.width, leftButtonSize.height);
    
    // Position the dividers
    UIView* leftDivider = [self.subviews objectAtIndex:1];
    const CGSize leftDividerSize = leftDivider.bounds.size;
    leftDivider.frame = CGRectMake(leftButtonSize.width, 0, leftDividerSize.width, leftDividerSize.height);
    
    UIView* rightDivider = [self.subviews objectAtIndex:3];
    const CGSize rightDividerSize = rightDivider.bounds.size;
    rightDivider.frame = CGRectMake(rightButton.frame.origin.x - rightDividerSize.width, 0, rightDividerSize.width, rightDividerSize.height);
    
    // Size and position the middle button.
    UIView* middleButton = [self.buttons objectAtIndex:1];
    const CGSize middleButtonSize = [rightButton sizeThatFits:CGSizeZero];
    middleButton.frame = CGRectMake(CGRectGetMaxX(leftDivider.frame), 0, CGRectGetMinX(rightDivider.frame) - CGRectGetMaxX(leftDivider.frame), middleButtonSize.height);
/*    
    __block CGFloat buttonWidth = 0.0f;
    [self.buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGSize minimumSize = [obj sizeThatFits:CGSizeZero];
        const NSUInteger indexAsButton = [self.buttons indexOfObject:obj];
        minimumSize.width = (indexAsButton != NSNotFound && indexAsButton == self.selectedSegment) ? 100.0f : minimumSize.width;        
        buttonWidth += minimumSize.width;            
    }];
    
    __block CGFloat currentOriginX = 0.0f;
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGSize minimumSize = [obj sizeThatFits:CGSizeZero];
        const NSUInteger indexAsButton = [self.buttons indexOfObject:obj];
        minimumSize.width = (indexAsButton != NSNotFound && indexAsButton == self.selectedSegment) ? 100.0f : minimumSize.width;
        
        if(idx < (self.subviews.count-1)) {
            [obj setBounds:CGRectMake(0, 0, minimumSize.width, minimumSize.height)];
            [obj setCenter:CGPointMake(minimumSize.width*0.5f + currentOriginX, 0.5f*minimumSize.height)];
            currentOriginX += minimumSize.width;            
        }
        
    }];    */
}

@end
