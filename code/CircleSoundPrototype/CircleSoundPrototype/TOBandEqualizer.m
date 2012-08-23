//
//  TOBandEqualizer.m
//  EqualizerTest
//
//  Created by Tobias Ottenweller on 17.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOBandEqualizer.h"
#import "TOCAShortcuts.h"


@implementation TOBandEqualizer


- (id)init
{
    self = [super init];
    
    if (self) {
        _equalizerUnit = [[TOAudioUnit alloc] init];
        _equalizerUnit->description = TOAudioComponentDescription(kAudioUnitType_Effect, kAudioUnitSubType_NBandEQ);
        
        _audioUnits = [_audioUnits arrayByAddingObject:_equalizerUnit];
    }
    
    return self;
}


# pragma mark - EQ wrapper methods

- (UInt32)maxNumberOfBands
{
    UInt32 maxNumBands = 0;
    UInt32 propSize = sizeof(maxNumBands);
    TOThrowOnError(AudioUnitGetProperty(_equalizerUnit->unit,
                                        kAUNBandEQProperty_MaxNumberOfBands,
                                        kAudioUnitScope_Global,
                                        0,
                                        &maxNumBands,
                                        &propSize));
    
    return maxNumBands;
}


- (UInt32)numBands
{
    UInt32 numBands;
    UInt32 propSize = sizeof(numBands);
    TOThrowOnError(AudioUnitGetProperty(_equalizerUnit->unit,
                                        kAUNBandEQProperty_NumberOfBands,
                                        kAudioUnitScope_Global,
                                        0,
                                        &numBands,
                                        &propSize));
    
    return numBands;
}


- (void)setNumBands:(UInt32)numBands
{
    TOThrowOnError(AudioUnitSetProperty(_equalizerUnit->unit,
                                        kAUNBandEQProperty_NumberOfBands,
                                        kAudioUnitScope_Global,
                                        0,
                                        &numBands,
                                        sizeof(numBands)));
}


- (void)setBands:(NSArray *)bands
{
    _bands = bands;
    
    for (NSUInteger i=0; i<bands.count; i++) {
        TOThrowOnError(AudioUnitSetParameter(_equalizerUnit->unit,
                                             kAUNBandEQParam_Frequency+i,
                                             kAudioUnitScope_Global,
                                             0,
                                             (AudioUnitParameterValue)[[bands objectAtIndex:i] floatValue],
                                             0));
        
        
        // setting the bypassBand paramter does work!
//        TOThrowOnError(AudioUnitSetParameter(equalizerUnit,
//                                             kAUNBandEQParam_BypassBand+i,
//                                             kAudioUnitScope_Global,
//                                             0,
//                                             1,
//                                             0));
//        
        TOThrowOnError(AudioUnitSetParameter(_equalizerUnit->unit,
                                             kAUNBandEQParam_FilterType+i,
                                             kAudioUnitScope_Global,
                                             0,
                                             kAUNBandEQFilterType_Parametric,
                                             0));
//
//        TOThrowOnError(AudioUnitSetParameter(equalizerUnit,
//                                             kAUNBandEQParam_Bandwidth+i,
//                                             kAudioUnitScope_Global,
//                                             0,
//                                             5.0,
//                                             0));
    }
}


- (AudioUnitParameterValue)gainForBandAtPosition:(NSUInteger)bandPosition
{
    AudioUnitParameterValue gain;
    AudioUnitParameterID parameterID = kAUNBandEQParam_Gain + bandPosition;
    
    TOThrowOnError(AudioUnitGetParameter(_equalizerUnit->unit,
                                         parameterID,
                                         kAudioUnitScope_Global,
                                         0,
                                         &gain));
    
    return gain;
}


- (void)setGain:(AudioUnitParameterValue)gain forBandAtPosition:(NSUInteger)bandPosition
{
    AudioUnitParameterID parameterID = kAUNBandEQParam_Gain + bandPosition;
    
    TOThrowOnError(AudioUnitSetParameter(_equalizerUnit->unit,
                                         parameterID,
                                         kAudioUnitScope_Global,
                                         0,
                                         gain,
                                         0));
}

@end
