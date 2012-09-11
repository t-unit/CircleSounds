//
//  TOSoundDocument.m
//  CircleSoundPrototype
//
//  Created by Tobias Ottenweller on 22.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOSoundDocument.h"

#import <AVFoundation/AVFoundation.h>
#import "TOAudioUnit.h"
#import "TOCAShortcuts.h"
#import "TOPlugableSound.h"
#import "TOSoundDocumentDelegate.h"
#import "NSSet+setByRemovingObject.h"
#import "NSArray+arrayByRemovingObject.h"


#define PREFERRED_GRAPH_SAMPLE_RATE 44100.0


@interface TOSoundDocument ()

- (void)handleDocumentDurationReached;

@end



@implementation TOSoundDocument

@synthesize duration = _duration;
@synthesize currentPlaybackPosition = _currentPlaybackPosition;


- (id)init
{
    self = [super init];
    
    if (self) {
        _plugableSounds = @[];
        _availibleBuses = [NSSet set];
        
        _maxBusTaken = -1;
        
        _mixerUnit = [[TOAudioUnit alloc] init];
        _rioUnit = [[TOAudioUnit alloc] init];
        
        _startSampleTime = NAN;
        
        [self setupProcessingGraph];
    }
    
    return self;
}


- (void)dealloc
{
    [self pause];
    
    TOThrowOnError(AUGraphClose(_graph));
    TOThrowOnError(AUGraphUninitialize(_graph));
    TOThrowOnError(DisposeAUGraph(_graph));
}


#pragma mark - Audio Render Callbacks

OSStatus MixerUnitRenderNoteCallack(void                        *inRefCon,
                                    AudioUnitRenderActionFlags  *ioActionFlags,
                                    const AudioTimeStamp        *inTimeStamp,
                                    UInt32                      inBusNumber,
                                    UInt32                      inNumberFrames,
                                    AudioBufferList             *ioData
                                   )
{
    TOSoundDocument *doc = (__bridge TOSoundDocument *)inRefCon;
    
    if (*ioActionFlags & kAudioUnitRenderAction_PostRender) {
        
        /* start playback */
        if (isnan(doc->_startSampleTime)) {
            doc->_startSampleTime = inTimeStamp->mSampleTime;
        }
        
        
        /* resume after pause */
        if (doc->_prePausePlaybackPosition) {
            doc->_startSampleTime = inTimeStamp->mSampleTime - doc->_prePausePlaybackPosition * doc->_mixerOutputSampleRate;
            doc->_prePausePlaybackPosition = 0;
        }
        
        doc->_currentPlaybackPosition =  (inTimeStamp->mSampleTime - doc->_startSampleTime) / doc->_mixerOutputSampleRate;
        
        /* handle end of document */
        if (doc->_currentPlaybackPosition > doc->_duration) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [doc handleDocumentDurationReached];
            });
            
        }
    }
    
    return noErr;
}


#pragma mark - AUGraph setup

