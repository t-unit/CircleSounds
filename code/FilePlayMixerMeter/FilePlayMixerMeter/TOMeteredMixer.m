//
//  TOMeteredMixer.m
//  FilePlayMixerMeter
//
//  Created by Tobias Ottenweller on 15.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOMeteredMixer.h"

#import <AudioToolbox/AudioToolbox.h>
#import "TOCAShortcuts.h"

@interface TOMeteredMixer ()

- (void)initializePlayerUnit;

@end


@implementation TOMeteredMixer

#pragma mark - C function callbacks

void AudioFileCompletionCallback(void *userData, ScheduledAudioFileRegion *fileRegion, OSStatus result)
{    
    TOMeteredMixer *mixer = (__bridge TOMeteredMixer *)userData;
    
    // changes some properties of th file palyer unit will also cause
    // calling this function. just return without doing anything while
    // reseting the file player unit.
    if (mixer->unitsGettingReset) {
        return;
    }
    
    mixer->unitsGettingReset = YES;
    
    // setting properties inside the units own callback does not work
    // just add a block to the main queue doing the changes.
    dispatch_async(dispatch_get_main_queue(), ^{
        [mixer initializePlayerUnit];
        mixer->unitsGettingReset = NO;
    });
}

#pragma mark - setup

- (id)init
{
    self = [super init];
    
    if (self) {
        // following lines are here for testing and should be removed later on!
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
    
    AUNode rioNode, mixerNode, filePlayerNode;
    
    // file player unit
    TOThrowOnError(TOAUGraphAddNode(kAudioUnitType_Generator,
                                    kAudioUnitSubType_AudioFilePlayer,
                                    graph,
                                    &filePlayerNode));
    
    // mixer unit
    TOThrowOnError(TOAUGraphAddNode(kAudioUnitType_Mixer,
                                    kAudioUnitSubType_MultiChannelMixer,
                                    graph,
                                    &mixerNode));
    
    // remote IO unit
    TOThrowOnError(TOAUGraphAddNode(kAudioUnitType_Output,
                                    kAudioUnitSubType_RemoteIO,
                                    graph,
                                    &rioNode));
    
    
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
                                   mixerNode,
                                   NULL,
                                   &mixerUnit));
    
    TOThrowOnError(AUGraphNodeInfo(graph,
                                   rioNode,
                                   NULL,
                                   &rioUnit));
    
    
    //............................................................................
    // Connect the nodes of the audio processing graph
    // file player -> converter -> EQ -> mixer -> rio
    
    TOThrowOnError(AUGraphConnectNodeInput(graph,
                                           filePlayerNode,     // source node
                                           0,                   // source bus
                                           mixerNode,          // destination node
                                           0));                 // destination bus
    
    TOThrowOnError(AUGraphConnectNodeInput(graph,
                                           mixerNode,
                                           0,
                                           rioNode,
                                           0));

    
    //............................................................................
    // Set properties/parameters of the units inside the graph
    
    // Enable metering at the output of the mixer unit
    UInt32 meteringMode = 1; // enabled
    TOThrowOnError(AudioUnitSetProperty(mixerUnit,
                                        kAudioUnitProperty_MeteringMode,
                                        kAudioUnitScope_Output,
                                        0,
                                        &meteringMode,
                                        sizeof(meteringMode)));
    
    
    //............................................................................
    // Initialize Graph
    TOThrowOnError(AUGraphInitialize(graph));
    
    
    
    //............................................................................
    // other audio unit setup
    [self initializePlayerUnit];
}


- (void)initializePlayerUnit
{
    // init audioFile
    if (audioFile) {
        TOThrowOnError(AudioFileClose(audioFile));
    }
    
    
    NSURL *nyanURL = [[NSBundle mainBundle] URLForResource:@"nyan" withExtension:@"m4a"];
    TOThrowOnError(AudioFileOpenURL((__bridge CFURLRef)(nyanURL), kAudioFileReadPermission, 0, &audioFile));
    
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
	rgn.mCompletionProc = AudioFileCompletionCallback;
	rgn.mCompletionProcUserData = (__bridge void *)(self);
	rgn.mAudioFile = audioFile;
	rgn.mLoopCount = 0;
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


# pragma mark - Mixer Parameters

- (AudioUnitParameterValue)avgValueLeft
{
    AudioUnitParameterValue retVal;
    
    TOThrowOnError(AudioUnitGetParameter(mixerUnit,
                                         kMultiChannelMixerParam_PostAveragePower,
                                         kAudioUnitScope_Output,
                                         0,
                                         &retVal));
    
    return retVal;
}


- (AudioUnitParameterValue)avgValueRight
{
    AudioUnitParameterValue retVal;
    
    TOThrowOnError(AudioUnitGetParameter(mixerUnit,
                                         kMultiChannelMixerParam_PostAveragePower+1,
                                         kAudioUnitScope_Output,
                                         0,
                                         &retVal));
    
    return retVal;
}


- (AudioUnitParameterValue)peakValueLeft
{
    AudioUnitParameterValue retVal;
    
    TOThrowOnError(AudioUnitGetParameter(mixerUnit,
                                         kMultiChannelMixerParam_PostPeakHoldLevel,
                                         kAudioUnitScope_Output,
                                         0,
                                         &retVal));
    
    return retVal;
}


- (AudioUnitParameterValue)peakValueRight
{
    AudioUnitParameterValue retVal;
    
    TOThrowOnError(AudioUnitGetParameter(mixerUnit,
                                         kMultiChannelMixerParam_PostPeakHoldLevel+1,
                                         kAudioUnitScope_Output,
                                         0,
                                         &retVal));
    
    return retVal;
}


- (void)setVolume:(AudioUnitParameterValue)volume
{
    TOThrowOnError(AudioUnitSetParameter(mixerUnit,
                                         kMultiChannelMixerParam_Volume,
                                         kAudioUnitScope_Output,
                                         0,
                                         volume,
                                         0));
}


- (AudioUnitParameterValue)volume
{
    AudioUnitParameterValue retVal;
    
    TOThrowOnError(AudioUnitGetParameter(mixerUnit,
                                         kMultiChannelMixerParam_Volume,
                                         kAudioUnitScope_Output,
                                         0,
                                         &retVal));
    
    return retVal;
}


@end
