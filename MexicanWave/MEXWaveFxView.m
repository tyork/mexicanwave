//
//  MEXWaveFxView.m
//  MexicanWave
//
//  Created by Tom York on 14/03/2012.
//  Copyright (c) 2012 Yell Group Plc. All rights reserved.
//

#import "MEXWaveFxView.h"
#import "MEXLampView.h"

#define kActiveTime 0.5

@interface MEXWaveFxView ()
@property (nonatomic,retain,readwrite) NSArray* lampViews;
@end


@implementation MEXWaveFxView

@synthesize lampViews;

- (id)initWithFrame:(CGRect)frame {
    if(!(self = [super initWithFrame:frame])) {
        return nil;
    }
    
    return self;
}

- (void)dealloc {
    [lampViews release];
    [super dealloc];
}

- (void)configureLampsWithLocations:(NSArray*)locations scaleFactors:(NSArray*)scaleFactors {
    NSAssert(locations.count == scaleFactors.count, @"Size mismatch between lamp location and scale factor arrays");

    // No existing lamp views are reused but configureLamps is not expected to be called often.
    [self.lampViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSMutableArray* newLamps = [[[NSMutableArray alloc] initWithCapacity:locations.count] autorelease];
    for(NSUInteger lampIndex = 0; lampIndex < locations.count; lampIndex++) {
        MEXLampView* oneNewLamp = [[MEXLampView alloc] initWithFrame:CGRectZero];
        [oneNewLamp sizeToFit];
        oneNewLamp.center = [[locations objectAtIndex:lampIndex] CGPointValue];
        oneNewLamp.bulbScale = [[scaleFactors objectAtIndex:lampIndex] floatValue];
        [self addSubview:oneNewLamp];
        [newLamps addObject:oneNewLamp];
        [oneNewLamp release];
    }
    
    self.lampViews = newLamps;
}

- (void)animateWithDuration:(NSTimeInterval)duration referenceAngle:(float)referenceAngle numberOfPeaks:(NSUInteger)peaksPerCycle {

    const NSUInteger numberOfLamps = self.lampViews.count;
    [self.lampViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MEXLampView* oneLamp = (MEXLampView*)obj;
        const float phase = (float)(idx * peaksPerCycle) / (float)numberOfLamps + referenceAngle/360.0f;        
        [oneLamp animateGlowWithCycleTime:duration activeTime:kActiveTime/(NSTimeInterval)peaksPerCycle phase:phase];
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}


@end
