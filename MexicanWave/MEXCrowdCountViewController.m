//
//  MEXViewController.m
//  MexicanWave
//
//  Created by Tom York on 29/02/2012.
//  Copyright (c) 2012 Yell Group Plc. All rights reserved.
//

#import "MEXCrowdCountViewController.h"
#import "MEXCalibrationViewController.h"
#import "MEXDataModel.h"

@implementation MEXCrowdCountViewController

#pragma mark - Actions

- (IBAction)didAdjustCrowdSize:(id)sender {
    if(![sender isKindOfClass:[UISlider class]]) {
        return;
    }
         
    [[MEXDataModel sharedDataModel] setCrowdSize:(NSUInteger)roundf([(UISlider*)sender value])];
}

- (IBAction)didChooseCrowdSize:(id)sender {
    MEXCalibrationViewController* calibrationVC = [[[MEXCalibrationViewController alloc] initWithNibName:nil bundle:nil] autorelease];    
    [self.navigationController pushViewController:calibrationVC animated:YES];
}


#pragma mark - Lifecycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if(!(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        return nil;
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
