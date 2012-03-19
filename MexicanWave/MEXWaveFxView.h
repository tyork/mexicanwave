//
//  MEXWaveFxView.h
//  MexicanWave
//
//  Created by Tom York on 14/03/2012.
//  Copyright (c) 2012 Yell Group Plc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MEXWaveFxView : UIView

@property (nonatomic,retain,readonly) NSArray* lampViews;

- (void)animateWithDuration:(NSTimeInterval)duration referenceAngle:(float)referenceAngle numberOfPeaks:(NSUInteger)peaksPerCycle;

@end
