//
//  TOSoundFileChangingViewController.h
//  CircleSounds
//
//  Created by Tobias Ottenweller on 08.09.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TOSoundFileChangingViewControllerDelegate.h"

@class TOEqualizerSound;


/**
 Acts as a wrapper view controller around the recording and
 file choosing view controller.
 */
@interface TOSoundFileChangingViewController : UIViewController

@property (strong, nonatomic) TOEqualizerSound *sound;
@property (weak, nonatomic) id<TOSoundFileChangingViewControllerDelegate> delegate;


/**
 Should only be called by child view controllers of this controller.
 Exhanges the audio file of the 'sound' property and informs the delegate.
 */
- (void)handleAudioFileChangingWithURL:(NSURL *)audioFileURL;

@end
