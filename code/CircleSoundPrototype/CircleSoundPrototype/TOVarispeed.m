//
//  TOVarispeed.m
//  VarispeedTest
//
//  Created by Tobias Ottenweller on 20.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOVarispeed.h"


@implementation TOVarispeed

- (id)init
{
    self = [super init];
    
    if (self) {
        _varispeedUnit = [[TOAudioUnit alloc] init];
        _varispeedUnit->description = TOAudioComponentDescription(kAudioUnitType_FormatConverter, kAudioUnitSubType_Varispeed);
        
        _audioUnits = [_audioUnits arrayByAddingObject:_varispeedUnit];
    }
    
    return self;
}


#pragma mark - Varispeed Unit Parameter Wrapper Methods

- (AudioUnitParameterValue)playbackCents
{
    AudioUnitParameterValue playbackCents;
    TOThrowOnError(AudioUnitGetParameter(_varispeedUnit->unit,
                                         kVarispeedParam_PlaybackCents,
                                         kAudioUnitScope_Global,
                                         0,
                                         &playbackCents));
    
    return playbackCents;
}


- (void)setPlaybackCents:(AudioUnitParameterValue)playbackCents
{
    TOThrowOnError(AudioUnitSetParameter(_varispeedUnit->unit,
                                         kVarispeedParam_PlaybackCents,
                                         kAudioUnitScope_Global,
                                         0,
                                         playbackCents,
                                         0));
    
    self.startTime = self.startTime; /* this will call the setter which will set the correct start time */
}



- (AudioUnitParameterValue)playbackRate
{
    AudioUnitParameterValue playbackRate;
    TOThrowOnError(AudioUnitGetParameter(_varispeedUnit->unit,
                                         kVarispeedParam_PlaybackRate,
                                         kAudioUnitScope_Global,
                                         0,
                                         &playbackRate));
    
    return playbackRate;
}


- (void)setPlaybackRate:(AudioUnitParameterValue)playbackRate
{
    TOThrowOnError(AudioUnitSetParameter(_varispeedUnit->unit,
                                         kVarispeedParam_PlaybackRate,
                                         kAudioUnitScope_Global,
                                         0,
                                         playbackRate,
                                         0));
    
    self.startTime = self.startTime; /* this will call the setter which will set the correct start time */
}



#pragma mark - Audio File Player Overwrite Methods

- (void)setStartTime:(double)startTime
{
    /*
     Depending on the playback rate the varispeed unit will 
     ask the file player for more or less samples during 
     the same time we need to adjust the start time of the
     file player.
     */
    
    startTime *= self.playbackRate;
    [super setStartTime:startTime];
}

@end
