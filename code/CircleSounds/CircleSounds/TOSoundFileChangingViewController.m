//
//  TOSoundFileChangingViewController.m
//  CircleSounds
//
//  Created by Tobias Ottenweller on 08.09.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOSoundFileChangingViewController.h"

#import "TOSoundDetailsPopoverViewControllerDelegate.h"
#import "TOEqualizerSound.h"


@interface TOSoundFileChangingViewController ()

@end


@implementation TOSoundFileChangingViewController

- (void)handleAudioFileChangingWithURL:(NSURL *)audioFileURL
{
    NSError *error;
    BOOL success = [self.sound setAudioFileURL:audioFileURL error:&error];
    
    if (!success || error) {
        [[[UIAlertView alloc] initWithTitle:@"There was a problem with the selected sound!"
                                   message:[NSString stringWithFormat:@"Please choose a different sound.\n%@ (%@)", error.userInfo[kTOErrorInfoStringKey], error.userInfo[kTOErrorStatusStringKey]]
                                  delegate:nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil] show];
    }
    else {
        self.sound.regionStart = 0;
        self.sound.regionDuration = self.sound.fileDuration;
        
        [self.delegate soundFileChangingViewControllerDidChangeSoundFile:self];
    }
}

@end
