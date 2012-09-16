//
//  TOBandEqualizer.h
//  EqualizerTest
//
//  Created by Tobias Ottenweller on 17.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOVarispeedSound.h"

/**
 Wrapper for the 'kAudioUnitSubType_NBandEQ' unit.
 */
@interface TOEqualizerSound : TOVarispeedSound
{
    TOAudioUnit *_equalizerUnit;
    
    NSArray *_bands;
    NSMutableArray *_bandGains;
    
    AudioUnitParameterValue _globalGain;
}


@property (readonly, nonatomic) UInt32 maxNumberOfBands;


/**
 An array contains frequencies in Hz for each band of the equalizer unit.
 Frequencies must be between 20 and SampleRate/2.
 
 Can only be set if the equalizer unit is uninitialized. This is before the
 sound has been added to the document! The number of elements in this array 
 must no be greater than 'maxNumberOfBands'.
 */
@property (readwrite, nonatomic) NSArray *bands;



/**
 Gain in decibel. Values between -96 and 24 will be accepted.
 Default value is 0 db.
 */
- (AudioUnitParameterValue)gainForBandAtPosition:(NSUInteger)bandPosition;
- (void)setGain:(AudioUnitParameterValue)gain forBandAtPosition:(NSUInteger)bandPosition;

@property (readwrite, nonatomic) AudioUnitParameterValue globalGain;

@end

