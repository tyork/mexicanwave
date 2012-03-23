//
//  MEXWavingViewController.m
//  MexicanWave
//
//  Created by Tom York on 29/02/2012.
//  Copyright (c) 2012 Yell Group Plc. All rights reserved.
//

#import "MEXWavingViewController.h"
#import "MEXWaveModel.h"
#import "MEXWaveFxView.h"
#import "MEXCrowdTypeSelectionControl.h"

#import <AVFoundation/AVFoundation.h>

#define kTorchOnTime 0.25f

#define kModelKeyPathForPeriod @"wavePeriodInSeconds"
#define kModelKeyPathForPhase @"wavePhase"
#define kModelKeyPathForPeaks @"numberOfPeaks"

@implementation MEXWavingViewController

@synthesize waveView;
@synthesize crowdTypeSelectionControl;
@synthesize waveModel;

- (MEXWaveModel*)waveModel {
    if(!waveModel) {
        waveModel = [[MEXWaveModel alloc] init];
        [waveModel addObserver:self forKeyPath:kModelKeyPathForPhase options:NSKeyValueObservingOptionNew context:NULL];
        [waveModel addObserver:self forKeyPath:kModelKeyPathForPeriod options:NSKeyValueObservingOptionNew context:NULL];
        [waveModel addObserver:self forKeyPath:kModelKeyPathForPeaks options:NSKeyValueObservingOptionNew context:NULL];
    }
    return waveModel;
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
    if(![backCamera respondsToSelector:@selector(isTorchAvailable)]) {
        // TODO: iOS 4.x
        return;
    }

    if([backCamera isTorchAvailable] && [backCamera torchMode] != AVCaptureTorchModeOff) {
        if([backCamera lockForConfiguration:nil]) {
            [backCamera setTorchMode:AVCaptureTorchModeOff];
            [backCamera unlockForConfiguration];
        }
    }
}

- (void)torchOn {    
    AVCaptureDevice* backCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if(![backCamera respondsToSelector:@selector(isTorchAvailable)]) {
        // TODO: iOS 4.x
        return;
    }
    
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
    
    // Flash the torch
    [self torchOn];
}

#pragma mark - Controller lifecycle

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MEXWaveModelDidWaveNotification object:nil];
    [waveModel removeObserver:self forKeyPath:kModelKeyPathForPhase];
    [waveModel removeObserver:self forKeyPath:kModelKeyPathForPeriod];
    [waveModel removeObserver:self forKeyPath:kModelKeyPathForPeaks];
    [waveModel release];
    [waveView release];
    [crowdTypeSelectionControl release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didWave:) name:MEXWaveModelDidWaveNotification object:nil];
    
    // Set crowd type on view from model
    self.crowdTypeSelectionControl.selectedSegment = (MEXCrowdTypeSelectionSegment)self.waveModel.crowdType;
}
 
- (void)viewDidUnload {
    [super viewDidUnload];
    [self torchOff];
    self.waveView = nil;
    self.crowdTypeSelectionControl = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MEXWaveModelDidWaveNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // TODO: start waving
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self torchOff];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if(object != self.waveModel) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    // A wave period change or angle change means we need to update the display.
    [self.waveView animateWithDuration:self.waveModel.wavePeriodInSeconds startingPhase:self.waveModel.wavePhase numberOfPeaks:self.waveModel.numberOfPeaks];
}

#pragma mark - Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

@end
