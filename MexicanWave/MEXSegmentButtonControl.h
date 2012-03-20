//
//  MEXSegmentButtonControl.h
//  MexicanWave
//
//  Created by Tom York on 20/03/2012.
//  Copyright (c) 2012 Yell Group Plc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MEXSegmentButtonControl : UIControl

@property (nonatomic,retain,readonly) UIImageView* backgroundImageView;
@property (nonatomic,retain,readonly) UIImageView* imageView;
@property (nonatomic,retain,readonly) UILabel* titleView;

@property (nonatomic) UIEdgeInsets contentInsets;

@end
