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

- (id)initWithPlugableSound:(TOEqualizerSound *)sound atPosition:(CGRect)viewFrame;


@property (readonly, nonatomic) TOEqualizerSound *sound;
@property (readonly, nonatomic) TOPlugableSoundView *soundView;

@property (weak, nonatomic) TOSoundDocumentViewController *documentController;



@end
