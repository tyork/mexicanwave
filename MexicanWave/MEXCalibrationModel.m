//
//  MEXCalibrationModel.m
//  MexicanWave
//
//  Created by Tom York on 01/03/2012.
//  Copyright (c) 2012 Yell Group Plc. All rights reserved.
//

#import "MEXCalibrationModel.h"



#define DEFAULT_MAX_ERROR 0.75f

@interface MEXCalibrationModel ()
@property (nonatomic,copy) MEXCalibrationCompletionBlock completionBlock;
@property (nonatomic,retain) CLLocationManager* locationManager;
@property (nonatomic,readwrite) float headingInDegreesEastOfNorth;
@end

@implementation MEXCalibrationModel

@synthesize headingInDegreesEastOfNorth;
@synthesize completionBlock, locationManager;

- (void)didAcquireHeading {
    if(self.completionBlock) {
        completionBlock(self.headingInDegreesEastOfNorth, nil);
        self.completionBlock = nil;
    }
    [self.locationManager stopUpdatingHeading];
}

- (void)cancelTimeout {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didAcquireHeading) object:nil];  
}

- (void)startCalibratingWithErrorPercentage:(float)errorPercentage timeout:(NSTimeInterval)maxTimeToAcquireResult completionBlock:(MEXCalibrationCompletionBlock)aCompletionBlock {
    if(self.completionBlock) {
        [self cancelTimeout];
        self.completionBlock = nil;
    }
    
    self.completionBlock = aCompletionBlock;    
    [self.locationManager startUpdatingHeading];
    
    [self performSelector:@selector(didAcquireHeading) withObject:nil afterDelay:(maxTimeToAcquireResult > 0) ? maxTimeToAcquireResult : 4.0];
}

- (void)cancelCalibration {
    [self cancelTimeout];
    self.completionBlock = nil;
    [self.locationManager stopUpdatingHeading];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    self.headingInDegreesEastOfNorth = [newHeading magneticHeading];
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
    [locationManager release];
    [super dealloc];
}

@end
