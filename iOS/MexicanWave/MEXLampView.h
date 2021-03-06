//
//  MEXLampView.h
//  MexicanWave
//
//  Created by Tom York on 14/03/2012.
//  Copyright (c) 2012 Yell Group Plc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MEXLampView : UIView


@property (nonatomic) float bulbScale;

- (void)animateGlowWithCycleTime:(NSTimeInterval)cycleTime activeTime:(NSTimeInterval)activeTime phase:(float)phase;
- (void)cancelGlowAnimation;

@end
