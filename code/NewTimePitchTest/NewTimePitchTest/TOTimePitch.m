//
//  TOPitch.m
//  PitchTest
//
//  Created by Tobias Ottenweller on 20.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOTimePitch.h"
#import "TOCAShortcuts.h"


#define USE_CONVERTER 1
#define USE_SILENT_AUDIO_FILE 0


@implementation TOTimePitch


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
    AUNode filePlayerNode, pitchNode, rioNode;
    
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
    
    // time pitch  unit
    TOThrowOnError(TOAUGraphAddNode(kAudioUnitType_FormatConverter,
                                    kAudioUnitSubType_NewTimePitch,
                                    graph,
                                    &pitchNode));
    
#if USE_CONVERTER
    AUNode filePlayerPitchConverterNode, pitchRioConverterNode;
    
    // file to eq converter unit
    TOThrowOnError(TOAUGraphAddNode(kAudioUnitType_FormatConverter,
                                    kAudioUnitSubType_AUConverter,
                                    graph,
                                    &filePlayerPitchConverterNode));
    
    // eq to rio converter unit
    TOThrowOnError(TOAUGraphAddNode(kAudioUnitType_FormatConverter,
                                    kAudioUnitSubType_AUConverter,
                                    graph,
                                    &pitchRioConverterNode));
#endif
    
    
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
                                   pitchNode,
                                   NULL,
                                   &pitchUnit));
    
    TOThrowOnError(AUGraphNodeInfo(graph,
                                   rioNode,
                                   NULL,
                                   &rioUnit));

#if USE_CONVERTER
    TOThrowOnError(AUGraphNodeInfo(graph,
                                   filePlayerPitchConverterNode,
                                   NULL,
                                   &filePlayerPitchConverterUnit));
    
    TOThrowOnError(AUGraphNodeInfo(graph,
                                   pitchRioConverterNode,
                                   NULL,
                                   &pitchRioConverterUnit));
#endif
    
    
    //............................................................................
    // Set properties/parameters of the units inside the graph
    
#if USE_CONVERTER

    AudioStreamBasicDescription filePlayerFormat;
    UInt32 propSize = sizeof(filePlayerFormat);
    
    TOThrowOnError(AudioUnitGetProperty(filePlayerUnit,
                                        kAudioUnitProperty_StreamFormat,
                                        kAudioUnitScope_Output,
                                        0,
                                        &filePlayerFormat,
                                        &propSize));
    
    
    AudioStreamBasicDescription effectFormat;
    propSize = sizeof(effectFormat);

    TOThrowOnError(AudioUnitGetProperty(pitchUnit,
                                        kAudioUnitProperty_StreamFormat,
                                        kAudioUnitScope_Input,
                                        0,
                                        &effectFormat,
                                        &propSize));
    
    AudioStreamBasicDescription rioFormat = TOCanonicalAUGraphStreamFormat(2, false);
    propSize = sizeof(rioFormat);
    
    
    TOPrintASBD(filePlayerFormat);
    printf("\n**************************************\n\n");
    TOPrintASBD(effectFormat);
    printf("\n**************************************\n\n");
    TOPrintASBD(rioFormat);
    
    
    
    TOThrowOnError(AudioUnitSetProperty(filePlayerPitchConverterUnit,
                                        kAudioUnitProperty_StreamFormat,
                                        kAudioUnitScope_Input,
                                        0,
                                        &filePlayerFormat,
                                        sizeof(filePlayerFormat)));


    TOThrowOnError(AudioUnitSetProperty(filePlayerPitchConverterUnit,
                                        kAudioUnitProperty_StreamFormat,
                                        kAudioUnitScope_Output,
                                        0,
                                        &effectFormat,
                                        sizeof(effectFormat)));

    
    TOThrowOnError(AudioUnitSetProperty(pitchRioConverterUnit,
                                        kAudioUnitProperty_StreamFormat,
                                        kAudioUnitScope_Input,
                                        0,
                                        &effectFormat,
                                        sizeof(effectFormat)));


    TOThrowOnError(AudioUnitSetProperty(pitchRioConverterUnit,
                                        kAudioUnitProperty_StreamFormat,
                                        kAudioUnitScope_Output,
                                        0,
                                        &rioFormat,
                                        sizeof(rioFormat)));
    
    TOThrowOnError(AudioUnitSetProperty(rioUnit,
                                        kAudioUnitProperty_StreamFormat,
                                        kAudioUnitScope_Input,
                                        0,
                                        &rioFormat,
                                        sizeof(rioFormat)));
    
#endif

    
    
    
    //............................................................................
    // Connect the nodes of the audio processing graph

#if USE_CONVERTER
    TOThrowOnError(AUGraphConnectNodeInput(graph,
                                           filePlayerNode,                  // source node
                                           0,                               // source bus
                                           filePlayerPitchConverterNode,    // destination node
                                           0));                             // destination bus
    
    TOThrowOnError(AUGraphConnectNodeInput(graph,
                                           filePlayerPitchConverterNode,
                                           0,
                                           pitchNode,
                                           0));
    
    TOThrowOnError(AUGraphConnectNodeInput(graph,
                                           pitchNode,
                                           0,
                                           pitchRioConverterNode,
                                           0));
    
    TOThrowOnError(AUGraphConnectNodeInput(graph,
                                           pitchRioConverterNode,
                                           0,
                                           rioNode,
                                           0));
    
#else
    
    TOThrowOnError(AUGraphConnectNodeInput(graph,
                                           filePlayerNode,                  // source node
                                           0,                               // source bus
                                           pitchNode,                       // destination node
                                           0));                             // destination bus
    
    TOThrowOnError(AUGraphConnectNodeInput(graph,
                                           pitchNode,
                                           0,
                                           rioNode,
                                           0));
#endif
    
    
    
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
#if USE_SILENT_AUDIO_FILE
    NSURL *songURL = [[NSBundle mainBundle] URLForResource:@"guitarStereo_silent" withExtension:@"caf"];
#else
    NSURL *songURL = [[NSBundle mainBundle] URLForResource:@"guitarStereo" withExtension:@"caf"];
#endif
    
    
    
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



# pragma mark - Time Pitch wrapper methods

- (void)setPitchRate:(AudioUnitParameterValue)pitchRate
{
    TOThrowOnError(AudioUnitSetParameter(pitchUnit,
                                         kTimePitchParam_Rate,
                                         kAudioUnitScope_Global,
                                         0,
                                         pitchRate,
                                         0));
}


- (AudioUnitParameterValue)pitchRate
{
    AudioUnitParameterValue pitchRate;
    
    TOThrowOnError(AudioUnitGetParameter(pitchUnit,
                                         kTimePitchParam_Rate,
                                         kAudioUnitScope_Global,
                                         0,
                                         &pitchRate));
    
    return pitchRate;
}


@end
