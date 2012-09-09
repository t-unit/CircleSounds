//
//  TOSoundFileChangingViewControllerDelegate.h
//  CircleSounds
//
//  Created by Tobias Ottenweller on 09.09.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TOSoundFileChangingViewController;


@protocol TOSoundFileChangingViewControllerDelegate <NSObject>

- (void)soundFileChangingViewControllerDidChangeSoundFile:(TOSoundFileChangingViewController *)sender;

@end
