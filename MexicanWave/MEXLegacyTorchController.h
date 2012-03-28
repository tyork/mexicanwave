//
//  MEXLegacyTorchController.h
//  MexicanWave
//
//  Created by Tom York on 28/03/2012.
//  Copyright (c) 2012 Yell Group Plc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 This is to manage the torch on iOS 4.x. The technique used
 is much less efficient than that available on iOS 5+.
 This should be removed once iOS 4.x support is not a concern.
 */
@interface MEXLegacyTorchController : NSObject {
}

/**
 Returns true if the app should use MEXLegacyTorchController
 to run the torch.
 */
+ (BOOL)isLegacySystem;

- (void)torchOn;
- (void)torchOff;

@end
