//
//  TOSubgraph.m
//  SubGraphTest
//
//  Created by Tobias Ottenweller on 20.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOSubgraph.h"
#import "TOCAShortcuts.h"


@implementation TOSubgraph

- (id)init
{
    self = [super init];
    
    if (self) {
        [self initializeOutputGraph];
        TOThrowOnError(AUGraphStart(graph));
        
        
        [self performSelector:@selector(addAdditionalNodes) withObject:nil afterDelay:10];
    }
    
    return self;
}


- (void)initializeOutputGraph
{
    //............................................................................
    // Create AUGraph
    
    TOThrowOnError(NewAUGraph(&graph));
    
    
    
    //............................................................................
    // Add Audio Units (Nodes) to the graph
    
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
                                   mixerNode,
                                   NULL,
                                   &mixerUnit));
    
    TOThrowOnError(AUGraphNodeInfo(graph,
                                   rioNode,
                                   NULL,
                                   &rioUnit));
    
    
    //............................................................................
    // Set properties/parameters of the units inside the graph
    
    
    
    //............................................................................
    // Connect the nodes of the audio processing graph
    
    TOThrowOnError(AUGraphConnectNodeInput(graph,
                                           mixerNode,          // source node
                                           0,                  // source bus
                                           rioNode,            // destination node
                                           0));                // destination bus
    
    
    //............................................................................
    // Initialize Graph
    TOThrowOnError(AUGraphInitialize(graph));
    
    
    //............................................................................
    // other audio unit setup
    
    printf("*************** GRAPH ***************\n");
    CAShow(graph);
}


- (void)addAdditionalNodes
{
    //............................................................................
    // Add new Audio Units (Nodes) to the graph
    
    // file player unit
    TOThrowOnError(TOAUGraphAddNode(kAudioUnitType_Generator,
                                    kAudioUnitSubType_AudioFilePlayer,
                                    graph,
                                    &filePlayerNode));
    
    // varispeed unit
    TOThrowOnError(TOAUGraphAddNode(kAudioUnitType_FormatConverter,
                                    kAudioUnitSubType_Varispeed,
                                    graph,
                                    &varispeedNode));
    
    
    
    //............................................................................
    // Obtain the new audio unit instances from its corresponding node.
    
    TOThrowOnError(AUGraphNodeInfo(graph,
                                   filePlayerNode,
                                   NULL,
                                   &filePlayerUnit));
    
    TOThrowOnError(AUGraphNodeInfo(graph,
                                   varispeedNode,
                                   NULL,
                                   &varispeedUnit));
    
    
    
    //............................................................................
    // Connect the nodes of the audio processing graph
    
    TOThrowOnError(AUGraphConnectNodeInput(graph,
                                           filePlayerNode,     // source node
                                           0,                  // source bus
                                           varispeedNode,      // destination node
                                           0));                // destination bus
    
    TOThrowOnError(AUGraphConnectNodeInput(graph,
                                           varispeedNode,
                                           0,
                                           mixerNode,
                                           0));
    
    
    
    //............................................................................
    // update the graph
    TOThrowOnError(AUGraphUpdate(graph, NULL));
    
    
    //............................................................................
    // file player unit setup
    [self initializePlayerUnit];
    
    
    printf("*************** GRAPH ***************\n");
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


@end
