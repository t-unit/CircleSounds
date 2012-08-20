//
//  TOReverb.m
//  ReverbTest
//
//  Created by Tobias Ottenweller on 20.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOReverb.h"
#import "TOCAShortcuts.h"


@implementation TOReverb


- (id)init
{
    self = [super init];
    
    if (self) {
        [self initializeGraph];
        TOThrowOnError(AUGraphStart(graph));
    }
    
    return self;
}


- (void)initializeGraph
{
    //............................................................................
    // Create AUGraph
    
    TOThrowOnError(NewAUGraph(&graph));
    
    
    
    //............................................................................
    // Add Audio Units (Nodes) to the graph
    AUNode filePlayerNode, rioNode, reverbNode;
    
    // file player unit
    TOThrowOnError(TOAUGraphAddNode(kAudioUnitType_Generator,
                                    kAudioUnitSubType_AudioFilePlayer,
                                    graph,
                                    &filePlayerNode));
    
    
    // remote IO unit
    TOThrowOnError(TOAUGraphAddNode(kAudioUnitType_Output,
                                    kAudioUnitSubType_RemoteIO,
                                    graph,
                                    &rioNode));
    
    // EQ unit
    TOThrowOnError(TOAUGraphAddNode(kAudioUnitType_Effect,
                                    kAudioUnitSubType_Reverb2,
                                    graph,
                                    &reverbNode));

    
    
    //............................................................................
    // Open the processing graph.
    
    TOThrowOnError(AUGraphOpen(graph));
    
    
    //............................................................................
    // Obtain the audio unit instances from its corresponding node.
    
    TOThrowOnError(AUGraphNodeInfo(graph,
                                   filePlayerNode,
                                   NULL,
                                   &filePlayerUnit));
    
    TOThrowOnError(AUGraphNodeInfo(graph,
                                   reverbNode,
                                   NULL,
                                   &reverbUnit));
    
    TOThrowOnError(AUGraphNodeInfo(graph,
                                   rioNode,
                                   NULL,
                                   &rioUnit));
    
    
    //............................................................................
    // Set properties/parameters of the units inside the graph
    
    
    
    //............................................................................
    // Connect the nodes of the audio processing graph
    
    TOThrowOnError(AUGraphConnectNodeInput(graph,
                                           filePlayerNode,          // source node
                                           0,                       // source bus
                                           reverbNode,              // destination node
                                           0));                     // destination bus
    

    
    TOThrowOnError(AUGraphConnectNodeInput(graph,
                                           reverbNode,
                                           0,
                                           rioNode,
                                           0));
    
    
    
    //............................................................................
    // Initialize Graph
    TOThrowOnError(AUGraphInitialize(graph));
    
    
    
    //............................................................................
    // other audio unit setup
    [self initializePlayerUnit];
    
    CAShow(graph);
}


- (void)initializePlayerUnit
{
    NSURL *songURL = [[NSBundle mainBundle] URLForResource:@"guitarStereo" withExtension:@"caf"];
    TOThrowOnError(AudioFileOpenURL((__bridge CFURLRef)(songURL), kAudioFileReadPermission, 0, &audioFile));
    
    TOThrowOnError(AudioUnitSetProperty(filePlayerUnit,
                                        kAudioUnitProperty_ScheduledFileIDs,
                                        kAudioUnitScope_Global,
                                        0,
                                        &audioFile,
                                        sizeof(audioFile)));
    
    
    
    // get input file format
    AudioStreamBasicDescription audioFileASBD;
    UInt32 propSize = sizeof(audioFileASBD);
    TOThrowOnError(AudioFileGetProperty(audioFile,
                                        kAudioFilePropertyDataFormat,
                                        &propSize,
                                        &audioFileASBD));
    
    
    
	UInt64 nPackets;
	UInt32 propsize = sizeof(nPackets);
	TOThrowOnError(AudioFileGetProperty(audioFile,
                                        kAudioFilePropertyAudioDataPacketCount,
                                        &propsize,
                                        &nPackets));
	
    
	// tell the file player AU to play the entire file
	ScheduledAudioFileRegion rgn;
	memset (&rgn.mTimeStamp, 0, sizeof(rgn.mTimeStamp));
	rgn.mTimeStamp.mFlags = kAudioTimeStampSampleTimeValid;
	rgn.mTimeStamp.mSampleTime = 0;
	rgn.mCompletionProc = NULL;
	rgn.mCompletionProcUserData = NULL;
	rgn.mAudioFile = audioFile;
	rgn.mLoopCount = -1;
	rgn.mStartFrame = 0;
	rgn.mFramesToPlay = nPackets * audioFileASBD.mFramesPerPacket;
	
	TOThrowOnError(AudioUnitSetProperty(filePlayerUnit,
                                        kAudioUnitProperty_ScheduledFileRegion,
                                        kAudioUnitScope_Global,
                                        0,
                                        &rgn,
                                        sizeof(rgn)));
    
	// prime the file player AU with default values
	UInt32 defaultVal = 0;
	TOThrowOnError(AudioUnitSetProperty(filePlayerUnit,
                                        kAudioUnitProperty_ScheduledFilePrime,
                                        kAudioUnitScope_Global,
                                        0,
                                        &defaultVal,
                                        sizeof(defaultVal)));
	
	// tell the file player AU when to start playing (-1 sample time means next render cycle)
	AudioTimeStamp startTime;
	memset (&startTime, 0, sizeof(startTime));
	startTime.mFlags = kAudioTimeStampSampleTimeValid;
	startTime.mSampleTime = -1;
    
	TOThrowOnError(AudioUnitSetProperty(filePlayerUnit,
                                        kAudioUnitProperty_ScheduleStartTimeStamp,
                                        kAudioUnitScope_Global,
                                        0,
                                        &startTime,
                                        sizeof(startTime)));
}



