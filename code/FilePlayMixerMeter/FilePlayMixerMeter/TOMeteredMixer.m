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
{
    AUGraph _graph;
    
    
    AudioUnit _converterUnit;
    AUNode _converterNode;
    
    
    AudioUnit _rioUnit;
    AUNode _rioNode;
    
    
    AudioUnit _mixerUnit;
    AUNode _mixerNode;
    
    
    AudioUnit _filePlayerUnit;
    AUNode _filePlayerNode;
    
    AudioFileID _audioFile;
    
    
    AUNode _eqNode;
    
    NSArray *_eqFrequencies;
    
    
    BOOL _unitsGettingReset;
}

- (void)setUpFilePlayerUnit;
- (void)setUp;

@end


@implementation TOMeteredMixer

#pragma mark - C function callbacks

void AudioFileCompletionCallback(void *userData, ScheduledAudioFileRegion *fileRegion, OSStatus result)
{    
    TOMeteredMixer *mixer = (__bridge TOMeteredMixer *)userData;
    
    // changes some properties of th file palyer unit will also cause
    // calling this function. just return without doing anything while
    // reseting the file player unit.
    if (mixer->_unitsGettingReset) {
        return;
    }
    
    mixer->_unitsGettingReset = YES;
    
    // setting properties inside the units own callback does not work
    // just add a block to the main queue doing the changes.
    dispatch_async(dispatch_get_main_queue(), ^{
        [mixer setUpFilePlayerUnit];
        mixer->_unitsGettingReset = NO;
    });
}

#pragma mark - setup

- (id)init
{
    self = [super init];
    
    if (self) {
        // following lines are here for testing and should be removed later on!
        [self setUp];
        TOThrowOnError(AUGraphStart(_graph));
    }
    
    return self;
}


