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
    
    // mixer bus use info
    UInt32 maxBusTaken; /* -1 if no bus is in use */
    NSArray *availibleBuses; /* number of buses ready for reuse */
}

@property (readonly, nonatomic) NSArray *plugableSounds;

@property (readonly, nonatomic) double currentPlaybackPos; // in seconds

@property (readonly, nonatomic) AudioTimeStamp currentAudioTimeStamp;


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
