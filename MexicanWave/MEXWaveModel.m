//
//  MEXDataModel.m
//  MexicanWave
//
//  Created by Tom York on 29/02/2012.
//  Copyright (c) 2012 Yell Group Plc. All rights reserved.
//

#import "MEXWaveModel.h"
#import "MEXCompassModel.h"

#define MIN_WAVE_PERIOD 0.5
#define MAX_WAVE_PERIOD 10.0

NSString* const MEXWaveModelDidWaveNotification = @"MEXWaveModelDidWaveNotification";

@interface MEXWaveModel ()
@property (nonatomic,retain) MEXCompassModel* compassModel;


- (void)waveDidPassOurBearing;
- (void)cancelWave;
- (void)scheduleWave;
@end

@implementation MEXWaveModel

@synthesize crowdType;
@synthesize compassModel;

+ (NSSet*)keyPathsForValuesAffectingNumberOfPeaks {
    return [NSSet setWithObject:@"crowdType"];
}

+ (NSSet*)keyPathsForValuesAffectingWavePeriodInSeconds {
    return [NSSet setWithObject:@"crowdType"];
}

+ (NSSet*)keyPathsForValuesAffectingWavePhase {
    return [NSSet setWithObjects:@"compassModel.headingInDegreesEastOfNorth",@"crowdType",nil];
}

- (NSUInteger)numberOfPeaks {
    return (self.crowdType == kMEXCrowdTypeStageBased) ? 2 : 1;
}

- (NSTimeInterval)wavePeriodInSeconds {
    float crowdSizeFactor = 1.0f;
    switch (self.crowdType) {
        case kMEXCrowdTypeSmallGroup:
            crowdSizeFactor = 0.1;
            break;
            
        case kMEXCrowdTypeStageBased:
            crowdSizeFactor = 0.3;
            break;
            
        case kMEXCrowdTypeStadium:
            crowdSizeFactor = 1.0;
            break;
            
        default:
            NSAssert(NO, @"Unhandled crowd size enum value %d", self.crowdType);
            break;
    }
    return MIN_WAVE_PERIOD + (MAX_WAVE_PERIOD - MIN_WAVE_PERIOD) * crowdSizeFactor;
}

- (float)wavePhase {
    if(self.wavePeriodInSeconds <= 0.0f) {
        return 0.0f;
    }
    
    return ((float)fmod([[NSDate date] timeIntervalSinceReferenceDate] - (self.compassModel.headingInDegreesEastOfNorth / 360.0)*self.wavePeriodInSeconds, self.wavePeriodInSeconds))/self.wavePeriodInSeconds;
}

- (void)setCrowdType:(MEXCrowdType)newValue {
    if(crowdType != newValue) {
        [self willChangeValueForKey:@"crowdType"];
        crowdType = newValue;
        [self didChangeValueForKey:@"crowdType"];
        [self scheduleWave];
    }
}

#pragma mark - Waving

- (void)waveDidPassOurBearing {
    [self scheduleWave];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:MEXWaveModelDidWaveNotification object:[NSNumber numberWithBool:YES]]];
}

- (void)cancelWave {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(waveDidPassOurBearing) object:nil];
}

- (void)scheduleWave {
    // In case we're called multiple times.
    [self cancelWave];

    if(self.wavePeriodInSeconds <= 0.0) {
        return;
    }
    
    // Check our activity status
    if([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        return;
    }
    const float timeToNextWave = self.wavePeriodInSeconds * (1.0f - self.wavePhase);
    [self performSelector:@selector(waveDidPassOurBearing) withObject:nil afterDelay:timeToNextWave];
}

- (void)didChangeActivityState {
    if([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        [self.compassModel stopCompass];
    }
    else {
        [self.compassModel startCompass];
        [self scheduleWave];
    }
}
     
#pragma mark - Lifecycle

- (id)init {
    if(!(self = [super init])) {
        return nil;
    }
    crowdType = kMEXCrowdTypeStageBased;
    compassModel = [[MEXCompassModel alloc] init];
        
    NSNotificationCenter* noteCenter = [NSNotificationCenter defaultCenter];
    [noteCenter addObserver:self selector:@selector(scheduleWave) name:UIApplicationSignificantTimeChangeNotification object:nil];
    [noteCenter addObserver:self selector:@selector(didChangeActivityState) name:UIApplicationDidBecomeActiveNotification object:nil];
    [noteCenter addObserver:self selector:@selector(didChangeActivityState) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [self scheduleWave];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self cancelWave];
    [compassModel release];
    [super dealloc];
}

@end
