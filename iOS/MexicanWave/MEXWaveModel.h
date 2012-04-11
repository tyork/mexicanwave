//
//  MEXDataModel.h
//  MexicanWave
//
//  Created by Tom York on 29/02/2012.
//  Copyright (c) 2012 Yell Group Plc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kMEXCrowdTypeSmallGroup,
    kMEXCrowdTypeStageBased,
    kMEXCrowdTypeStadium
} MEXCrowdType;

NSString* const MEXWaveModelDidWaveNotification;

@interface MEXWaveModel : NSObject

@property (nonatomic) MEXCrowdType crowdType;
@property (nonatomic,readonly) NSTimeInterval wavePeriodInSeconds;
@property (nonatomic,readonly) NSUInteger numberOfPeaks;
@property (nonatomic,readonly) float wavePhase;

- (void)pause;
- (void)resume;

@end
