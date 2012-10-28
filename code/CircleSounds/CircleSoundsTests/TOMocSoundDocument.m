//
//  TOMocSoundDocument.m
//  CircleSounds
//
//  Created by Tobias Ottenweller on 28.10.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOMocSoundDocument.h"

@implementation TOMocSoundDocument

- (TOAudioUnit *)mixerUnit
{
    return _mixerUnit;
}


- (void)setMixerUnit:(TOAudioUnit *)mixerUnit
{
    _mixerUnit = mixerUnit;
}


- (TOAudioUnit *)rioUnit
{
    return _rioUnit;
}


- (void)setRioUnit:(TOAudioUnit *)rioUnit
{
    _rioUnit = rioUnit;
}


- (AUGraph)graph
{
    return _graph;
}


- (void)setGraph:(AUGraph)graph
{
    _graph = graph;
}


- (NSTimeInterval)prePausePlaybackPosition
{
    return _prePausePlaybackPosition;
}


- (void)setPrePausePlaybackPosition:(NSTimeInterval)prePausePlaybackPosition
{
    _prePausePlaybackPosition = prePausePlaybackPosition;
}


- (Float64)startSampleTime
{
    return _startSampleTime;
}


- (void)setStartSampleTime:(Float64)startSampleTime
{
    _startSampleTime = startSampleTime;
}


- (UInt32)maxBusTaken
{
    return _maxBusTaken;
}


- (void)setMaxBusTaken:(UInt32)maxBusTaken
{
    _maxBusTaken = maxBusTaken;
}

@end
