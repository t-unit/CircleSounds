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
@protocol TOSoundDocumentDelegate;



/**
 A Collection of Plugable Sound object.
 This class handles playback of the sounds.
 It is unsing a Audio Processing Graph to 
 manage the sounds.
 */
@interface TOSoundDocument : NSObject
{
    AUGraph _graph;
    
    TOAudioUnit *_mixerUnit;
    TOAudioUnit *_rioUnit;
    

    UInt32 _maxBusTaken; /* -1 if no bus is in use */
    NSSet *_availibleBuses; /* number of buses ready for reuse */
    
    
    Float64 _startSampleTime; /* NaN before set to correct value */
    NSTimeInterval _prePausePlaybackPosition; /* The playback position position before 
                                                 the graph was stopped while the graph 
                                                 is not running. Zero otherwise. 
                                               */
    
    Float64 _mixerOutputSampleRate;
}

@property (weak, nonatomic) id<TOSoundDocumentDelegate> delegate;

@property (readonly, nonatomic) NSTimeInterval currentPlaybackPosition; // in seconds
@property (readwrite, nonatomic) NSTimeInterval duration; // in seconds


/**
 Should the document restart replaying after it reached 'duration'?
 */
@property (readwrite, nonatomic) BOOL loop;


@property (readonly, nonatomic) NSArray *plugableSounds;

- (void)addPlugableSoundObject:(TOPlugableSound *)soundObject;
- (void)removePlugableSoundObject:(TOPlugableSound *)soundObject;


- (void)start;
- (void)pause;
- (void)reset; /* set the playback position back to zero */

@property (readonly, nonatomic) BOOL isRunning;


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
