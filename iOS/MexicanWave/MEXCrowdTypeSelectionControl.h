//
//  MEXCrowdTypeSelectionControl.h
//  MexicanWave
//
//  Created by Tom York on 15/03/2012.
//  Copyright (c) 2012 Yell Group Plc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MEXCrowdTypeSelectionSegmentLeft,
    MEXCrowdTypeSelectionSegmentMiddle,
    MEXCrowdTypeSelectionSegmentRight
} MEXCrowdTypeSelectionSegment;


@interface MEXCrowdTypeSelectionControl : UIControl

@property (nonatomic) MEXCrowdTypeSelectionSegment selectedSegment;

- (void)setSelectedSegment:(MEXCrowdTypeSelectionSegment)newSegment animated:(BOOL)animated;

@end
