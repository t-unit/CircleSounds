//
//  TOReverb.h
//  ReverbTest
//
//  Created by Tobias Ottenweller on 20.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOVarispeedSound.h"


@interface TOReverbSound : TOVarispeedSound
{
    TOAudioUnit *_reverbUnit;
    
    AudioUnitParameterValue _dryWetMix;
    AudioUnitParameterValue _gain;
    AudioUnitParameterValue _minDelayTime;
    AudioUnitParameterValue _maxDelayTime;
    AudioUnitParameterValue _decayTimeAt0Hz;
    AudioUnitParameterValue _decayTimeAtNyquist;
    int _randomizeReflections;
}


/**
 CrossFade (values from 0 to 100 are excepted). 
 Default value is 0.
 */
@property (assign, nonatomic) AudioUnitParameterValue dryWetMix;


/**
 Gain in decibels. Values between -20 and 20 db are excepted.
 Default value is 0.
 */
@property (assign, nonatomic) AudioUnitParameterValue gain;


/**
 In Seconds. Values between 0.0001 and 1.0 are excepted.
 Default value is 0.008.
 */
@property (assign, nonatomic) AudioUnitParameterValue minDelayTime;


/**
 In Seconds. Values between 0.0001 and 1.0 are excepted.
 Default value is 0.050.
 */
@property (assign, nonatomic) AudioUnitParameterValue maxDelayTime;


/**
 In Seconds. Values between 0.001 and 20 are excepted.
 Default value is 1.
 */
@property (assign, nonatomic) AudioUnitParameterValue decayTimeAt0Hz;


/**
 In Seconds. Values between 0.001 and 20 are excepted.
 Default value is 0.5.
 */
@property (assign, nonatomic) AudioUnitParameterValue decayTimeAtNyquist;


/**
 Values between 1 and 1000 are excepted.
 Default value is 1.
 */
@property (assign, nonatomic) int randomizeReflections;


@end
