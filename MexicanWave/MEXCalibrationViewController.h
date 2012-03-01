//
//  MEXCalibrationViewController.h
//  MexicanWave
//
//  Created by Tom York on 29/02/2012.
//  Copyright (c) 2012 Yell Group Plc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MEXCalibrationModel.h"

@interface MEXCalibrationViewController : UIViewController

@property (nonatomic,retain) MEXCalibrationModel* model;

@property (nonatomic,retain) IBOutlet UILabel* angleIndicatorLabel;

@end
