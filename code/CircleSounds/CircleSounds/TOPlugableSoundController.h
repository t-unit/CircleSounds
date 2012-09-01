//
//  TOPlugableSoundViewController.h
//  CircleSounds
//
//  Created by Tobias Ottenweller on 29.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TOPlugableSoundView;
@class TOEqualizerSound;
@class TOSoundDocumentViewController;


@interface TOPlugableSoundController : NSObject

/**
 The designated initializer for the sound controller. It will overwrite the 'startTime'
 property of 'sound'. Other properties won't be changed during initialization.
 */
- (id)initWithPlugableSound:(TOEqualizerSound *)sound atPosition:(CGRect)viewFrame documentController:(TOSoundDocumentViewController *)documentController;


@property (readonly, nonatomic) TOEqualizerSound *sound;
@property (readonly, nonatomic) TOPlugableSoundView *soundView;
@property (readonly, nonatomic) TOSoundDocumentViewController *documentController;



@end