- (void)setupProcessingGraph
{
    //............................................................................
    // Create AUGraph
    
    TOThrowOnError(NewAUGraph(&_graph));
    
    
    //............................................................................
    // Add Audio Units (Nodes) to the graph
    
    _mixerUnit->description = TOAudioComponentDescription(kAudioUnitType_Mixer, kAudioUnitSubType_MultiChannelMixer);
    TOThrowOnError(AUGraphAddNode(_graph,
                                  &(_mixerUnit->description),
                                  &(_mixerUnit->node)));
    
    
    _rioUnit->description = TOAudioComponentDescription(kAudioUnitType_Output, kAudioUnitSubType_RemoteIO);
    TOThrowOnError(AUGraphAddNode(_graph,
                                  &(_rioUnit->description),
                                  &(_rioUnit->node)));
    
    
    //............................................................................
    // Open the processing graph.
    
    TOThrowOnError(AUGraphOpen(_graph));
    
    
    //............................................................................
    // Obtain the audio unit instances from its corresponding node.
    
    TOThrowOnError(AUGraphNodeInfo(_graph,
                                   _mixerUnit->node,
                                   NULL,
                                   &(_mixerUnit->unit)));
    
    TOThrowOnError(AUGraphNodeInfo(_graph,
                                   _rioUnit->node,
                                   NULL,
                                   &(_rioUnit->unit)));
    
    
    //............................................................................
    // Connect the nodes of the audio processing graph
    
    TOThrowOnError(AUGraphConnectNodeInput(_graph,
                                           _mixerUnit->node,      // source node
                                           0,                     // source bus
                                           _rioUnit->node,        // destination node
                                           0));                   // destination bus
    
    
    //............................................................................
    // Set properties/parameters of the units inside the graph
    
    // Set maximum number of buses on the mixer node
    UInt32 numbuses = 100; // TODO: adjust this value while adding new sound to the graph!
    TOThrowOnError(AudioUnitSetProperty(_mixerUnit->unit,
                                        kAudioUnitProperty_ElementCount,
                                        kAudioUnitScope_Input,
                                        0,
                                        &numbuses,
                                        sizeof(UInt32)));
    
    // Enable metering at the output of the mixer unit
    UInt32 meteringMode = 1; // enabled
    TOThrowOnError(AudioUnitSetProperty(_mixerUnit->unit,
                                        kAudioUnitProperty_MeteringMode,
                                        kAudioUnitScope_Output,
                                        0,
                                        &meteringMode,
                                        sizeof(meteringMode)));
    
    
    // add render notification callback to the mixer output
    TOThrowOnError(AudioUnitAddRenderNotify(_mixerUnit->unit,
                                            MixerUnitRenderNoteCallack,
                                            (__bridge void *)(self)));
    
    
    // obtain the mixer output sample rate
    UInt32 propSize = sizeof(_mixerOutputSampleRate);
    TOThrowOnError(AudioUnitGetProperty(_mixerUnit->unit,
                                        kAudioUnitProperty_SampleRate,
                                        kAudioUnitScope_Output,
                                        0,
                                        &_mixerOutputSampleRate,
                                        &propSize));
    
    
    //............................................................................
    // Initialize Graph
    TOThrowOnError(AUGraphInitialize(_graph));
}


#pragma mark - Audio Session

- (void)setAudioSessionActive
{
    NSError *error = nil;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    [session setActive:YES error:&error];
    
    [session setPreferredSampleRate:PREFERRED_GRAPH_SAMPLE_RATE error:&error];
    [[AVAudioSession sharedInstance] setPreferredIOBufferDuration:1024.0/PREFERRED_GRAPH_SAMPLE_RATE error:&error];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAudioInterruption:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:session];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAudioRouteChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:session];
    
}


- (void)handleAudioInterruption:(NSNotification *)note
{
    
}


- (void)handleAudioRouteChange:(NSNotification *)note
{
    
}


# pragma mark - Start, Stop and Restart

- (void)start
{
    @synchronized(self) {
        Boolean isRunning;
        
        TOThrowOnError(AUGraphIsRunning(_graph, &isRunning));
        
        if (!isRunning) {
            [self setAudioSessionActive];
            TOThrowOnError(AUGraphStart(_graph));
            
            if ([self.delegate respondsToSelector:@selector(soundDocumentDidStartPlayback:)]) {
                [self.delegate soundDocumentDidStartPlayback:self];
            }
        }
    }
}


- (void)pause
{
    @synchronized(self) {
        Boolean isRunning;
        
        TOThrowOnError(AUGraphIsRunning(_graph, &isRunning));
        
        if (isRunning) {
            TOThrowOnError(AUGraphStop(_graph));
            _prePausePlaybackPosition = _currentPlaybackPosition;
            
            if ([self.delegate respondsToSelector:@selector(soundDocumentDidPausePlayback:)]) {
                [self.delegate soundDocumentDidPausePlayback:self];
            }
        }
    }
}


