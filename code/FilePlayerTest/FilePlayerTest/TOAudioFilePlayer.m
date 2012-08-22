//
//  TOAudioFilePlayer.m
//  FilePlayerTest
//
//  Created by Tobias Ottenweller on 21.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOAudioFilePlayer.h"
#import "TOCAShortcuts.h"

#include <mach/mach_time.h>

@implementation TOAudioFilePlayer

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
                                   rioNode,
                                   NULL,
                                   &rioUnit));
    
    
    //............................................................................
    // Connect the nodes of the audio processing graph
    // file player -> converter -> EQ -> mixer -> rio
    
    TOThrowOnError(AUGraphConnectNodeInput(graph,
                                           filePlayerNode,      // source node
                                           0,                   // source bus
                                           rioNode,             // destination node
                                           0));                 // destination bus
    

    
    
    //............................................................................
    // Set properties/parameters of the units inside the graph
    
    
    //............................................................................
    // Initialize Graph
    TOThrowOnError(AUGraphInitialize(graph));
}


- (BOOL)applyChanges:(NSError *__autoreleasing *)error
{
    //............................................................................
    // audio file setup
    if (audioFile) {
        TOThrowOnError(AudioFileClose(audioFile));
    }
    
    NSError *intError = nil;

    TOErrorHandler(AudioFileOpenURL((__bridge CFURLRef)(self.audioFileURL),
                                    kAudioFileReadPermission,
                                    0,
                                    &audioFile),
                    &intError,
                    @"Failed to open audio file");
    
    if (intError) {
        if (error) {
            *error = intError;
        }
        
        return NO;
    }
    
    
    
    //............................................................................
    // get audio file properties
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
    
    
    
    //............................................................................
    // calculate file player unit properties
    
    // region
    SInt64 startFrame;
    double currentTime = 0; // TODO: ask the document for the time
    UInt32 framesToPlay;
    UInt32 numFramesInFile = nPackets * audioFileASBD.mFramesPerPacket;
    
    
    if (currentTime < self.startTime) {
        startFrame = self.regionStart * audioFileASBD.mSampleRate;
        framesToPlay = self.regionDuration * audioFileASBD.mSampleRate;
    }
    else {
        startFrame = currentTime * audioFileASBD.mSampleRate;
        framesToPlay = (self.regionDuration - (currentTime - self.startTime)) * audioFileASBD.mSampleRate;
    }
    
    
    // avoid playing over the end of the actual file
    if ((startFrame + framesToPlay) > numFramesInFile) {
        framesToPlay -= numFramesInFile - startFrame - framesToPlay;
    }
    
    
    ScheduledAudioFileRegion rgn;
	memset (&rgn.mTimeStamp, 0, sizeof(rgn.mTimeStamp));
	rgn.mTimeStamp.mFlags = kAudioTimeStampSampleTimeValid;
	rgn.mTimeStamp.mSampleTime = 0;
	rgn.mCompletionProc = NULL;
	rgn.mCompletionProcUserData = NULL;
	rgn.mAudioFile = audioFile;
	rgn.mLoopCount = self.loopCount;
	rgn.mStartFrame = startFrame;
	rgn.mFramesToPlay = framesToPlay;
    
    
    // start time
    Float64 currentGraphSampleTime = 0; // TODO: ask the document for the time
    Float64 graphSampleRate = 44100; // TODO: ask the document for the sample rate
    
    Float64 sampleStartTime = (startFrame / audioFileASBD.mSampleRate + currentGraphSampleTime) * graphSampleRate;
    
    AudioTimeStamp startTime;
	memset (&startTime, 0, sizeof(startTime));
	startTime.mFlags = kAudioTimeStampSampleTimeValid;
	startTime.mSampleTime = sampleStartTime;
    
    
    
    //............................................................................
    // set the file player properties
    TOThrowOnError(AudioUnitSetProperty(filePlayerUnit,
                                        kAudioUnitProperty_ScheduledFileIDs,
                                        kAudioUnitScope_Global,
                                        0,
                                        &audioFile,
                                        sizeof(audioFile)));
	
    
	
	
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
	
    
	TOThrowOnError(AudioUnitSetProperty(filePlayerUnit,
                                        kAudioUnitProperty_ScheduleStartTimeStamp,
                                        kAudioUnitScope_Global,
                                        0,
                                        &startTime,
                                        sizeof(startTime)));

    return YES;
}


@end
