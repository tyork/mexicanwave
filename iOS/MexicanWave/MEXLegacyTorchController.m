//
//  MEXLegacyTorchController.m
//  MexicanWave
//
//  Created by Tom York on 28/03/2012.
//  Copyright (c) 2012 Yell Group Plc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "MEXLegacyTorchController.h"

@interface MEXLegacyTorchController ()
@property (nonatomic, retain) AVCaptureSession* torchSession;

- (void)setTorchMode:(AVCaptureTorchMode)newMode;
@end


@implementation MEXLegacyTorchController

@synthesize torchSession;

+ (BOOL)isLegacySystem {
    return ![[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] respondsToSelector:@selector(isTorchAvailable)];
}

#pragma mark - Torch control

- (void)torchOn {
    [self setTorchMode:AVCaptureTorchModeOn];
}

- (void)torchOff {
    [self setTorchMode:AVCaptureTorchModeOff];
}

- (void)setTorchMode:(AVCaptureTorchMode)newMode {    
    if(!self.torchSession) {
        return;
    }
    AVCaptureDevice* backCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];    
    if([backCamera isTorchModeSupported:newMode] && [backCamera torchMode] != newMode && [backCamera lockForConfiguration:nil]) {
        [backCamera setTorchMode:newMode];
        [backCamera unlockForConfiguration];
    }
}

#pragma mark - Lifecycle

- (id)init {
    if(!(self = [super init])) {
        return nil;
    }
    
    AVCaptureDevice* backCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if(backCamera.hasTorch) {
        AVCaptureDeviceInput* input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:nil];
        if(input) {
            torchSession = [[AVCaptureSession alloc] init];
            [torchSession beginConfiguration];
            
            [torchSession addInput:input];

            AVCaptureVideoDataOutput* output = [[AVCaptureVideoDataOutput alloc] init];
            [torchSession addOutput:output];
            [output release];            
            
            [torchSession commitConfiguration];
            
            [torchSession startRunning];
        }        
    }
    
    return self;
}

- (void)dealloc {
    [torchSession stopRunning];
    [torchSession release];
    [super dealloc];
}

@end
