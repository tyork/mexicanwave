//
//  MEXWavingViewController.h
//  MexicanWave
//
//  Created by Tom York on 29/02/2012.
//  Copyright (c) 2012 Yell Group Plc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MEXCrowdTypeSelectionControl;
@class MEXWaveFxView;
@class MEXWaveModel;

@interface MEXWavingViewController : UIViewController

@property (nonatomic,retain) MEXWaveModel* waveModel;
@property (nonatomic,getter=isVibrationOnWaveEnabled) BOOL vibrationOnWaveEnabled;
@property (nonatomic,getter=isSoundOnWaveEnabled) BOOL soundOnWaveEnabled;

@property (nonatomic,retain) IBOutlet MEXWaveFxView* waveView;
@property (nonatomic,retain) IBOutlet MEXCrowdTypeSelectionControl* crowdTypeSelectionControl;

- (IBAction)didChangeCrowdType:(id)sender;
- (IBAction)didTapSettingButton:(id)sender;
- (void)pause;
- (void)resume;

@end