//- (void)initializeAUGraph
//{
//    printf("initializeAUGraph\n");
//    
//    AUNode outputNode;
//    AUNode eqNode;
//    AUNode mixerNode;
//    AUNode converterNode;
//    
//    
//    
//    // client format audio goes into the mixer
//    _clientASBD = TOCanonicalStreamFormat(2, false);
//    
//    // output format
//    _outputASBD = TOCanonicalAUGraphStreamFormat(2, false);
//
//    
//
//    
//    
//    // create a new AUGraph
//    TOThrowOnError(NewAUGraph(&_graph));
//    
//    // output unit
//    AudioComponentDescription output_desc = TOAudioComponentDescription(kAudioUnitType_Output, kAudioUnitSubType_RemoteIO);
//    
//    // Effect unit
//    AudioComponentDescription eq_desc = TOAudioComponentDescription(kAudioUnitType_Effect, kAudioUnitSubType_NBandEQ);
//    
//    // multichannel mixer unit
//    AudioComponentDescription mixer_desc = TOAudioComponentDescription(kAudioUnitType_Mixer, kAudioUnitSubType_MultiChannelMixer);
//    
//    // converter mixer unit
//    AudioComponentDescription converter_desc = TOAudioComponentDescription(kAudioUnitType_FormatConverter, kAudioUnitSubType_AUConverter);
//    
//    
//    
//    
//    
//    
//    // create a node in the graph that is an AudioUnit, using the supplied AudioComponentDescription to find and open that unit
//    TOThrowOnError(AUGraphAddNode(_graph, &output_desc, &outputNode));
//
//    TOThrowOnError(AUGraphAddNode(_graph, &eq_desc, &eqNode));
//    
//    TOThrowOnError(AUGraphAddNode(_graph, &mixer_desc, &mixerNode));
//
//    TOThrowOnError(AUGraphAddNode(_graph, &converter_desc, &converterNode));
//
//    
//    
//    
//    
//    
//    // connect a node's output to a node's input
//    // input -> mixer -> converter -> eq -> output
//    TOThrowOnError(AUGraphConnectNodeInput(_graph, mixerNode, 0, converterNode, 0));
//    
//    TOThrowOnError(AUGraphConnectNodeInput(_graph, converterNode, 0, eqNode, 0));
//    
//    TOThrowOnError(AUGraphConnectNodeInput(_graph, eqNode, 0, outputNode, 0));
//    
//    
//    
//    // open the graph AudioUnits are open but not initialized (no resource allocation occurs here)
//    TOThrowOnError(AUGraphOpen(_graph));
//
//    
//    
//    
//    
//    
//    // grab the audio unit instances from the nodes
//    TOThrowOnError(AUGraphNodeInfo(_graph, mixerNode, NULL, &_mixerUnit));
//    
//    TOThrowOnError(AUGraphNodeInfo(_graph, eqNode, NULL, &equalizerUnit));
//    
//    TOThrowOnError(AUGraphNodeInfo(_graph, converterNode, NULL, &_convertUnit));
//    
//    
//    
//    
//    
//    
//    
//    // set bus count
//    UInt32 numbuses = 2;
//    
//    printf("set input bus count %lu\n", numbuses);
//    
//    result = AudioUnitSetProperty(mMixer, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &numbuses, sizeof(numbuses));
//    if (result) { printf("AudioUnitSetProperty result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
//    
//    for (int i = 0; i < numbuses; ++i) {
//        // setup render callback struct
//        AURenderCallbackStruct rcbs;
//        rcbs.inputProc = &renderInput;
//        rcbs.inputProcRefCon = &mUserData;
//        
//        printf("set AUGraphSetNodeInputCallback\n");
//        
//        // set a callback for the specified node's specified input
//        result = AUGraphSetNodeInputCallback(_graph, mixerNode, i, &rcbs);
//        if (result) { printf("AUGraphSetNodeInputCallback result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
//        
//        printf("set input bus %d, client kAudioUnitProperty_StreamFormat\n", i);
//        
//        // set the input stream format, this is the format of the audio for mixer input
//        result = AudioUnitSetProperty(mMixer, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, i, &mClientFormat, sizeof(mClientFormat));
//        if (result) { printf("AudioUnitSetProperty result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
//    }
//    
//    printf("set output kAudioUnitProperty_StreamFormat\n");
//    
//    // set the output stream format of the mixer
//    result = AudioUnitSetProperty(mMixer, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &mOutputFormat, sizeof(mOutputFormat));
//    if (result) { printf("AudioUnitSetProperty result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
//    
//    // set the output stream format of the converter
//    result = AudioUnitSetProperty(mConverter, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &mOutputFormat, sizeof(mOutputFormat));
//    if (result) { printf("AudioUnitSetProperty result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
//    
//    
//    /* ---- Get the format of the input bus of the effect unit --- this is the important bit */
//    CAStreamBasicDescription effectUnitInputFormat;
//    UInt32 propSize = sizeof(CAStreamBasicDescription);
//    memset(&effectUnitInputFormat, 0, propSize);
//    result = AudioUnitGetProperty(mEQ, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &effectUnitInputFormat, &propSize);
//    effectUnitInputFormat.Print();
//    
//    result = AudioUnitSetProperty(mConverter, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &effectUnitInputFormat, sizeof(effectUnitInputFormat));
//    if (result) { printf("AudioUnitSetProperty result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
//    
//    printf("set render notification\n");
//    
//    // add a render notification, this is a callback that the graph will call every time the graph renders
//    // the callback will be called once before the graph’s render operation, and once after the render operation is complete
//    result = AUGraphAddRenderNotify(_graph, renderNotification, &mUserData);
//    if (result) { printf("AUGraphAddRenderNotify result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
//    
//    printf("AUGraphInitialize\n");
//    
//    // now that we've set everything up we can initialize the graph, this will also validate the connections
//    result = AUGraphInitialize(_graph);
//    if (result) { printf("AUGraphInitialize result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
//    
//    CAShow(_graph);
//}



