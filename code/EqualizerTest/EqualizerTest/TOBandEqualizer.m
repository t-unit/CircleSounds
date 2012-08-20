//
//  TOBandEqualizer.m
//  EqualizerTest
//
//  Created by Tobias Ottenweller on 17.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOBandEqualizer.h"
#import "TOCAShortcuts.h"


@implementation TOBandEqualizer


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
    AUNode filePlayerNode, rioNode, eqNode, file2eqConverterNode, eq2rioConverterNode;
    
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
                                    kAudioUnitSubType_NBandEQ,
                                    graph,
                                    &eqNode));
    
    // file to eq converter unit
//    TOThrowOnError(TOAUGraphAddNode(kAudioUnitType_FormatConverter,
//                                    kAudioUnitSubType_AUConverter,
//                                    graph,
//                                    &file2eqConverterNode));
    
    // eq to rio converter unit
    TOThrowOnError(TOAUGraphAddNode(kAudioUnitType_FormatConverter,
                                    kAudioUnitSubType_AUConverter,
                                    graph,
                                    &eq2rioConverterNode));
    
    
    
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
                                   eqNode,
                                   NULL,
                                   &equalizerUnit));
    
    TOThrowOnError(AUGraphNodeInfo(graph,
                                   rioNode,
                                   NULL,
                                   &rioUnit));
    
//    TOThrowOnError(AUGraphNodeInfo(graph,
//                                   file2eqConverterNode,
//                                   NULL,
//                                   &file2eqConverterUnit));
    
    TOThrowOnError(AUGraphNodeInfo(graph,
                                   eq2rioConverterNode,
                                   NULL,
                                   &eq2rioConverterUnit));
    
    
    //............................................................................
    // Set properties/parameters of the units inside the graph

    // Set number of bands for the EQ unit
    // Set the frequencies for each band of the EQ unit
    NSArray *eqFrequencies = @[ @32, @64, @125, @250, @500, @1000, @2000, @4000, @8000, @16000 ];
    self.numBands = eqFrequencies.count;
    self.bands = eqFrequencies;
    
    
    
    AudioStreamBasicDescription filePlayerFormat;
    UInt32 propSize = sizeof(filePlayerFormat);
    
    TOThrowOnError(AudioUnitGetProperty(filePlayerUnit,
                                        kAudioUnitProperty_StreamFormat,
                                        kAudioUnitScope_Output,
                                        0,
                                        &filePlayerFormat,
                                        &propSize));
    
    
//    AudioStreamBasicDescription effectFormat;
//    propSize = sizeof(effectFormat);
//    
//    TOThrowOnError(AudioUnitGetProperty(equalizerUnit,
//                                        kAudioUnitProperty_StreamFormat,
//                                        kAudioUnitScope_Input,
//                                        0,
//                                        &effectFormat,
//                                        &propSize));
    
    AudioStreamBasicDescription rioFormat = TOCanonicalAUGraphStreamFormat(2, false);
//    propSize = sizeof(rioFormat);
//    
//    TOThrowOnError(AudioUnitGetProperty(rioUnit,
//                                        kAudioUnitProperty_StreamFormat,
//                                        kAudioUnitScope_Input,
//                                        1,
//                                        &rioFormat,
//                                        &propSize));
    
    
    
    TOPrintASBD(filePlayerFormat);
    printf("\n**************************************\n\n");
//    TOPrintASBD(effectFormat);
    printf("\n**************************************\n\n");
    TOPrintASBD(rioFormat);

    
    
//    TOThrowOnError(AudioUnitSetProperty(file2eqConverterUnit,
//                                        kAudioUnitProperty_StreamFormat,
//                                        kAudioUnitScope_Input,
//                                        0,
//                                        &filePlayerFormat,
//                                        sizeof(filePlayerFormat)));
//    
//    
//    TOThrowOnError(AudioUnitSetProperty(file2eqConverterUnit,
//                                        kAudioUnitProperty_StreamFormat,
//                                        kAudioUnitScope_Output,
//                                        0,
//                                        &effectFormat,
//                                        sizeof(effectFormat)));
    
    
    TOThrowOnError(AudioUnitSetProperty(equalizerUnit,
                                        kAudioUnitProperty_StreamFormat,
                                        kAudioUnitScope_Input,
                                        0,
                                        &filePlayerFormat,
                                        sizeof(filePlayerFormat)));