- (BOOL)isRunning
{
    if (!_graph) {
        return NO;
    }

    Boolean isRunning;
    TOThrowOnError(AUGraphIsRunning(_graph, &isRunning));
    
    return isRunning;
}


- (void)reset
{
    _startSampleTime = NAN;
    _currentPlaybackPosition = 0;
    _prePausePlaybackPosition = 0;
    
    for (TOPlugableSound *sound in self.plugableSounds) {
        [sound handleDocumentReset];
    }


    if ([self.delegate respondsToSelector:@selector(soundDocumentGotReset:)]) {
        [self.delegate soundDocumentGotReset:self];
    }
}



- (void)handleDocumentDurationReached
{
    if (!self.loop) {
        [self pause];
    }
    
    [self reset];
}



# pragma mark - Plugable Sounds Handling

- (void)addPlugableSoundObject:(TOPlugableSound *)soundObject
{
    @synchronized(self) {
        _plugableSounds = [_plugableSounds arrayByAddingObject:soundObject];
        
        // add node to the graph and get the unit back
        for (TOAudioUnit *au in soundObject.audioUnits) {
            TOThrowOnError(AUGraphAddNode(_graph,
                                          &(au->description),
                                          &(au->node)));
            
            TOThrowOnError(AUGraphNodeInfo(_graph,
                                           au->node,
                                           NULL,
                                           &(au->unit)));
        }
        
        
        // connect the nodes inside the sound object
        for (NSInteger i=0; i<soundObject.audioUnits.count-1; i++) {
            TOAudioUnit *sourceAU = soundObject.audioUnits[i];
            TOAudioUnit *destAU = soundObject.audioUnits[i+1];
            
            TOThrowOnError(AUGraphConnectNodeInput(_graph,
                                                   sourceAU->node,
                                                   0,
                                                   destAU->node,
                                                   0));
        }
        
        
        // connect the last AU inside the sound object to the mixer unit;
        UInt32 mixerInputBus;
        
        if (_availibleBuses.count) {
            NSNumber *mixerInputBusObject = [_availibleBuses anyObject];
            
            mixerInputBus = [mixerInputBusObject unsignedIntegerValue];
            _availibleBuses = [_availibleBuses setByRemovingObject:mixerInputBusObject];
        }
        else {
            mixerInputBus = ++_maxBusTaken;
        }

        
        TOAudioUnit *sourceAU = [soundObject.audioUnits lastObject];
        TOThrowOnError(AUGraphConnectNodeInput(_graph,
                                               sourceAU->node,
                                               0,
                                               _mixerUnit->node,
                                               mixerInputBus));
        soundObject.document = self;
        [soundObject setupUnits];
        
        TOThrowOnError(AUGraphUpdate(_graph, NULL));
        
        [soundObject setupFinished];
        
#if DEBUG
        NSLog(@"New Sound (%@) added at mixer bus: %ld", soundObject, mixerInputBus);
#endif
    }
    
    
    if ([self.delegate respondsToSelector:@selector(soundDocument:didAddNewSound:)]) {
        [self.delegate soundDocument:self didAddNewSound:soundObject];
    }
    
    
#if DEBUG
    CAShow(_graph);
#endif
    
}


