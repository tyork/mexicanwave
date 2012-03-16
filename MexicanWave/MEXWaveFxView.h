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

- (void)configureLampsWithLocations:(NSArray*)locations scaleFactors:(NSArray*)scaleFactors;

- (void)setLampLevelsForLinesFromCenter:(CGPoint)start angles:(NSArray*)lineAnglesInDegrees animated:(BOOL)animated;

- (void)setAllLampLevels:(float)intensity animated:(BOOL)animated;

@end
