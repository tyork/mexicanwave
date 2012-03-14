//
//  MEXWavingViewController.m
//  MexicanWave
//
//  Created by Tom York on 29/02/2012.
//  Copyright (c) 2012 Yell Group Plc. All rights reserved.
//

#import "MEXWavingViewController.h"
#import "MEXDataModel.h"

@implementation MEXWavingViewController

- (IBAction)didTapSmallAudienceButton:(id)sender {
    
}

- (IBAction)didTapGigButton:(id)sender {
    
}

- (IBAction)didTapStadiumButton:(id)sender {
    
}

#pragma mark - Wave trigger

- (void)didWave:(NSNotification*)note {
    
}

#pragma mark - Lifecycle

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MEXDataModelDidWaveNotification object:nil];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didWave:) name:MEXDataModelDidWaveNotification object:nil];
}
 
- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MEXDataModelDidWaveNotification object:nil];
}

#pragma mark - Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

@end
