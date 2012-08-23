//
//  TOVarispeed.m
//  VarispeedTest
//
//  Created by Tobias Ottenweller on 20.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOVarispeed.h"
#import "TOCAShortcuts.h"


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
}

@end
