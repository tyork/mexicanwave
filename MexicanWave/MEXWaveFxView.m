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

- (void)setAllLampIntensitiesForLineFromPoint:(CGPoint)start angle:(float)angleInDegrees animated:(BOOL)animated {
    
    const CGPoint lineDirectionCosines = CGPointMake(sinf((float)M_PI * angleInDegrees / 180.0f), cosf((float)M_PI * angleInDegrees / 180.0f));
    
    [UIView animateWithDuration:animated ? 0.1 : 0 animations:^{
        [self.lampViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MEXLampView* oneLamp = (MEXLampView*)obj;
                        
            CGPoint toLamp = CGPointMake(oneLamp.center.x - start.x, oneLamp.center.y - start.y);
            const CGFloat toLampLength = sqrtf(toLamp.x*toLamp.x + toLamp.y*toLamp.y);
            toLamp.x /= toLampLength;
            toLamp.y /= toLampLength;
            const CGFloat proportionalAlpha = 0.5f*(lineDirectionCosines.x*toLamp.x + lineDirectionCosines.y*toLamp.y) + 0.5f;
            oneLamp.alpha = proportionalAlpha*proportionalAlpha*proportionalAlpha;
        }];
    }];    
}


- (void)setLampIntensity:(float)intensity atLampIndex:(NSUInteger)lampIndex animated:(BOOL)animated {
    const float alphaToSet = MIN(1, MAX(0, intensity));
    MEXLampView* oneLamp = [self.lampViews objectAtIndex:lampIndex];
    
    [UIView animateWithDuration:animated ? 0.25 : 0 animations:^{
        oneLamp.alpha = alphaToSet;            
    }];
}

- (void)setAllLampIntensities:(float)intensity animated:(BOOL)animated {
    const float alphaToSet = MIN(1, MAX(0, intensity));

    [UIView animateWithDuration:animated ? 0.25 : 0 animations:^{
        [self.lampViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MEXLampView* oneLamp = (MEXLampView*)obj;
            oneLamp.alpha = alphaToSet;            
        }];
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}


@end
