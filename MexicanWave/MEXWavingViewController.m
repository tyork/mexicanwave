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


#define SIGN(x) ((x) < 0.0f ? -1.0f : 1.0f)

@implementation MEXWavingViewController

@synthesize waveView;
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

- (IBAction)didTapSmallAudienceButton:(id)sender {
    self.waveModel.crowdType = kMEXCrowdTypeSmallGroup;
}

- (IBAction)didTapGigButton:(id)sender {
    self.waveModel.crowdType = kMEXCrowdTypeStageBased;    
}

- (IBAction)didTapStadiumButton:(id)sender {
    self.waveModel.crowdType = kMEXCrowdTypeStadium;
}

- (IBAction)didTapCalibrationButton:(id)sender {
    [self.calibrationModel startCalibratingWithErrorPercentage:0 timeout:4.0 completionBlock:^(float deviceHeading, NSError* error) {
        self.waveModel.deviceHeadingInDegreesEastOfNorth = [self.calibrationModel headingInDegreesEastOfNorth];
    }];
}

#pragma mark - Wave trigger

- (void)didWave:(NSNotification*)note {
    // TODO:
}

#pragma mark - Lifecycle

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MEXWaveModelDidWaveNotification object:nil];
    [waveModel release];
    [calibrationModel release];
    [waveView release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.waveView setAllLampIntensities:1.0f animated:animated];
    });
}

- (CGPoint)positionOnProjectedCircleForAngle:(float)angle center:(CGPoint)center {
    const float y = 132.0f*2.0f*(fabsf(angle) - 0.5f);
    return CGPointMake(center.x + SIGN(angle)*sqrtf(132.0f*132.0f - y*y), center.y - y);
}

- (CGFloat)scaleFactorOnProjectedCircleForAngle:(float)fractionalAngle {
    return (76.0f/128.0f) * (1.0f - fabsf(fractionalAngle)*0.86);    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didWave:) name:MEXWaveModelDidWaveNotification object:nil];
    
    
    NSArray* angles = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:0.24f],[NSNumber numberWithFloat:0.48f],[NSNumber numberWithFloat:0.68f],[NSNumber numberWithFloat:0.815f],[NSNumber numberWithFloat:0.896f],[NSNumber numberWithFloat:0.945f],[NSNumber numberWithFloat:0.98f],[NSNumber numberWithFloat:0.995f],[NSNumber numberWithFloat:1.0f],[NSNumber numberWithFloat:-0.24f],[NSNumber numberWithFloat:-0.48f],[NSNumber numberWithFloat:-0.68f],[NSNumber numberWithFloat:-0.815f],[NSNumber numberWithFloat:-0.896f],[NSNumber numberWithFloat:-0.945f],[NSNumber numberWithFloat:-0.98f],[NSNumber numberWithFloat:-0.995f],nil];

    
    
    NSMutableArray* locations = [[NSMutableArray alloc] initWithCapacity:angles.count]; 
    NSMutableArray* scaleFactors = [[NSMutableArray alloc] initWithCapacity:angles.count]; 

    for(NSUInteger angleIndex = 0; angleIndex < angles.count; angleIndex++) {
        const float angle = [[angles objectAtIndex:angleIndex] floatValue];
        [locations addObject:[NSValue valueWithCGPoint:[self positionOnProjectedCircleForAngle:angle center:CGPointMake(158.0f, 155.0f)]]];
        [scaleFactors addObject:[NSNumber numberWithFloat:[self scaleFactorOnProjectedCircleForAngle:angle]]];
    }
    
    
    [self.waveView configureLampsWithLocations:locations scaleFactors:scaleFactors];    
    [self.waveView setAllLampIntensities:0 animated:NO];
    
    // Set crowd type on view from model
    self.waveModel.crowdType; // TODO:
}
 
- (void)viewDidUnload {
    [super viewDidUnload];
    self.waveView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MEXWaveModelDidWaveNotification object:nil];
}

#pragma mark - Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

@end
