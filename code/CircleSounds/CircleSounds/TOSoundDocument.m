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
    
    AUGraphClose(_graph);
    AUGraphUninitialize(_graph);
    DisposeAUGraph(_graph);
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
    UInt32 numbuses = 0; // the value will be adjusted while adding and removing sounds
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
    [self pause];
}


- (void)handleAudioRouteChange:(NSNotification *)note
{
    [self pause];
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

- (UInt32)mixerInputBusForNewPlugableSound
{
    UInt32 mixerInputBus = ++_maxBusTaken;
        
    // Set number of buses on the mixer node
    UInt32 numbuses = _maxBusTaken + 1;
    TOThrowOnError(AudioUnitSetProperty(_mixerUnit->unit,
                                        kAudioUnitProperty_ElementCount,
                                        kAudioUnitScope_Input,
                                        0,
                                        &numbuses,
                                        sizeof(UInt32)));
    
    return mixerInputBus;
}


- (UInt32)mixerInputBusForPlugableSound:(TOPlugableSound *)plugableSound
{
    TOAudioUnit *lastAudioUnit = [plugableSound.audioUnits lastObject];
    
    UInt32 numInteractions;
    TOThrowOnError(AUGraphCountNodeInteractions(_graph,
                                                lastAudioUnit->node,
                                                &numInteractions));
    
    AUNodeInteraction *lastAudioUnitInteractions = (AUNodeInteraction *)malloc(sizeof(AUNodeInteraction) * numInteractions);
    
    TOThrowOnError(AUGraphGetNodeInteractions(_graph,
                                              lastAudioUnit->node,
                                              &numInteractions,
                                              lastAudioUnitInteractions));
    
    
    UInt32 mixerBus;
    for (UInt32 i=0; i<numInteractions; i++) {
        AUNodeInteraction interaction = lastAudioUnitInteractions[i];
        
        if (interaction.nodeInteraction.connection.destNode == _mixerUnit->node) {
            mixerBus = interaction.nodeInteraction.connection.destInputNumber;
            break;
        }
    }
    
    free(lastAudioUnitInteractions);
    return mixerBus;
}


- (void)addPlugableSoundObject:(TOPlugableSound *)soundObject
{
    if (soundObject.document) {
        @throw [[NSException alloc] initWithName:NSInternalInconsistencyException
                                          reason:@"A plugable sound cannot be part of more than one document once at a time"
                                        userInfo:nil];
    }
    
    @synchronized(self) {
        _plugableSounds = [_plugableSounds arrayByAddingObject:soundObject];
        
        // add nodes to the graph and get the units back
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
        UInt32 mixerInputBus = [self mixerInputBusForNewPlugableSound];

        TOAudioUnit *sourceAU = [soundObject.audioUnits lastObject];
        TOThrowOnError(AUGraphConnectNodeInput(_graph,
                                               sourceAU->node,
                                               0,
                                               _mixerUnit->node,
                                               mixerInputBus));
        soundObject.document = self;
        [soundObject setupUnits];
        
        TOThrowOnError(AUGraphUpdate(_graph, NULL)); // make the changes happen
        
        [soundObject setupFinished];
        
#if DEBUG
        NSLog(@"New Sound (%@) added at mixer bus: %ld", soundObject, mixerInputBus);
#endif
    }
    
    // inform the delegate
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
        
        
        //
        // disconnect all the nodes from the graph
        //
        for (NSInteger i=1; i<soundObject.audioUnits.count; i++) {
            TOAudioUnit *destAU = soundObject.audioUnits[i];
            
            TOThrowOnError(AUGraphDisconnectNodeInput(_graph,
                                                      destAU->node,
                                                      0));
        }
        
        
        //
        // disconnect the last AU inside the sound object from the mixer unit;
        //
        UInt32 mixerBus = [self mixerInputBusForPlugableSound:soundObject];
        
        TOThrowOnError(AUGraphDisconnectNodeInput(_graph,
                                                  _mixerUnit->node,
                                                  mixerBus));
        
        _plugableSounds = [self.plugableSounds arrayByRemovingObject:soundObject];
        
        
        //
        // rearange the mixer input
        //
        TOAudioUnit *maxBusUnit;
        SInt64 maxBusNum = -1;
        
        for (TOPlugableSound *s in self.plugableSounds) {
            UInt32 mixerBus = [self mixerInputBusForPlugableSound:s];
            
            if (mixerBus > maxBusNum) {
                maxBusUnit = [s.audioUnits lastObject];
                maxBusNum = mixerBus;
            }
        }

        
        if (maxBusNum != -1) {
            TOThrowOnError(AUGraphDisconnectNodeInput(_graph,
                                                      _mixerUnit->node,
                                                      maxBusNum));
            
            TOThrowOnError(AUGraphConnectNodeInput(_graph,
                                                   maxBusUnit->node,
                                                   0,
                                                   _mixerUnit->node,
                                                   mixerBus));
        }
        
        // set the new number of input buses of the mixer unit
        TOThrowOnError(AudioUnitSetProperty(_mixerUnit->unit,
                                            kAudioUnitProperty_ElementCount,
                                            kAudioUnitScope_Input,
                                            0,
                                            &_maxBusTaken,
                                            sizeof(UInt32)));
        
        _maxBusTaken--;
        
        
        //
        // remove nodes from the graph
        //
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
    
    
    //
    // inform the delegate about the changes
    //
    if ([self.delegate respondsToSelector:@selector(soundDocument:didRemoveSound:)]) {
        [self.delegate soundDocument:self didRemoveSound:soundObject];
    }
    
#if DEBUG
    CAShow(_graph);
#endif
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
