//
//  MEXCrowdTypeSelectionControl.m
//  MexicanWave
//
//  Created by Tom York on 15/03/2012.
//  Copyright (c) 2012 Yell Group Plc. All rights reserved.
//

#import "MEXCrowdTypeSelectionControl.h"
#import "MEXSegmentButtonControl.h"

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
    
    MEXSegmentButtonControl* leftButton = [[[MEXSegmentButtonControl alloc] initWithFrame:CGRectZero] autorelease];
    leftButton.backgroundImageView.image = [[UIImage imageNamed:@"button-l"] stretchableImageWithLeftCapWidth:39 topCapHeight:0];
    leftButton.imageView.image = [UIImage imageNamed:@"icon-group"];
    leftButton.titleView.text = @"Fun";
    leftButton.contentInsets = UIEdgeInsetsMake(0, 20.0f, 0, 5.0f);
    [leftButton addTarget:self action:@selector(didTapSegment:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:leftButton];

    UIImageView* leftDivider = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button-separator"]] autorelease];
    [self addSubview:leftDivider];
    
    MEXSegmentButtonControl* middleButton = [[[MEXSegmentButtonControl alloc] initWithFrame:CGRectZero] autorelease];
    middleButton.backgroundImageView.image = [UIImage imageNamed:@"button-m"];
    middleButton.imageView.image = [UIImage imageNamed:@"icon-music"];
    middleButton.titleView.text = @"Gig";
    middleButton.contentInsets = UIEdgeInsetsMake(0, 10.0f, 0, 10.0f);
    [middleButton addTarget:self action:@selector(didTapSegment:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:middleButton];

    UIImageView* rightDivider = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button-separator"]] autorelease];
    [self addSubview:rightDivider];

    MEXSegmentButtonControl* rightButton = [[[MEXSegmentButtonControl alloc] initWithFrame:CGRectZero] autorelease];
    rightButton.backgroundImageView.image = [[UIImage imageNamed:@"button-r"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
    rightButton.imageView.image = [UIImage imageNamed:@"icon-stadium"];
    rightButton.titleView.text = @"Stadium";
    rightButton.contentInsets = UIEdgeInsetsMake(0, 5.0f, 0, 20.0f);
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
    const CGSize middleButtonSize = [middleButton sizeThatFits:CGSizeZero];
    middleButton.frame = CGRectMake(CGRectGetMaxX(leftDivider.frame), 0, CGRectGetMinX(rightDivider.frame) - CGRectGetMaxX(leftDivider.frame), middleButtonSize.height);

}

@end
