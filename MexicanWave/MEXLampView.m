//
//  MEXLampView.m
//  MexicanWave
//
//  Created by Tom York on 14/03/2012.
//  Copyright (c) 2012 Yell Group Plc. All rights reserved.
//

#import "MEXLampView.h"
#import <QuartzCore/QuartzCore.h>

@implementation MEXLampView

@synthesize bulbScale;

- (void)animateGlowWithCycleTime:(NSTimeInterval)cycleTime activeTime:(NSTimeInterval)activeTime phase:(float)phase {
    // TODO: smoothly continue
    [self cancelGlowAnimation];
    
    CAKeyframeAnimation* opacityAnim = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0],[NSNumber numberWithFloat:1],[NSNumber numberWithFloat:0],nil];
    opacityAnim.keyTimes = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.5*(1.0-activeTime)],[NSNumber numberWithFloat:0.5],[NSNumber numberWithFloat:0.5*(1.0+activeTime)],nil];
    opacityAnim.speed = 1.0/cycleTime;
    opacityAnim.duration = 1.0;
    opacityAnim.timeOffset = phase - 0.5;
    opacityAnim.repeatCount = HUGE_VALF;    // Repeat forever
    
    [self.layer addAnimation:opacityAnim forKey:@"glow"];
}

- (void)cancelGlowAnimation {
    [self.layer removeAnimationForKey:@"glow"];
}


- (void)setBulbScale:(float)newScale {
    NSAssert(self.subviews.count == 2, @"Bulb view or glow view or both not present in a lamp");
    bulbScale = newScale;
    UIView* bulbView = [self.subviews objectAtIndex:0];
    const CGFloat affineScale = MIN(1, MAX(bulbScale, 0));
    bulbView.transform = CGAffineTransformMakeScale(affineScale, affineScale);
    UIView* glowView = [self.subviews objectAtIndex:1];
    glowView.transform = CGAffineTransformMakeScale(affineScale, affineScale);
}

#pragma mark - Lifecycle

- (void)commonInitialization {
    bulbScale = 1.0f;
    
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    
    UIImageView* bulbView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"light-blob"]];
    [self addSubview:bulbView];
    [bulbView release];
    
    UIImageView* glowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flare"]];
    [self addSubview:glowView];
    [glowView release];  
    
    NSAssert(self.subviews.count == 2, @"Bulb view or glow view or both not present in a lamp");
}

- (id)initWithFrame:(CGRect)frame {
    if(!(self = [super initWithFrame:frame])) {
        return nil;
    }
    [self commonInitialization];    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if(!(self = [super initWithCoder:aDecoder])) {
        return nil;
    }
    [self commonInitialization];    
    return self;
}

#pragma mark - UIView

- (CGSize)sizeThatFits:(CGSize)size {
    NSAssert(self.subviews.count == 2, @"Bulb view or glow view or both not present in a lamp");
    UIImageView* glowView = (UIImageView*)[self.subviews objectAtIndex:1];
    return glowView.image.size;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSAssert(self.subviews.count == 2, @"Bulb view or glow view or both not present in a lamp");
    
    const CGPoint midBounds = CGPointMake(self.bounds.size.width*0.5f, self.bounds.size.height*0.5f);
    
    UIView* bulbView = [self.subviews objectAtIndex:0];
    [bulbView sizeToFit];
    bulbView.center = midBounds;
    
    UIView* glowView = [self.subviews objectAtIndex:1];
    [glowView sizeToFit];
    glowView.center = midBounds;
}

@end
