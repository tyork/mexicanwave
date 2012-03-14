//
//  MEXWavingViewController.h
//  MexicanWave
//
//  Created by Tom York on 29/02/2012.
//  Copyright (c) 2012 Yell Group Plc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MEXWaveFxView;
@class MEXWaveModel, MEXCalibrationModel;

@interface MEXWavingViewController : UIViewController

@property (nonatomic,retain) MEXWaveModel* waveModel;
@property (nonatomic,retain) MEXCalibrationModel* calibrationModel;

@property (nonatomic,retain) IBOutlet MEXWaveFxView* waveView;

- (IBAction)didTapSmallAudienceButton:(id)sender;
- (IBAction)didTapGigButton:(id)sender;
- (IBAction)didTapStadiumButton:(id)sender;

- (IBAction)didTapCalibrationButton:(id)sender;

@end