- (void)removePlugableSoundObject:(TOPlugableSound *)soundObject
{
    @synchronized(self) {
        if (![self.plugableSounds containsObject:soundObject]) {
            return;
        }
        
        // disconnect all the nodes from the graph
        for (NSInteger i=1; i<soundObject.audioUnits.count; i++) {
            TOAudioUnit *destAU = soundObject.audioUnits[i];
            
            TOThrowOnError(AUGraphDisconnectNodeInput(_graph,
                                                      destAU->node,
                                                      0));
        }
        
        
        // disconnect the last AU inside the sound object from the mixer unit;
        TOAudioUnit *lastAU = [soundObject.audioUnits lastObject];
        AUNodeInteraction lastAUInteraction;
        UInt32 numInteractions = 1;
        
        TOThrowOnError(AUGraphGetNodeInteractions(_graph,
                                                  lastAU->node,
                                                  &numInteractions,
                                                  &lastAUInteraction));
        
        UInt32 mixerBus = lastAUInteraction.nodeInteraction.connection.destInputNumber;
        
        TOThrowOnError(AUGraphDisconnectNodeInput(_graph,
                                                  _mixerUnit->node,
                                                  mixerBus));
        
        _availibleBuses = [_availibleBuses setByAddingObject:@(mixerBus)];
        _plugableSounds = [self.plugableSounds arrayByRemovingObject:soundObject];
        
        
        // remove nodes from the graph
        for (TOAudioUnit *au in soundObject.audioUnits) {
            TOThrowOnError(AUGraphRemoveNode(_graph, au->node));
        }
        
        
        [soundObject tearDownUnits];
        TOThrowOnError(AUGraphUpdate(_graph, NULL));
        
        soundObject.document = nil;
        
        // set nodes and units to NULL
        for (TOAudioUnit *au in soundObject.audioUnits) {
            memset(&(au->unit), 0, sizeof(AudioUnit));
            memset(&(au->node), 0, sizeof(AUNode));
        }
        
        
#if DEBUG
        NSLog(@"Removed Sound (%@) at mixer bus: %ld", soundObject, mixerBus);
#endif
    }
    
    if ([self.delegate respondsToSelector:@selector(soundDocument:didRemoveSound:)]) {
        [self.delegate soundDocument:self didRemoveSound:soundObject];
    }
}


# pragma mark - Mixer Parameter Wrapper Methods

- (AudioUnitParameterValue)avgValueLeft
{
    AudioUnitParameterValue retVal;
    TOThrowOnError(AudioUnitGetParameter(_mixerUnit->unit,
                                         kMultiChannelMixerParam_PostAveragePower,
                                         kAudioUnitScope_Output,
                                         0,
                                         &retVal));
    
    return retVal;
}


- (AudioUnitParameterValue)avgValueRight
{
    AudioUnitParameterValue retVal;
    TOThrowOnError(AudioUnitGetParameter(_mixerUnit->unit,
                                         kMultiChannelMixerParam_PostAveragePower+1,
                                         kAudioUnitScope_Output,
                                         0,
                                         &retVal));
    
    return retVal;
}


- (AudioUnitParameterValue)peakValueLeft
{
    AudioUnitParameterValue retVal;
    TOThrowOnError(AudioUnitGetParameter(_mixerUnit->unit,
                                         kMultiChannelMixerParam_PostPeakHoldLevel,
                                         kAudioUnitScope_Output,
                                         0,
                                         &retVal));
    
    return retVal;
}


- (AudioUnitParameterValue)peakValueRight
{
    AudioUnitParameterValue retVal;
    TOThrowOnError(AudioUnitGetParameter(_mixerUnit->unit,
                                         kMultiChannelMixerParam_PostPeakHoldLevel+1,
                                         kAudioUnitScope_Output,
                                         0,
                                         &retVal));
    
    return retVal;
}


- (void)setVolume:(AudioUnitParameterValue)volume
{
    TOThrowOnError(AudioUnitSetParameter(_mixerUnit->unit,
                                         kMultiChannelMixerParam_Volume,
                                         kAudioUnitScope_Output,
                                         0,
                                         volume,
                                         0));
}


- (AudioUnitParameterValue)volume
{
    AudioUnitParameterValue retVal;
    TOThrowOnError(AudioUnitGetParameter(_mixerUnit->unit,
                                         kMultiChannelMixerParam_Volume,
                                         kAudioUnitScope_Output,
                                         0,
                                         &retVal));
    
    return retVal;
}

@end