//
//    
//    TOThrowOnError(AudioUnitSetProperty(equalizerUnit,
//                                        kAudioUnitProperty_StreamFormat,
//                                        kAudioUnitScope_Output,
//                                        0,
//                                        &rioFormat,
//                                        sizeof(rioFormat)));
    
    
    TOThrowOnError(AudioUnitSetProperty(eq2rioConverterUnit,
                                        kAudioUnitProperty_StreamFormat,
                                        kAudioUnitScope_Input,
                                        0,
                                        &filePlayerFormat,
                                        sizeof(filePlayerFormat)));
    
    
    TOThrowOnError(AudioUnitSetProperty(eq2rioConverterUnit,
                                        kAudioUnitProperty_StreamFormat,
                                        kAudioUnitScope_Output,
                                        0,
                                        &rioFormat,
                                        sizeof(rioFormat)));
    
    
//    TOThrowOnError(AudioUnitSetProperty(rioUnit,
//                                        kAudioUnitProperty_StreamFormat,
//                                        kAudioUnitScope_Input,
//                                        1,
//                                        &filePlayerFormat,
//                                        sizeof(filePlayerFormat)));
    
    
    
    //............................................................................
    // Connect the nodes of the audio processing graph
    
    TOThrowOnError(AUGraphConnectNodeInput(graph,
                                           filePlayerNode,          // source node
                                           0,                       // source bus
                                           eqNode,    // destination node
                                           0));                     // destination bus
    
//    TOThrowOnError(AUGraphConnectNodeInput(graph,
//                                           file2eqConverterNode,
//                                           0,
//                                           eqNode,
//                                           0));
    
    TOThrowOnError(AUGraphConnectNodeInput(graph,
                                           eqNode,
                                           0,
                                           eq2rioConverterNode,
                                           0));
    
    TOThrowOnError(AUGraphConnectNodeInput(graph,
                                           eq2rioConverterNode,
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



# pragma mark - EQ wrapper methods

- (UInt32)maxNumberOfBands
{
    UInt32 maxNumBands = 0;
    UInt32 propSize = sizeof(maxNumBands);
    TOThrowOnError(AudioUnitGetProperty(equalizerUnit,
                                        kAUNBandEQProperty_MaxNumberOfBands,
                                        kAudioUnitScope_Global,
                                        0,
                                        &maxNumBands,
                                        &propSize));
    
    return maxNumBands;
}


- (UInt32)numBands
{
    UInt32 numBands;
    UInt32 propSize = sizeof(numBands);
    TOThrowOnError(AudioUnitGetProperty(equalizerUnit,
                                        kAUNBandEQProperty_NumberOfBands,
                                        kAudioUnitScope_Global,
                                        0,
                                        &numBands,
                                        &propSize));
    
    return numBands;
}


- (void)setNumBands:(UInt32)numBands
{
    TOThrowOnError(AudioUnitSetProperty(equalizerUnit,
                                        kAUNBandEQProperty_NumberOfBands,
                                        kAudioUnitScope_Global,
                                        0,
                                        &numBands,
                                        sizeof(numBands)));
}


- (void)setBands:(NSArray *)bands
{
    _bands = bands;
    
    for (NSUInteger i=0; i<bands.count; i++) {
        TOThrowOnError(AudioUnitSetParameter(equalizerUnit,
                                             kAUNBandEQParam_Frequency+i,
                                             kAudioUnitScope_Global,
                                             0,
                                             (AudioUnitParameterValue)[[bands objectAtIndex:i] floatValue],
                                             0));
        
        
        // setting the bypassBand paramter does work!
//        TOThrowOnError(AudioUnitSetParameter(equalizerUnit,
//                                             kAUNBandEQParam_BypassBand+i,
//                                             kAudioUnitScope_Global,
//                                             0,
//                                             1,
//                                             0));
//        
        TOThrowOnError(AudioUnitSetParameter(equalizerUnit,
                                             kAUNBandEQParam_FilterType+i,
                                             kAudioUnitScope_Global,
                                             0,
                                             kAUNBandEQFilterType_Parametric,
                                             0));
//
//        TOThrowOnError(AudioUnitSetParameter(equalizerUnit,
//                                             kAUNBandEQParam_Bandwidth+i,
//                                             kAudioUnitScope_Global,
//                                             0,
//                                             5.0,
//                                             0));
    }
}


- (AudioUnitParameterValue)gainForBandAtPosition:(NSUInteger)bandPosition
{
    AudioUnitParameterValue gain;
    AudioUnitParameterID parameterID = kAUNBandEQParam_Gain + bandPosition;
    
    TOThrowOnError(AudioUnitGetParameter(equalizerUnit,
                                         parameterID,
                                         kAudioUnitScope_Global,
                                         0,
                                         &gain));
    
    return gain;
}


- (void)setGain:(AudioUnitParameterValue)gain forBandAtPosition:(NSUInteger)bandPosition
{
    AudioUnitParameterID parameterID = kAUNBandEQParam_Gain + bandPosition;
    
    TOThrowOnError(AudioUnitSetParameter(equalizerUnit,
                                         parameterID,
                                         kAudioUnitScope_Global,
                                         0,
                                         gain,
                                         0));
}


@end
