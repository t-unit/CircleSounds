//
//  TOReverb.m
//  ReverbTest
//
//  Created by Tobias Ottenweller on 20.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOReverbSound.h"
#import "TOPlugableSound.h"


@implementation TOReverbSound


- (id)init
{
    self = [super init];
    
    if (self) {
        _reverbUnit = [[TOAudioUnit alloc] init];
        _reverbUnit->description = TOAudioComponentDescription(kAudioUnitType_Effect, kAudioUnitSubType_Reverb2);
        
        _audioUnits = [_audioUnits arrayByAddingObject:_reverbUnit];
        
        // property default values
        _minDelayTime = 0.008;
        _maxDelayTime = 0.050;
        _decayTimeAt0Hz = 0;
        _decayTimeAtNyquist = 0.5;
        _randomizeReflections = 1;
    }
    
    return self;
}


#pragma mark - Reverb Paramter Wrapper Methods


- (void)setDryWetMix:(AudioUnitParameterValue)dryWetMix
{
    _dryWetMix = dryWetMix;
    
    if (_reverbUnit->unit) {
        [self applyDryWetMix];
    }
}


- (void)applyDryWetMix
{
    TOThrowOnError(AudioUnitSetParameter(_reverbUnit->unit,
                                         kReverb2Param_DryWetMix,
                                         kAudioUnitScope_Global,
                                         0,
                                         _dryWetMix,
                                         0));
}



- (void)setGain:(AudioUnitParameterValue)gain
{
    _gain = gain;
    
    if (_reverbUnit->unit) {
        [self applyGain];
    }
}


- (void)applyGain
{
    TOThrowOnError(AudioUnitSetParameter(_reverbUnit->unit,
                                         kReverb2Param_Gain,
                                         kAudioUnitScope_Global,
                                         0,
                                         _gain,
                                         0));
}


- (void)setMinDelayTime:(AudioUnitParameterValue)minDelayTime
{
    _minDelayTime = minDelayTime;
    
    if (_reverbUnit->unit) {
        [self applyMinDelayTime];
    }
}


- (void)applyMinDelayTime
{
    TOThrowOnError(AudioUnitSetParameter(_reverbUnit->unit,
                                         kReverb2Param_MinDelayTime,
                                         kAudioUnitScope_Global,
                                         0,
                                         _minDelayTime,
                                         0));
}


- (void)setMaxDelayTime:(AudioUnitParameterValue)maxDelayTime
{
    _maxDelayTime = maxDelayTime;
    
    if (_reverbUnit->unit) {
        [self applyMaxDelayTime];
    }
}


- (void)applyMaxDelayTime
{
    TOThrowOnError(AudioUnitSetParameter(_reverbUnit->unit,
                                         kReverb2Param_MaxDelayTime,
                                         kAudioUnitScope_Global,
                                         0,
                                         _maxDelayTime,
                                         0));
}


- (void)setDecayTimeAt0Hz:(AudioUnitParameterValue)decayTimeAt0Hz
{
    _decayTimeAt0Hz = decayTimeAt0Hz;
    
    if (_reverbUnit->unit) {
        [self applyDecayTimeAt0Hz];
    }
}


- (void)applyDecayTimeAt0Hz
{
    TOThrowOnError(AudioUnitSetParameter(_reverbUnit->unit,
                                         kReverb2Param_DecayTimeAt0Hz,
                                         kAudioUnitScope_Global,
                                         0,
                                         _decayTimeAt0Hz,
                                         0));
}


- (void)setDecayTimeAtNyquist:(AudioUnitParameterValue)decayTimeAtNyquist
{
    _decayTimeAtNyquist = decayTimeAtNyquist;
    
    if (_reverbUnit->unit) {
        [self applyDecayTimeAtNyquist];
    }
}


- (void)applyDecayTimeAtNyquist
{
    TOThrowOnError(AudioUnitSetParameter(_reverbUnit->unit,
                                         kReverb2Param_DecayTimeAtNyquist,
                                         kAudioUnitScope_Global,
                                         0,
                                         _decayTimeAtNyquist,
                                         0));
}


- (void)setRandomizeReflections:(int)randomizeReflections
{
    _randomizeReflections = randomizeReflections;
    
    if (_reverbUnit->unit) {
        [self applyRandomizeReflections];
    }
}


- (void)applyRandomizeReflections
{
    TOThrowOnError(AudioUnitSetParameter(_reverbUnit->unit,
                                         kReverb2Param_RandomizeReflections,
                                         kAudioUnitScope_Global,
                                         0,
                                         (AudioUnitParameterValue)_randomizeReflections,
                                         0));
}

@end
