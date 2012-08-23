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
#import "NSArray+arrayByRemovingObject.h"

#define PREFERRED_GRAPH_SAMPLE_RATE 44100.0


@implementation TOSoundDocument

- (id)init
{
    self = [super init];
    
    if (self) {
        _plugableSounds = @[];
        availibleBuses = @[];
        
        maxBusTaken = -1;
        
        mixerUnit = [[TOAudioUnit alloc] init];
        rioUnit = [[TOAudioUnit alloc] init];
        
        startSampleTime = currentSampleTime = NAN;
        
        [self setupProcessingGraph];
    }
    
    return self;
}


- (void)dealloc
{
    [self stop];
    
    TOThrowOnError(AUGraphClose(graph));
    TOThrowOnError(AUGraphUninitialize(graph));
    TOThrowOnError(DisposeAUGraph(graph));
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
        
        if (isnan(doc->startSampleTime)) {
            doc->startSampleTime = inTimeStamp->mSampleTime;
        }
        
        doc->currentSampleTime = inTimeStamp->mSampleTime;
    }
    
    return noErr;
}


#pragma mark - AUGraph setup

- (void)setupProcessingGraph
{
    //............................................................................
    // Create AUGraph
    
    TOThrowOnError(NewAUGraph(&graph));
    
    
    //............................................................................
    // Add Audio Units (Nodes) to the graph
    
    mixerUnit->description = TOAudioComponentDescription(kAudioUnitType_Mixer, kAudioUnitSubType_MultiChannelMixer);
    TOThrowOnError(AUGraphAddNode(graph,
                                  &(mixerUnit->description),
                                  &(mixerUnit->node)));
    
    
    rioUnit->description = TOAudioComponentDescription(kAudioUnitType_Output, kAudioUnitSubType_RemoteIO);
    TOThrowOnError(AUGraphAddNode(graph,
                                  &(rioUnit->description),
                                  &(rioUnit->node)));
    
    
    //............................................................................
    // Open the processing graph.
    
    TOThrowOnError(AUGraphOpen(graph));
    
    
    //............................................................................
    // Obtain the audio unit instances from its corresponding node.
    
    TOThrowOnError(AUGraphNodeInfo(graph,
                                   mixerUnit->node,
                                   NULL,
                                   &(mixerUnit->unit)));
    
    TOThrowOnError(AUGraphNodeInfo(graph,
                                   rioUnit->node,
                                   NULL,
                                   &(rioUnit->unit)));
    
    
    //............................................................................
    // Connect the nodes of the audio processing graph
    
    TOThrowOnError(AUGraphConnectNodeInput(graph,
                                           mixerUnit->node,      // source node
                                           0,                    // source bus
                                           rioUnit->node,        // destination node
                                           0));                  // destination bus
    
    
    //............................................................................
    // Initialize Graph
    TOThrowOnError(AUGraphInitialize(graph));
    
    
    //............................................................................
    // Set properties/parameters of the units inside the graph
    
    // Enable metering at the output of the mixer unit
    UInt32 meteringMode = 1; // enabled
    TOThrowOnError(AudioUnitSetProperty(mixerUnit->unit,
                                        kAudioUnitProperty_MeteringMode,
                                        kAudioUnitScope_Output,
                                        0,
                                        &meteringMode,
                                        sizeof(meteringMode)));
    
    
    // add render notification callback to the mixer output
    TOThrowOnError(AudioUnitAddRenderNotify(mixerUnit->unit,
                                            MixerUnitRenderNoteCallack,
                                            (__bridge void *)(self)));
    
    
    // obtain the mixer output sample rate
    UInt32 propSize = sizeof(mixerOutputSampleRate);
    TOThrowOnError(AudioUnitGetProperty(mixerUnit->unit,
                                        kAudioUnitProperty_SampleRate,
                                        kAudioUnitScope_Output,
                                        0,
                                        &mixerOutputSampleRate,
                                        &propSize));

}


#pragma mark - Audio Session

- (void)setupAudioSession
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
        
        TOThrowOnError(AUGraphIsRunning(graph, &isRunning));
        
        if (!isRunning) {
            TOThrowOnError(AUGraphStart(graph));
        }
    }
}


- (void)stop
{
    @synchronized(self) {
        Boolean isRunning;
        
        TOThrowOnError(AUGraphIsRunning(graph, &isRunning));
        
        if (isRunning) {
            TOThrowOnError(AUGraphStop(graph));
        }
    }
}


- (void)reset
{    
}


# pragma mark - Plugable Sounds Handling

