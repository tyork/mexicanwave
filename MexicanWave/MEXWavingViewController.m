//
//  MEXWavingViewController.m
//  MexicanWave
//
//  Created by Tom York on 29/02/2012.
//  Copyright (c) 2012 Yell Group Plc. All rights reserved.
//

#import "MEXWavingViewController.h"
#import "MEXWaveModel.h"
#import "MEXCalibrationModel.h"
#import "MEXWaveFxView.h"
#import "MEXCrowdTypeSelectionControl.h"

#import <AVFoundation/AVFoundation.h>

#define kTorchOnTime 0.25f

@implementation MEXWavingViewController

@synthesize waveView;
@synthesize crowdTypeSelectionControl;
@synthesize waveModel, calibrationModel;

- (MEXWaveModel*)waveModel {
    if(!waveModel) {
        waveModel = [[MEXWaveModel alloc] init];
    }
    return waveModel;
}

- (MEXCalibrationModel*)calibrationModel {
    if(!calibrationModel) {
        calibrationModel = [[MEXCalibrationModel alloc] init];
    }
    return calibrationModel;
}

#pragma mark - UI actions

- (IBAction)didChangeCrowdType:(id)sender {
    switch ([(MEXCrowdTypeSelectionControl*)sender selectedSegment]) {
        case MEXCrowdTypeSelectionSegmentLeft:
            self.waveModel.crowdType = kMEXCrowdTypeSmallGroup;
            break;
            
        case MEXCrowdTypeSelectionSegmentMiddle:
            self.waveModel.crowdType = kMEXCrowdTypeStageBased;    
            break;

        case MEXCrowdTypeSelectionSegmentRight:
            self.waveModel.crowdType = kMEXCrowdTypeStadium;
            break;
        default:
            break;
    }
}

#pragma mark - Torch handling

- (void)torchOff {
    AVCaptureDevice* backCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if([backCamera isTorchAvailable] && [backCamera torchMode] != AVCaptureTorchModeOff) {
        if([backCamera lockForConfiguration:nil]) {
            [backCamera setTorchMode:AVCaptureTorchModeOff];
            [backCamera unlockForConfiguration];
        }
    }
}

- (void)torchOn {
    AVCaptureDevice* backCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if([backCamera isTorchAvailable] && [backCamera isTorchModeSupported:AVCaptureTorchModeOn]) {
        if([backCamera lockForConfiguration:nil]) {
            [backCamera setTorchMode:AVCaptureTorchModeOn];
            [backCamera unlockForConfiguration];
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, kTorchOnTime * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self torchOff];
            });
        }
    }
}

#pragma mark - Notifications

// Handles behaviour on wave trigger, i.e. wave has just passed our bearing
- (void)didWave:(NSNotification*)note {
    if(!self.isViewLoaded) {
        return;
    }
    // Update the view
    [self.waveView animateWithDuration:self.waveModel.wavePeriodInSeconds referenceAngle:0 numberOfPeaks:self.waveModel.numberOfPeaks];
    
    if(note.object) {        
        // Flash the torch
        [self torchOn];
    }
}

#pragma mark - Controller lifecycle

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MEXWaveModelDidWaveNotification object:nil];
    [calibrationModel removeObserver:self forKeyPath:MEXWaveModelDidWaveNotification];
    [calibrationModel release];
    [waveModel release];
    [waveView release];
    [crowdTypeSelectionControl release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didWave:) name:MEXWaveModelDidWaveNotification object:nil];
    [self.calibrationModel addObserver:self forKeyPath:@"headingInDegreesEastOfNorth" options:NSKeyValueObservingOptionNew context:NULL];
    
    // Set crowd type on view from model
    self.crowdTypeSelectionControl.selectedSegment = (MEXCrowdTypeSelectionSegment)self.waveModel.crowdType;
}
 
- (void)viewDidUnload {
    [super viewDidUnload];
    self.waveView = nil;
    self.crowdTypeSelectionControl = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MEXWaveModelDidWaveNotification object:nil];
    [self.calibrationModel stopCalibrating];
    [self torchOff];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.calibrationModel startCalibrating];  
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.calibrationModel stopCalibrating];
    [self torchOff];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    self.waveModel.deviceHeadingInDegreesEastOfNorth = self.calibrationModel.headingInDegreesEastOfNorth;
}

#pragma mark - Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

@end