- (void)setUp
{
    //............................................................................
    // Create AUGraph
    
    TOThrowOnError(NewAUGraph(&_graph));
    
    
    
    //............................................................................
    // Add Audio Units to the graph
    
    // file player unit
    TOThrowOnError(TOAUGraphAddNode(kAudioUnitType_Generator,
                                    kAudioUnitSubType_AudioFilePlayer,
                                    _graph,
                                    &_filePlayerNode));
    
    // mixer unit
    TOThrowOnError(TOAUGraphAddNode(kAudioUnitType_Mixer,
                                    kAudioUnitSubType_MultiChannelMixer,
                                    _graph,
                                    &_mixerNode));
    
    // remote IO unit
    TOThrowOnError(TOAUGraphAddNode(kAudioUnitType_Output,
                                    kAudioUnitSubType_RemoteIO,
                                    _graph,
                                    &_rioNode));
    
    // EQ unit
    TOThrowOnError(TOAUGraphAddNode(kAudioUnitType_Effect,
                                    kAudioUnitSubType_NBandEQ,
                                    _graph,
                                    &_eqNode));
    
    // converter unit
    TOThrowOnError(TOAUGraphAddNode(kAudioUnitType_FormatConverter,
                                    kAudioUnitSubType_AUConverter,
                                    _graph,
                                    &_converterNode));
    
    
    //............................................................................
    // Open the processing graph.
    
    TOThrowOnError(AUGraphOpen(_graph));
    
    
    //............................................................................
    // Obtain the audio unit instances from its corresponding node.
    
    TOThrowOnError(AUGraphNodeInfo(_graph,
                                   _filePlayerNode,
                                   NULL,
                                   &_filePlayerUnit));
    
    TOThrowOnError(AUGraphNodeInfo(_graph,
                                   _mixerNode,
                                   NULL,
                                   &_mixerUnit));
    
    TOThrowOnError(AUGraphNodeInfo(_graph,
                                   _rioNode,
                                   NULL,
                                   &_rioUnit));
    
    TOThrowOnError(AUGraphNodeInfo(_graph,
                                   _eqNode,
                                   NULL,
                                   &equalizerUnit));
    
    TOThrowOnError(AUGraphNodeInfo(_graph,
                                   _converterNode,
                                   NULL,
                                   &_converterUnit));
    
    
    
    
    //............................................................................
    // Connect the nodes of the audio processing graph
    // file player -> converter -> EQ -> mixer -> rio
    
    TOThrowOnError(AUGraphConnectNodeInput(_graph,
                                           _filePlayerNode,     // source node
                                           0,                   // source bus
                                           _converterNode,      // destination node
                                           0));                 // destination bus
    
    TOThrowOnError(AUGraphConnectNodeInput(_graph,
                                           _converterNode,
                                           0,
                                           _eqNode,
                                           0));
    
    TOThrowOnError(AUGraphConnectNodeInput(_graph,
                                           _eqNode,
                                           0,
                                           _rioNode,
                                           0));
    
//    TOThrowOnError(AUGraphConnectNodeInput(_graph,
//                                           _mixerNode,
//                                           0,
//                                           _rioNode,
//                                           0));

    
    
    //............................................................................
    // Set properties/parameters of the units inside the graph
    
    
    // Set the correct streaming format to the converter unit
    AudioStreamBasicDescription effectUnitInputFormat;
    UInt32 propSize = sizeof(AudioStreamBasicDescription);

    TOThrowOnError(AudioUnitGetProperty(equalizerUnit,
                                        kAudioUnitProperty_StreamFormat,
                                        kAudioUnitScope_Input,
                                        0,
                                        &effectUnitInputFormat,
                                        &propSize));
    
    
    TOThrowOnError(AudioUnitSetProperty(_converterUnit,
                                        kAudioUnitProperty_StreamFormat,
                                        kAudioUnitScope_Output,
                                        0,
                                        &effectUnitInputFormat,
                                        propSize));
    
    
    // Enable metering at the output of the mixer unit
    UInt32 meteringMode = 1; // enabled
    TOThrowOnError(AudioUnitSetProperty(_mixerUnit,
                                        kAudioUnitProperty_MeteringMode,
                                        kAudioUnitScope_Output,
                                        0,
                                        &meteringMode,
                                        sizeof(meteringMode)));
    
    
    // Set number of bands for the EQ unit
    // Set the frequencies for each band of the EQ unit    
    _eqFrequencies = @[ @32, @64, @125, @250, @500, @1000, @2000, @4000, @8000, @16000 ];
    self.numBands = _eqFrequencies.count;
    self.bands = _eqFrequencies;
    
    
    
    //............................................................................
    // Initialize Graph
    TOThrowOnError(AUGraphInitialize(_graph));
    
    
    
    //............................................................................
    // other audio unit setup
    [self setUpFilePlayerUnit];
}


