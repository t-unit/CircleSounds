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
    AUGraph _graph;
    
    TOAudioUnit *_mixerUnit;
    TOAudioUnit *_rioUnit;
    

    UInt32 _maxBusTaken; /* -1 if no bus is in use */
    NSArray *_availibleBuses; /* number of buses ready for reuse */
    
    
    Float64 _startSampleTime; /* NaN before set to correct value*/
    Float64 _mixerOutputSampleRate;
}

@property (readonly, nonatomic) NSTimeInterval currentPlaybackPosition; // in seconds
@property (readwrite, nonatomic) NSTimeInterval duration; // in seconds


@property (readonly, nonatomic) NSArray *plugableSounds;

- (void)addPlugableSoundObject:(TOPlugableSound *)soundObject;
- (void)removePlugableSoundObject:(TOPlugableSound *)soundObject;


- (void)start;
- (void)stop;
- (void)reset; /* set the playback position back to zero */


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
