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

NSString* const MEXDataModelDidWaveNotification = @"MEXDataModelDidWaveNotification";

@implementation MEXWaveModel

@synthesize crowdType, headingInDegreesEastOfNorth;

#pragma mark - Waving

- (void)didWave {
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:MEXDataModelDidWaveNotification object:self]];
}

- (void)cancelWave {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didWave) object:nil];
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
    const NSTimeInterval timeOffsetDueToAngle = self.headingInDegreesEastOfNorth / 360.0 * self.wavePeriodInSeconds;
    const NSTimeInterval timeToNextWave = timeOffsetDueToAngle + self.wavePeriodInSeconds - fmod([now timeIntervalSinceReferenceDate], self.wavePeriodInSeconds);        
    [self performSelector:@selector(didWave) withObject:nil afterDelay:timeToNextWave];
}

- (NSTimeInterval)wavePeriodInSeconds {
    float crowdSizeFactor = 1.0f;
    switch (self.crowdType) {
        case kMEXCrowdTypeSmallGroup:
            crowdSizeFactor = 0.1;
            break;
            
        case kMEXCrowdTypeStageBased:
            crowdSizeFactor = 0.5;
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
     
- (void)setCrowdSize:(MEXCrowdType)newType {
    if(crowdType != newType) {
        crowdType = newType;
        [self scheduleWave];
    }
}

- (void)setHeadingInDegreesEastOfNorth:(float)newAngle {
    if(headingInDegreesEastOfNorth != newAngle) {
        headingInDegreesEastOfNorth = newAngle;
        [self scheduleWave];
    }
}

#pragma mark - Lifecycle

+ (id)sharedDataModel {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init {
    if(!(self = [super init])) {
        return nil;
    }
    crowdType = kMEXCrowdTypeStadium;
    
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
