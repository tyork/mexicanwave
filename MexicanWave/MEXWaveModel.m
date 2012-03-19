//
//  MEXDataModel.m
//  MexicanWave
//
//  Created by Tom York on 29/02/2012.
//  Copyright (c) 2012 Yell Group Plc. All rights reserved.
//

#import "MEXWaveModel.h"

#define MIN_WAVE_PERIOD 0.5
#define MAX_WAVE_PERIOD 10.0

NSString* const MEXWaveModelDidWaveNotification = @"MEXWaveModelDidWaveNotification";

@interface MEXWaveModel ()
- (void)waveDidPassOurBearing;
- (void)resetWave;
- (void)cancelWave;
- (void)scheduleWave;
@end

@implementation MEXWaveModel

@synthesize crowdType, deviceHeadingInDegreesEastOfNorth;

- (void)setCrowdType:(MEXCrowdType)newValue {
    if(crowdType != newValue) {
        crowdType = newValue;
        [self resetWave];
    }
}

- (void)setDeviceHeadingInDegreesEastOfNorth:(float)newHeading {
    if(deviceHeadingInDegreesEastOfNorth != newHeading) {
        deviceHeadingInDegreesEastOfNorth = newHeading;
        [self resetWave];
    }
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

#pragma mark - Waving

- (void)resetWave {
    [self scheduleWave];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:MEXWaveModelDidWaveNotification object:nil]];    
}

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

    NSDate* now = [NSDate date];
    const NSTimeInterval timeOffsetDueToAngle = self.deviceHeadingInDegreesEastOfNorth / 360.0 * self.wavePeriodInSeconds;
    const NSTimeInterval timeToNextWave = timeOffsetDueToAngle + self.wavePeriodInSeconds - fmod([now timeIntervalSinceReferenceDate], self.wavePeriodInSeconds);        
    [self performSelector:@selector(waveDidPassOurBearing) withObject:nil afterDelay:timeToNextWave];
}
     
#pragma mark - Lifecycle

- (id)init {
    if(!(self = [super init])) {
        return nil;
    }
    crowdType = kMEXCrowdTypeStageBased;
    
    NSNotificationCenter* noteCenter = [NSNotificationCenter defaultCenter];
    [noteCenter addObserver:self selector:@selector(scheduleWave) name:UIApplicationSignificantTimeChangeNotification object:nil];
    [noteCenter addObserver:self selector:@selector(scheduleWave) name:UIApplicationDidBecomeActiveNotification object:nil];
    [noteCenter addObserver:self selector:@selector(scheduleWave) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [self scheduleWave];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self cancelWave];
    [super dealloc];
}

@end
