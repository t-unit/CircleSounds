//
//  TOMocEqualizerSound.m
//  CircleSounds
//
//  Created by Tobias Ottenweller on 27.10.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOMocEqualizerSound.h"

@implementation TOMocEqualizerSound

- (TOAudioUnit *)equalizerUnit
{
    return _equalizerUnit;
}


- (void)setEqualizerUnit:(TOAudioUnit *)equalizerUnit
{
    _equalizerUnit = equalizerUnit;
}

@end