#pragma mark - Reverb Paramter Wrapper Methods

- (AudioUnitParameterValue)dryWetMix
{
    AudioUnitParameterValue dryWetMix;
    
    TOThrowOnError(AudioUnitGetParameter(reverbUnit,
                                         kReverb2Param_DryWetMix,
                                         kAudioUnitScope_Global,
                                         0,
                                         &dryWetMix));
    
    
    return dryWetMix;
}


- (void)setDryWetMix:(AudioUnitParameterValue)dryWetMix
{
    TOThrowOnError(AudioUnitSetParameter(reverbUnit,
                                         kReverb2Param_DryWetMix,
                                         kAudioUnitScope_Global,
                                         0,
                                         dryWetMix,
                                         0));
}


- (AudioUnitParameterValue)gain
{
    AudioUnitParameterValue gain;
    
    TOThrowOnError(AudioUnitGetParameter(reverbUnit,
                                         kReverb2Param_Gain,
                                         kAudioUnitScope_Global,
                                         0,
                                         &gain));
    
    
    return gain;
}


- (void)setGain:(AudioUnitParameterValue)gain
{
    TOThrowOnError(AudioUnitSetParameter(reverbUnit,
                                         kReverb2Param_Gain,
                                         kAudioUnitScope_Global,
                                         0,
                                         gain,
                                         0));
}


- (AudioUnitParameterValue)minDelayTime
{
    AudioUnitParameterValue minDelayTime;
    
    TOThrowOnError(AudioUnitGetParameter(reverbUnit,
                                         kReverb2Param_MinDelayTime,
                                         kAudioUnitScope_Global,
                                         0,
                                         &minDelayTime));
    
    
    return minDelayTime;
}


- (void)setMinDelayTime:(AudioUnitParameterValue)minDelayTime
{
    TOThrowOnError(AudioUnitSetParameter(reverbUnit,
                                         kReverb2Param_MinDelayTime,
                                         kAudioUnitScope_Global,
                                         0,
                                         minDelayTime,
                                         0));
}


- (AudioUnitParameterValue)maxDelayTime
{
    AudioUnitParameterValue maxDelayTime;
    
    TOThrowOnError(AudioUnitGetParameter(reverbUnit,
                                         kReverb2Param_MaxDelayTime,
                                         kAudioUnitScope_Global,
                                         0,
                                         &maxDelayTime));
    
    
    return maxDelayTime;
}


- (void)setMaxDelayTime:(AudioUnitParameterValue)maxDelayTime
{
    TOThrowOnError(AudioUnitSetParameter(reverbUnit,
                                         kReverb2Param_MaxDelayTime,
                                         kAudioUnitScope_Global,
                                         0,
                                         maxDelayTime,
                                         0));
}


- (AudioUnitParameterValue)decayTimeAt0Hz
{
    AudioUnitParameterValue decayTimeAt0Hz;
    
    TOThrowOnError(AudioUnitGetParameter(reverbUnit,
                                         kReverb2Param_DecayTimeAt0Hz,
                                         kAudioUnitScope_Global,
                                         0,
                                         &decayTimeAt0Hz));
    
    
    return decayTimeAt0Hz;
}


- (void)setDecayTimeAt0Hz:(AudioUnitParameterValue)decayTimeAt0Hz
{
    TOThrowOnError(AudioUnitSetParameter(reverbUnit,
                                         kReverb2Param_DecayTimeAt0Hz,
                                         kAudioUnitScope_Global,
                                         0,
                                         decayTimeAt0Hz,
                                         0));
}


- (AudioUnitParameterValue)decayTimeAtNyquist
{
    AudioUnitParameterValue decayTimeAtNyquist;
    
    TOThrowOnError(AudioUnitGetParameter(reverbUnit,
                                         kReverb2Param_DecayTimeAtNyquist,
                                         kAudioUnitScope_Global,
                                         0,
                                         &decayTimeAtNyquist));
    
    
    return decayTimeAtNyquist;
}


- (void)setDecayTimeAtNyquist:(AudioUnitParameterValue)decayTimeAtNyquist
{
    TOThrowOnError(AudioUnitSetParameter(reverbUnit,
                                         kReverb2Param_DecayTimeAtNyquist,
                                         kAudioUnitScope_Global,
                                         0,
                                         decayTimeAtNyquist,
                                         0));
}


- (int)randomizeReflections
{
    AudioUnitParameterValue randomizeReflections;
    
    TOThrowOnError(AudioUnitGetParameter(reverbUnit,
                                         kReverb2Param_RandomizeReflections,
                                         kAudioUnitScope_Global,
                                         0,
                                         &randomizeReflections));
    
    
    return (int)randomizeReflections;
}


- (void)setRandomizeReflections:(int)randomizeReflections
{
    TOThrowOnError(AudioUnitSetParameter(reverbUnit,
                                         kReverb2Param_RandomizeReflections,
                                         kAudioUnitScope_Global,
                                         0,
                                         (AudioUnitParameterValue)randomizeReflections,
                                         0));
}


@end
