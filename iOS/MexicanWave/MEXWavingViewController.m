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
#import "MEXLegacyTorchController.h"            // TODO: Remove this once support for iOS 4.x is not a concern.
#import "SettingsViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define kTorchOnTime 0.25f

#define kModelKeyPathForPeriod @"wavePeriodInSeconds"
#define kModelKeyPathForPhase @"wavePhase"
#define kModelKeyPathForPeaks @"numberOfPeaks"

@interface MEXWavingViewController ()
@property (nonatomic,retain) MEXLegacyTorchController* legacyTorchController;
@property (nonatomic) SystemSoundID waveSoundID;

- (void)setTorchMode:(AVCaptureTorchMode)newMode;
@end


@implementation MEXWavingViewController

@synthesize waveView;
@synthesize crowdTypeSelectionControl;
@synthesize waveModel;
@synthesize vibrationOnWaveEnabled, soundOnWaveEnabled;
@synthesize legacyTorchController;
@synthesize waveSoundID;

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

- (IBAction)didTapSettingButton:(id)sender {

    SettingsViewController* settings = [[SettingsViewController alloc]init];
    settings.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    [self presentModalViewController:settings animated:YES];
    [settings release];
    [self pause];
   
}

#pragma mark - Torch handling

- (void)torchOff {
    if(self.legacyTorchController) {
        // iOS 4.x
        [self.legacyTorchController torchOff];
        return;        
    }
    // iOS 5+
    [self setTorchMode:AVCaptureTorchModeOff];
}

- (void)torchOn { 
    if(self.legacyTorchController) {
        // iOS 4.x
        [self.legacyTorchController torchOn];
    }
    else {
        // iOS 5+
        [self setTorchMode:AVCaptureTorchModeOn];
    }
        
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, kTorchOnTime * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self torchOff];
    });
}

- (void)setTorchMode:(AVCaptureTorchMode)newMode {    
    AVCaptureDevice* backCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if([backCamera isTorchAvailable] && [backCamera isTorchModeSupported:newMode] && [backCamera torchMode] != newMode) {
        if([backCamera lockForConfiguration:nil]) {
            [backCamera setTorchMode:newMode];
            [backCamera unlockForConfiguration];
        }
    }
}

#pragma mark - App lifecycle

- (void)pause {
    // Turn off the torch (just in case)
    [self torchOff];
    // Suspend the model
    [self.waveModel pause];
}

- (void)resume {
    // Refetch our settings preferences, they may have changed while we were in the background.
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	self.vibrationOnWaveEnabled = [defaults boolForKey:@"vibration_preference"];    
    self.soundOnWaveEnabled = [defaults boolForKey:@"sound_preference"];
    
    // Start running again
    [self.waveModel resume];
}

#pragma mark - Notifications

// Handles behaviour on wave trigger, i.e. wave has just passed our bearing
- (void)didWave:(NSNotification*)note {
    if(!self.isViewLoaded) {
        return;
    }
    
    // Flash the torch
    [self torchOn];

    // Vibrate
    if(self.isVibrationOnWaveEnabled) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    // Play sound
    if(self.isSoundOnWaveEnabled) {
        AudioServicesPlaySystemSound(self.waveSoundID);
    }
}

#pragma mark - Controller lifecycle

- (void)awakeFromNib {
    if(!self.legacyTorchController && [MEXLegacyTorchController isLegacySystem]) {
        self.legacyTorchController = [[[MEXLegacyTorchController alloc] init] autorelease];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [waveModel pause];
    [waveModel removeObserver:self forKeyPath:kModelKeyPathForPhase];
    [waveModel removeObserver:self forKeyPath:kModelKeyPathForPeriod];
    [waveModel removeObserver:self forKeyPath:kModelKeyPathForPeaks];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MEXWaveModelDidWaveNotification object:nil];
    AudioServicesDisposeSystemSoundID(waveSoundID);
    [waveModel release];
    [waveView release];
    [crowdTypeSelectionControl release];
    [legacyTorchController release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didWave:) name:MEXWaveModelDidWaveNotification object:nil];
    
    // Set crowd type on view from model
    self.crowdTypeSelectionControl.selectedSegment = (MEXCrowdTypeSelectionSegment)self.waveModel.crowdType;
    
    // Load in the wave sound.
    AudioServicesCreateSystemSoundID((CFURLRef)[[NSBundle mainBundle] URLForResource:@"clapping" withExtension:@"caf"], &waveSoundID);
}
 
- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MEXWaveModelDidWaveNotification object:nil];

    [self torchOff];

    AudioServicesDisposeSystemSoundID(waveSoundID);
    self.waveSoundID = 0;

    self.waveView = nil;
    self.crowdTypeSelectionControl = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self torchOff];
    [self pause];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self resume];
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
