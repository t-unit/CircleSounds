//
//  TOBandEqualizer.m
//  FilePlayMixerMeter
//
//  Created by Tobias Ottenweller on 17.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOBandEqualizer.h"
#import "TOCAShortcuts.h"


@implementation TOBandEqualizer

- (UInt32)maxNumberOfBands
{
    UInt32 maxNumBands = 0;
    UInt32 propSize = sizeof(maxNumBands);
    TOThrowOnError(AudioUnitGetProperty(equalizerUnit,
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
    TOThrowOnError(AudioUnitGetProperty(equalizerUnit,
                                        kAUNBandEQProperty_NumberOfBands,
                                        kAudioUnitScope_Global,
                                        0,
                                        &numBands,
                                        &propSize));
    
    return numBands;
}


- (void)setNumBands:(UInt32)numBands
{
    TOThrowOnError(AudioUnitSetProperty(equalizerUnit,
                                        kAUNBandEQProperty_NumberOfBands,
                                        kAudioUnitScope_Global,
                                        0,
                                        &numBands,
                                        sizeof(numBands)));
    
    // since this method is called before the eq unit gets initialized
    // this is a good point to set its filter type
    
    
}


- (void)setBands:(NSArray *)bands
{
    _bands = bands;
    
    for (NSUInteger i=0; i<bands.count; i++) {
        AudioUnitParameterValue frequency = [[bands objectAtIndex:i] floatValue];
        
        TOThrowOnError(AudioUnitSetParameter(equalizerUnit,
                                             kAUNBandEQParam_Frequency+i,
                                             kAudioUnitScope_Global,
                                             0,
                                             frequency,
                                             0));
        
//        if (frequency < 1000) { // bypass band is working!
//            TOThrowOnError(AudioUnitSetParameter(equalizerUnit,
//                                                 kAUNBandEQParam_BypassBand+i,
//                                                 kAudioUnitScope_Global,
//                                                 0,
//                                                 0,
//                                                 0));
//        }
//        
//        TOThrowOnError(AudioUnitSetParameter(equalizerUnit,
//                                             kAUNBandEQParam_FilterType+i,
//                                             kAudioUnitScope_Global,
//                                             0,
//                                             kAUNBandEQFilterType_BandStop,
//                                             0));
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
    
    TOThrowOnError(AudioUnitGetParameter(equalizerUnit,
                                         parameterID,
                                         kAudioUnitScope_Global,
                                         0,
                                         &gain));
    
    return gain;
}


- (void)setGain:(AudioUnitParameterValue)gain forBandAtPosition:(NSUInteger)bandPosition
{
    AudioUnitParameterID parameterID = kAUNBandEQParam_Gain + bandPosition;
    
    TOThrowOnError(AudioUnitSetParameter(equalizerUnit,
                                         parameterID,
                                         kAudioUnitScope_Global,
                                         0,
                                         gain,
                                         0));
}


- (AudioUnitParameterValue)globalGain
{
    AudioUnitParameterValue globalGain;
    
    TOThrowOnError(AudioUnitGetParameter(equalizerUnit,
                                         kAUNBandEQParam_GlobalGain,
                                         kAudioUnitScope_Global,
                                         0,
                                         &globalGain));
    
    return globalGain;
}


- (void)setGlobalGain:(AudioUnitParameterValue)globalGain
{
    TOThrowOnError(AudioUnitSetParameter(equalizerUnit,
                                         kAUNBandEQParam_GlobalGain,
                                         kAudioUnitScope_Global,
                                         0,
                                         globalGain,
                                         0));
}


@end
