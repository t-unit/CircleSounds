//
//  TOSoundDocument.h
//  CircleSoundPrototype
//
//  Created by Tobias Ottenweller on 22.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class TOPlugableSound;
@class TOAudioUnit;


@interface TOSoundDocument : NSObject
{
    AUGraph graph;
    
    TOAudioUnit *mixerUnit;
    TOAudioUnit *rioUnit;
    

    UInt32 maxBusTaken; /* -1 if no bus is in use */
    NSArray *availibleBuses; /* number of buses ready for reuse */
    
    
    Float64 startSampleTime; /* NaN before set to correct value*/
    Float64 currentSampleTime; /* NaN before set to correct value*/
    
    Float64 mixerOutputSampleRate;
}

@property (readonly, nonatomic) Float64 currentPlaybackPos; // in seconds


@property (readonly, nonatomic) NSArray *plugableSounds;

- (void)addPlugableSoundObject:(TOPlugableSound *)soundObject;
- (void)removePlugableSoundObject:(TOPlugableSound *)soundObject;


- (void)start;
- (void)stop;
- (void)reset;


/**
 Monitor properties. Return decibel values between -∞ and 0.
 */
@property (assign, nonatomic) AudioUnitParameterValue avgValueLeft;
@property (assign, nonatomic) AudioUnitParameterValue avgValueRight;
@property (assign, nonatomic) AudioUnitParameterValue peakValueLeft;
@property (assign, nonatomic) AudioUnitParameterValue peakValueRight;


/**
 Linear Gain. Set to values beween 0 and 1. 
 Default Value is 1.
 */
@property (assign, nonatomic) AudioUnitParameterValue volume;

@end
