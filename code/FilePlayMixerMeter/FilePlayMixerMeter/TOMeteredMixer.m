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
    
    
    
    
    //............................................................................
    // Connect the nodes of the audio processing graph
    
    TOThrowOnError(AUGraphConnectNodeInput(_graph,
                                           _filePlayerNode,     // source node
                                           0,                   // source bus
                                           _eqNode,             // destination node
                                           0));                 // destination bus
    
    TOThrowOnError(AUGraphConnectNodeInput(_graph,
                                           _eqNode,
                                           0,
                                           _mixerNode,
                                           0));
    
    TOThrowOnError(AUGraphConnectNodeInput(_graph,
                                           _mixerNode,
                                           0,
                                           _rioNode,
                                           0));
    
    
    //............................................................................
    // Set properties/parameters of the units inside the graph
    
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
    
    NSLog(@"num band: %ld", self.numBands);
    
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
