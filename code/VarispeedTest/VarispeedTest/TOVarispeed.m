//
//  TOVarispeed.m
//  VarispeedTest
//
//  Created by Tobias Ottenweller on 20.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOVarispeed.h"
#import "TOCAShortcuts.h"


@implementation TOVarispeed

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
    AUNode filePlayerNode, rioNode, varispeedNode;
    
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
    TOThrowOnError(TOAUGraphAddNode(kAudioUnitType_FormatConverter,
                                    kAudioUnitSubType_Varispeed,
                                    graph,
                                    &varispeedNode));

    
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
                                   varispeedNode,
                                   NULL,
                                   &varispeedUnit));
    
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
                                           varispeedNode,           // destination node
                                           0));                     // destination bus

    
    TOThrowOnError(AUGraphConnectNodeInput(graph,
                                           varispeedNode,
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
    NSURL *songURL = [[NSBundle mainBundle] URLForResource:@"song" withExtension:@"m4a"];
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



#pragma mark - Varispeed Unit Parameter Wrapper Methods

- (AudioUnitParameterValue)playbackCents
{
    AudioUnitParameterValue playbackCents;
    TOThrowOnError(AudioUnitGetParameter(varispeedUnit,
                                         kVarispeedParam_PlaybackCents,
                                         kAudioUnitScope_Global,
                                         0,
                                         &playbackCents));
    
    return playbackCents;
}


- (void)setPlaybackCents:(AudioUnitParameterValue)playbackCents
{
    TOThrowOnError(AudioUnitSetParameter(varispeedUnit,
                                         kVarispeedParam_PlaybackCents,
                                         kAudioUnitScope_Global,
                                         0,
                                         playbackCents,
                                         0));
}



- (AudioUnitParameterValue)playbackRate
{
    AudioUnitParameterValue playbackRate;
    TOThrowOnError(AudioUnitGetParameter(varispeedUnit,
                                         kVarispeedParam_PlaybackRate,
                                         kAudioUnitScope_Global,
                                         0,
                                         &playbackRate));
    
    return playbackRate;
}


- (void)setPlaybackRate:(AudioUnitParameterValue)playbackRate
{
    TOThrowOnError(AudioUnitSetParameter(varispeedUnit,
                                         kVarispeedParam_PlaybackRate,
                                         kAudioUnitScope_Global,
                                         0,
                                         playbackRate,
                                         0));
}




@end
