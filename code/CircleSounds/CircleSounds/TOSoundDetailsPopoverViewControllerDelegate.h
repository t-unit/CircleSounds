//
//  TOSoundDetailsPopoverViewControllerDelegate.h
//  CircleSounds
//
//  Created by Tobias Ottenweller on 03.09.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TOSoundDetailsPopoverViewController;
@class TOEqualizerSound;

@protocol TOSoundDetailsPopoverViewControllerDelegate <NSObject>

- (void)detailsController:(TOSoundDetailsPopoverViewController *)detailsController soundShouldBeRemovedFromDocument:(TOEqualizerSound *)sound;
- (void)detailsControllerChangeSoundFileButtonPressed:(TOSoundDetailsPopoverViewController *)detailsController;

@end