- (void)setUpFilePlayerUnit
{
    // init audioFile
    if (_audioFile) {
        TOThrowOnError(AudioFileClose(_audioFile));
    }
    
    
    NSURL *nyanURL = [[NSBundle mainBundle] URLForResource:@"nyan" withExtension:@"m4a"];
    TOThrowOnError(AudioFileOpenURL((__bridge CFURLRef)(nyanURL), kAudioFileReadPermission, 0, &_audioFile));
    
    TOThrowOnError(AudioUnitSetProperty(_filePlayerUnit,
                                        kAudioUnitProperty_ScheduledFileIDs,
                                        kAudioUnitScope_Global,
                                        0,
                                        &_audioFile,
                                            sizeof(_audioFile)));
   

    
    // get input file format
    AudioStreamBasicDescription audioFileASBD;
    UInt32 propSize = sizeof(audioFileASBD);
    TOThrowOnError(AudioFileGetProperty(_audioFile,
                                        kAudioFilePropertyDataFormat,
                                        &propSize,
                                        &audioFileASBD));
    
    
    
	UInt64 nPackets;
	UInt32 propsize = sizeof(nPackets);
	TOThrowOnError(AudioFileGetProperty(_audioFile,
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
	rgn.mAudioFile = _audioFile;
	rgn.mLoopCount = 0;
	rgn.mStartFrame = 0;
	rgn.mFramesToPlay = nPackets * audioFileASBD.mFramesPerPacket;
	
	TOThrowOnError(AudioUnitSetProperty(_filePlayerUnit,
                                        kAudioUnitProperty_ScheduledFileRegion,
                                        kAudioUnitScope_Global,
                                        0,
                                        &rgn,
                                        sizeof(rgn)));
    
	// prime the file player AU with default values
	UInt32 defaultVal = 0;
	TOThrowOnError(AudioUnitSetProperty(_filePlayerUnit,
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
    
	TOThrowOnError(AudioUnitSetProperty(_filePlayerUnit,
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
    
    TOThrowOnError(AudioUnitGetParameter(_mixerUnit,
                                         kMultiChannelMixerParam_PostAveragePower,
                                         kAudioUnitScope_Output,
                                         0,
                                         &retVal));
    
    return retVal;
}


- (AudioUnitParameterValue)avgValueRight
{
    AudioUnitParameterValue retVal;
    
    TOThrowOnError(AudioUnitGetParameter(_mixerUnit,
                                         kMultiChannelMixerParam_PostAveragePower+1,
                                         kAudioUnitScope_Output,
                                         0,
                                         &retVal));
    
    return retVal;
}


- (AudioUnitParameterValue)peakValueLeft
{
    AudioUnitParameterValue retVal;
    
    TOThrowOnError(AudioUnitGetParameter(_mixerUnit,
                                         kMultiChannelMixerParam_PostPeakHoldLevel,
                                         kAudioUnitScope_Output,
                                         0,
                                         &retVal));
    
    return retVal;
}


- (AudioUnitParameterValue)peakValueRight
{
    AudioUnitParameterValue retVal;
    
    TOThrowOnError(AudioUnitGetParameter(_mixerUnit,
                                         kMultiChannelMixerParam_PostPeakHoldLevel+1,
                                         kAudioUnitScope_Output,
                                         0,
                                         &retVal));
    
    return retVal;
}


- (void)setVolume:(AudioUnitParameterValue)volume
{
    TOThrowOnError(AudioUnitSetParameter(_mixerUnit,
                                         kMultiChannelMixerParam_Volume,
                                         kAudioUnitScope_Output,
                                         0,
                                         volume,
                                         0));
}


- (AudioUnitParameterValue)volume
{
    AudioUnitParameterValue retVal;
    
    TOThrowOnError(AudioUnitGetParameter(_mixerUnit,
                                         kMultiChannelMixerParam_Volume,
                                         kAudioUnitScope_Output,
                                         0,
                                         &retVal));
    
    return retVal;
}


@end
