//
//  MEXCalibrationModel.m
//  MexicanWave
//
//  Created by Tom York on 01/03/2012.
//  Copyright (c) 2012 Yell Group Plc. All rights reserved.
//

#import "MEXCompassModel.h"

#define kMinimumHeadingDelta 10.0f

@interface MEXCompassModel ()
@property (nonatomic,retain) CLLocationManager* locationManager;
@property (nonatomic,readwrite) float headingInDegreesEastOfNorth;
@end

@implementation MEXCompassModel

@synthesize headingInDegreesEastOfNorth;
@synthesize locationManager;

- (void)startCompass {
    [self.locationManager startUpdatingHeading];    
}

- (void)stopCompass {
    [self.locationManager stopUpdatingHeading];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    const float latestHeadingAngle = [newHeading magneticHeading];
    if(fabsf(latestHeadingAngle - self.headingInDegreesEastOfNorth) > kMinimumHeadingDelta) {
        self.headingInDegreesEastOfNorth = latestHeadingAngle;
    }
}

#pragma mark - Lifecycle

- (id)init {
    if(!(self = [super init])) {
        return nil;
    }
    
    if(!([CLLocationManager headingAvailable])) {
        [self release], self = nil;
        return nil;
    }
        
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    return self;
}

- (void)dealloc {
    [locationManager stopUpdatingHeading];
    [locationManager release];
    [super dealloc];
}

@end
