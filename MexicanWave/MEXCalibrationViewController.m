//
//  MEXCalibrationViewController.m
//  MexicanWave
//
//  Created by Tom York on 29/02/2012.
//  Copyright (c) 2012 Yell Group Plc. All rights reserved.
//

#import "MEXCalibrationViewController.h"
#import "MEXWavingViewController.h"
#import "MEXWaveModel.h"

#define kModelAngleKeyPath @"headingInDegreesEastOfNorth"

@implementation MEXCalibrationViewController

@synthesize model;
@synthesize angleIndicatorLabel;

#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if(!(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        return nil;
    }
    model = [[MEXCalibrationModel alloc] init];    
    [model addObserver:self forKeyPath:kModelAngleKeyPath options:NSKeyValueObservingOptionNew context:NULL];
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [angleIndicatorLabel release];
    [model removeObserver:self forKeyPath:kModelAngleKeyPath];
    [model release];
    [super dealloc];
}

#pragma mark - Model KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if(!self.isViewLoaded) {
        return;
    }
    
    if(object == self.model) {
        if([keyPath isEqualToString:kModelAngleKeyPath]) {
             self.angleIndicatorLabel.text = [NSString stringWithFormat:@"%.0f", self.model.headingInDegreesEastOfNorth];
        }
    }
}

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.model startCalibratingWithErrorPercentage:0 timeout:4.0 completionBlock:^{
        [[MEXWaveModel sharedDataModel] setHeadingInDegreesEastOfNorth:self.model.headingInDegreesEastOfNorth];

        MEXWavingViewController* wavingVC = [[[MEXWavingViewController alloc] initWithNibName:nil bundle:nil] autorelease];
        [self.navigationController pushViewController:wavingVC animated:YES];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.model cancelCalibration];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.angleIndicatorLabel.text = @"Locking on...";
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.angleIndicatorLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
