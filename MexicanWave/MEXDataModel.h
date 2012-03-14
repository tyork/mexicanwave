//
//  MEXDataModel.h
//  MexicanWave
//
//  Created by Tom York on 29/02/2012.
//  Copyright (c) 2012 Yell Group Plc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
typedef enum {
    kMEXCrowdSizeSmall,
    kMEXCrowdSizeMedium,
    kMEXCrowdSizeLarge
} MEXCrowdSize;
*/

NSString* const MEXDataModelDidWaveNotification;


@interface MEXDataModel : NSObject

@property (nonatomic) NSUInteger crowdSize;
@property (nonatomic) float headingInDegreesEastOfNorth;

@property (nonatomic,readonly) NSTimeInterval wavePeriodInSeconds;

+ (id)sharedDataModel;

@end
