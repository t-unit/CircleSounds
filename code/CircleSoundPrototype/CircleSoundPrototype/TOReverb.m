//
//  TOReverb.m
//  ReverbTest
//
//  Created by Tobias Ottenweller on 20.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOReverb.h"
#import "TOPlugableSound.h"


@implementation TOReverb


- (id)init
{
    self = [super init];
    
    if (self) {
        _reverbUnit = [[TOAudioUnit alloc] init];
        _reverbUnit->description = TOAudioComponentDescription(kAudioUnitType_Effect, kAudioUnitSubType_Reverb2);
        
        _audioUnits = [_audioUnits arrayByAddingObject:_reverbUnit];
    }
    
    return self;
}


#pragma mark - Reverb Paramter Wrapper Methods

- (AudioUnitParameterValue)dryWetMix
{
    AudioUnitParameterValue dryWetMix;
    
    TOThrowOnError(AudioUnitGetParameter(_reverbUnit->unit,
                                         kReverb2Param_DryWetMix,
                                         kAudioUnitScope_Global,
                                         0,
                                         &dryWetMix));
    
    
    return dryWetMix;
}


- (void)setDryWetMix:(AudioUnitParameterValue)dryWetMix
{
    TOThrowOnError(AudioUnitSetParameter(_reverbUnit->unit,
                                         kReverb2Param_DryWetMix,
                                         kAudioUnitScope_Global,
                                         0,
                                         dryWetMix,
                                         0));
}


- (AudioUnitParameterValue)gain
{
    AudioUnitParameterValue gain;
    
    TOThrowOnError(AudioUnitGetParameter(_reverbUnit->unit,
                                         kReverb2Param_Gain,
                                         kAudioUnitScope_Global,
                                         0,
                                         &gain));
    
    
    return gain;
}


- (void)setGain:(AudioUnitParameterValue)gain
{
    TOThrowOnError(AudioUnitSetParameter(_reverbUnit->unit,
                                         kReverb2Param_Gain,
                                         kAudioUnitScope_Global,
                                         0,
                                         gain,
                                         0));
}


- (AudioUnitParameterValue)minDelayTime
{
    AudioUnitParameterValue minDelayTime;
    
    TOThrowOnError(AudioUnitGetParameter(_reverbUnit->unit,
                                         kReverb2Param_MinDelayTime,
                                         kAudioUnitScope_Global,
                                         0,
                                         &minDelayTime));
    
    
    return minDelayTime;
}


- (void)setMinDelayTime:(AudioUnitParameterValue)minDelayTime
{
    TOThrowOnError(AudioUnitSetParameter(_reverbUnit->unit,
                                         kReverb2Param_MinDelayTime,
                                         kAudioUnitScope_Global,
                                         0,
                                         minDelayTime,
                                         0));
}


- (AudioUnitParameterValue)maxDelayTime
{
    AudioUnitParameterValue maxDelayTime;
    
    TOThrowOnError(AudioUnitGetParameter(_reverbUnit->unit,
                                         kReverb2Param_MaxDelayTime,
                                         kAudioUnitScope_Global,
                                         0,
                                         &maxDelayTime));
    
    
    return maxDelayTime;
}


- (void)setMaxDelayTime:(AudioUnitParameterValue)maxDelayTime
{
    TOThrowOnError(AudioUnitSetParameter(_reverbUnit->unit,
                                         kReverb2Param_MaxDelayTime,
                                         kAudioUnitScope_Global,
                                         0,
                                         maxDelayTime,
                                         0));
}


- (AudioUnitParameterValue)decayTimeAt0Hz
{
    AudioUnitParameterValue decayTimeAt0Hz;
    
    TOThrowOnError(AudioUnitGetParameter(_reverbUnit->unit,
                                         kReverb2Param_DecayTimeAt0Hz,
                                         kAudioUnitScope_Global,
                                         0,
                                         &decayTimeAt0Hz));
    
    
    return decayTimeAt0Hz;
}


- (void)setDecayTimeAt0Hz:(AudioUnitParameterValue)decayTimeAt0Hz
{
    TOThrowOnError(AudioUnitSetParameter(_reverbUnit->unit,
                                         kReverb2Param_DecayTimeAt0Hz,
                                         kAudioUnitScope_Global,
                                         0,
                                         decayTimeAt0Hz,
                                         0));
}


- (AudioUnitParameterValue)decayTimeAtNyquist
{
    AudioUnitParameterValue decayTimeAtNyquist;
    
    TOThrowOnError(AudioUnitGetParameter(_reverbUnit->unit,
                                         kReverb2Param_DecayTimeAtNyquist,
                                         kAudioUnitScope_Global,
                                         0,
                                         &decayTimeAtNyquist));
    
    
    return decayTimeAtNyquist;
}


- (void)setDecayTimeAtNyquist:(AudioUnitParameterValue)decayTimeAtNyquist
{
    TOThrowOnError(AudioUnitSetParameter(_reverbUnit->unit,
                                         kReverb2Param_DecayTimeAtNyquist,
                                         kAudioUnitScope_Global,
                                         0,
                                         decayTimeAtNyquist,
                                         0));
}


- (int)randomizeReflections
{
    AudioUnitParameterValue randomizeReflections;
    
    TOThrowOnError(AudioUnitGetParameter(_reverbUnit->unit,
                                         kReverb2Param_RandomizeReflections,
                                         kAudioUnitScope_Global,
                                         0,
                                         &randomizeReflections));
    
    
    return (int)randomizeReflections;
}


- (void)setRandomizeReflections:(int)randomizeReflections
{
    TOThrowOnError(AudioUnitSetParameter(_reverbUnit->unit,
                                         kReverb2Param_RandomizeReflections,
                                         kAudioUnitScope_Global,
                                         0,
                                         (AudioUnitParameterValue)randomizeReflections,
                                         0));
}

@end