- (void)addPlugableSoundObject:(TOPlugableSound *)soundObject
{
    @synchronized(self) {
        _plugableSounds = [_plugableSounds arrayByAddingObject:soundObject];
        
        // add node to the graph and get the unit back
        for (TOAudioUnit *au in soundObject.audioUnits) {
            TOThrowOnError(AUGraphAddNode(graph,
                                          &(au->description),
                                          &(au->node)));
            
            TOThrowOnError(AUGraphNodeInfo(graph,
                                           au->node,
                                           NULL,
                                           &(au->unit)));
        }
        
        
        // connect the nodes inside the sound object
        for (NSInteger i=0; i<soundObject.audioUnits.count-1; i++) {
            TOAudioUnit *sourceAU = soundObject.audioUnits[i];
            TOAudioUnit *destAU = soundObject.audioUnits[i+1];
            
            TOThrowOnError(AUGraphConnectNodeInput(graph,
                                                   sourceAU->node,
                                                   0,
                                                   destAU->node,
                                                   0));
        }
        
        
        // connect the last AU inside the sound object to the mixer unit;
        UInt32 mixerInputBus;
        
        if (availibleBuses.count) {
            mixerInputBus = [availibleBuses[0] unsignedIntegerValue];
        }
        else {
            mixerInputBus = ++maxBusTaken;
        }
        
        TOAudioUnit *sourceAU = [soundObject.audioUnits lastObject];
        TOThrowOnError(AUGraphConnectNodeInput(graph,
                                               sourceAU->node,
                                               0,
                                               mixerUnit->node,
                                               mixerInputBus));
    }
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
            
            TOThrowOnError(AUGraphDisconnectNodeInput(graph,
                                                      destAU->node,
                                                      0));
        }
        
        
        // disconnect the last AU inside the sound object from the mixer unit;
        TOAudioUnit *lastAU = [soundObject.audioUnits lastObject];
        AUNodeInteraction lastAUInteraction;
        UInt32 numInteractions = 1;
        
        TOThrowOnError(AUGraphGetNodeInteractions(graph,
                                                  lastAU->node,
                                                  &numInteractions,
                                                  &lastAUInteraction));
        
        UInt32 mixerBus = lastAUInteraction.nodeInteraction.connection.destInputNumber;
        
        TOThrowOnError(AUGraphDisconnectNodeInput(graph,
                                                  mixerUnit->node,
                                                  mixerBus));
        
        availibleBuses = [availibleBuses arrayByAddingObject:@(mixerBus)];
        _plugableSounds = [self.plugableSounds arrayByRemovingObject:soundObject];
        
        TOThrowOnError(AUGraphUpdate(graph, NULL));
        
        
        // set nodes and units to NULL
        for (TOAudioUnit *au in soundObject.audioUnits) {
            memset(&(au->unit), 0, sizeof(AudioUnit));
            memset(&(au->node), 0, sizeof(AUNode));
        }
    }
}


# pragma mark - Property Setter and Getter

- (Float64)currentPlaybackPos
{
    return (currentSampleTime - startSampleTime) / mixerOutputSampleRate;
}


# pragma mark - Mixer Parameter Wrapper Methods

- (AudioUnitParameterValue)avgValueLeft
{
    AudioUnitParameterValue retVal;
    TOThrowOnError(AudioUnitGetParameter(mixerUnit->unit,
                                         kMultiChannelMixerParam_PostAveragePower,
                                         kAudioUnitScope_Output,
                                         0,
                                         &retVal));
    
    return retVal;
}


- (AudioUnitParameterValue)avgValueRight
{
    AudioUnitParameterValue retVal;
    TOThrowOnError(AudioUnitGetParameter(mixerUnit->unit,
                                         kMultiChannelMixerParam_PostAveragePower+1,
                                         kAudioUnitScope_Output,
                                         0,
                                         &retVal));
    
    return retVal;
}


- (AudioUnitParameterValue)peakValueLeft
{
    AudioUnitParameterValue retVal;
    TOThrowOnError(AudioUnitGetParameter(mixerUnit->unit,
                                         kMultiChannelMixerParam_PostPeakHoldLevel,
                                         kAudioUnitScope_Output,
                                         0,
                                         &retVal));
    
    return retVal;
}


- (AudioUnitParameterValue)peakValueRight
{
    AudioUnitParameterValue retVal;
    TOThrowOnError(AudioUnitGetParameter(mixerUnit->unit,
                                         kMultiChannelMixerParam_PostPeakHoldLevel+1,
                                         kAudioUnitScope_Output,
                                         0,
                                         &retVal));
    
    return retVal;
}


- (void)setVolume:(AudioUnitParameterValue)volume
{
    TOThrowOnError(AudioUnitSetParameter(mixerUnit->unit,
                                         kMultiChannelMixerParam_Volume,
                                         kAudioUnitScope_Output,
                                         0,
                                         volume,
                                         0));
}


- (AudioUnitParameterValue)volume
{
    AudioUnitParameterValue retVal;
    TOThrowOnError(AudioUnitGetParameter(mixerUnit->unit,
                                         kMultiChannelMixerParam_Volume,
                                         kAudioUnitScope_Output,
                                         0,
                                         &retVal));
    
    return retVal;
}

@end
