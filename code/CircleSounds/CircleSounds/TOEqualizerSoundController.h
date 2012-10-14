//
//  TOEqualizerSoundController.h
//  CircleSounds
//
//  Created by Tobias Ottenweller on 29.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TOPlugableSoundView;
@class TOEqualizerSound;
@class TOSoundDocumentViewController;


@interface TOEqualizerSoundController : NSObject
{
    __weak TOSoundDocumentViewController *_documentController;
}

/**
 The designated initializer for the sound controller. It will overwrite the 'startTime'
 property of 'sound'. Other properties won't be changed during initialization.
 Won't retain documentController.
 */
- (id)initWithPlugableSound:(TOEqualizerSound *)sound atPosition:(CGRect)viewFrame documentController:(TOSoundDocumentViewController *)documentController;


- (void)displayDetailsPopover;
- (void)displayAudioFileChooserPopover;


@property (readonly, nonatomic) TOEqualizerSound *sound;
@property (readonly, nonatomic) TOPlugableSoundView *soundView;
@property (readonly, nonatomic) TOSoundDocumentViewController *documentController;

@end
