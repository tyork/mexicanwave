//
//  MEXCalibrationModel.h
//  MexicanWave
//
//  Created by Tom York on 01/03/2012.
//  Copyright (c) 2012 Yell Group Plc. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>


typedef void(^MEXCalibrationCompletionBlock)(float calibratedheadingInDegrees, NSError* error);


@interface MEXCalibrationModel : NSObject <CLLocationManagerDelegate>

@property (nonatomic,readonly) float headingInDegreesEastOfNorth;       // KVO this to get dynamic updates

// Right now we don't allow clients to specify an error limit, just a timeout
- (void)startCalibratingWithErrorPercentage:(float)errorPercentage timeout:(NSTimeInterval)maxTimeToAcquireResult completionBlock:(MEXCalibrationCompletionBlock)completionBlock;
- (void)cancelCalibration;
@end
