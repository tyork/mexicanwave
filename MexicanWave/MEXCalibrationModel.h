//
//  MEXCalibrationModel.h
//  MexicanWave
//
//  Created by Tom York on 01/03/2012.
//  Copyright (c) 2012 Yell Group Plc. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

// Right now we don't allow clients to specify an error limit

@interface MEXCalibrationModel : NSObject <CLLocationManagerDelegate>

@property (nonatomic,readonly) float headingInDegreesEastOfNorth;       // KVO this to get dynamic updates

- (void)startCalibratingWithErrorPercentage:(float)errorPercentage timeout:(NSTimeInterval)maxTimeToAcquireResult completionBlock:(void(^)())completionBlock;
- (void)cancelCalibration;
@end
