//
//  MEXSegmentButtonControl.m
//  MexicanWave
//
//  Created by Tom York on 20/03/2012.
//  Copyright (c) 2012 Yell Group Plc. All rights reserved.
//

#import "MEXSegmentButtonControl.h"

#define kScaleFactor 0.5f
#define kSpacing 5.0f

@implementation MEXSegmentButtonControl

@synthesize imageView, titleView, contentInsets, backgroundImageView;

#pragma mark - States

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted];
    self.imageView.highlighted = highlighted;
    self.titleView.highlighted = highlighted;
}

#pragma mark - Lifecycle

- (void)commonInitialization {
    backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:backgroundImageView];
    titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.opaque = NO;
    titleView.textColor = [UIColor whiteColor];
    titleView.contentMode = UIViewContentModeRight;
    [self addSubview:titleView];
    imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:imageView];
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
    [backgroundImageView release];
    [imageView release];
    [titleView release];
    [super dealloc];
}

#pragma mark - Layout

- (CGSize)sizeThatFits:(CGSize)size {
    const CGSize backgroundImageSize = [self.backgroundImageView sizeThatFits:size];
    const CGSize imageSize = [self.imageView sizeThatFits:size];
    const CGSize labelSize = [self.titleView sizeThatFits:size];
    
    if(self.selected) {
        return CGSizeMake(self.contentInsets.left + self.contentInsets.right + imageSize.width * kScaleFactor + kSpacing + labelSize.width, backgroundImageSize.height); 
    }    
    return CGSizeMake(self.contentInsets.left + self.contentInsets.right + imageSize.width, backgroundImageSize.height);
}

- (void)layoutSubviews {
    [super layoutSubviews];
        
    self.backgroundImageView.frame = self.bounds;

    const CGSize imageSize = [self.imageView sizeThatFits:self.bounds.size];
    const CGFloat leftTitleEdge = self.contentInsets.left + imageSize.width * kScaleFactor + kSpacing;
    self.titleView.frame = CGRectMake(leftTitleEdge, 0, 100, self.bounds.size.height);
    if(self.selected) {
        self.titleView.alpha = 1.0f;
        self.imageView.frame = CGRectMake(self.contentInsets.left, 0.5f*(self.bounds.size.height - (self.contentInsets.top + self.contentInsets.bottom + imageSize.height * kScaleFactor)), imageSize.width * kScaleFactor, imageSize.height * kScaleFactor);
    }
    else {
        self.titleView.alpha = 0.0f;
        self.imageView.frame = CGRectMake(0.5f * (self.bounds.size.width - imageSize.width), 0.5f*(self.bounds.size.height - (self.contentInsets.top + self.contentInsets.bottom + imageSize.height)), imageSize.width, imageSize.height);
    }
}

@end
