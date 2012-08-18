//
//  TOBandEqualizer.h
//  FilePlayMixerMeter
//
//  Created by Tobias Ottenweller on 17.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>


/**
 Abstract class for handling of an AUNBandEQ unit.
 
 Note that calling any method or accessing any property without having
 the equalizer unit instantiated might not have any effect or might even
 cause an exception being thrown.
 */
@interface TOBandEqualizer : NSObject
{
    /**
     The equalizer unit. Objects of this class will not instantiate this unit. 
     */
    AudioUnit equalizerUnit;
}


@property (readonly, nonatomic) UInt32 maxNumberOfBands;


/**
 Can only be set if the equalizer unit is uninitialized. The number
 of elements in this array must no be greater than 'maxNumberOfBands'.
 */
@property (readwrite, nonatomic) UInt32 numBands;


/**
 An array contains frequencies in Hz for each band of the equalizer unit.
 Frequencies must be between 20 and SampleRate/2. The number of supplied
 frequencies must match the value of 'numBands'.
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
