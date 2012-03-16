//
//  MEXWaveFxView.m
//  MexicanWave
//
//  Created by Tom York on 14/03/2012.
//  Copyright (c) 2012 Yell Group Plc. All rights reserved.
//

#import "MEXWaveFxView.h"
#import "MEXLampView.h"

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

- (void)setLampLevelsForLinesFromCenter:(CGPoint)start angles:(NSArray*)lineAnglesInDegrees animated:(BOOL)animated {
        
    NSMutableArray* lineDirectionCosines = [[NSMutableArray alloc] initWithCapacity:lineAnglesInDegrees.count];
    
    [lineAnglesInDegrees enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        const float angleInDegrees = [obj floatValue];
        [lineDirectionCosines addObject:[NSValue valueWithCGPoint:CGPointMake(sinf((float)M_PI * angleInDegrees / 180.0f), cosf((float)M_PI * angleInDegrees / 180.0f))]];

    }];
    
    [UIView animateWithDuration:animated ? 0.1 : 0.0 animations:^{
        [self.lampViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MEXLampView* oneLamp = (MEXLampView*)obj;
            
            CGPoint toLamp = CGPointMake(oneLamp.center.x - start.x, oneLamp.center.y - start.y);
            const CGFloat toLampLength = sqrtf(toLamp.x*toLamp.x + toLamp.y*toLamp.y);
            toLamp.x /= toLampLength;
            toLamp.y /= toLampLength;
            
            __block float totalLevel = 0;
            [lineDirectionCosines enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                CGPoint oneCosines = [obj CGPointValue];
                const CGFloat glowLevel = powf(0.5f*(oneCosines.x*toLamp.x + oneCosines.y*toLamp.y) + 0.5f, 3);
                totalLevel = MAX(glowLevel, totalLevel);
            }];
            oneLamp.glowLevel = totalLevel;
        }];
    }];
    [lineDirectionCosines release];
}

- (void)setAllLampLevels:(float)intensity animated:(BOOL)animated {
    const float glowLevel = MIN(1, MAX(0, intensity));
    [UIView animateWithDuration:animated ? 0.1 : 0.0 animations:^{
        [self.lampViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [(MEXLampView*)obj setGlowLevel:glowLevel];
        }];
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}


@end
