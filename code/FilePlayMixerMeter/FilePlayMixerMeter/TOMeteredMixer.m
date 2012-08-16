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
    AudioUnit _mixerUnit;
    AudioUnit _filePlayerUnit;
    
    AudioFileID _audioFile;
    AudioStreamBasicDescription _audioFileASBD;
}



@end


@implementation TOMeteredMixer


- (id)init
{
    self = [super init];
    
    if (self) {
        // init audioFile
        NSURL *nyanURL = [[NSBundle mainBundle] URLForResource:@"nyan" withExtension:@"m4a"];
        TOThrowOnError(AudioFileOpenURL((__bridge CFURLRef)(nyanURL), kAudioFileReadPermission, 0, &_audioFile));
        
        // get input file format
        UInt32 propSize = sizeof(_audioFileASBD);
        TOThrowOnError(AudioFileGetProperty(_audioFile,
                                            kAudioFilePropertyDataFormat,
                                            &propSize,
                                            &_audioFileASBD));
        
        // following lines are here for testing and should be removed later on!
        [self setUp];
        TOThrowOnError(AUGraphStart(_graph));
    }
    
    return self;
}


- (void)setUp
{
    // Create AUGraph
    TOThrowOnError(NewAUGraph(&_graph));
    
    
    // Create AUNodes
    AUNode filePlayerNode;
    TOThrowOnError(TOAUGraphAddNode(kAudioUnitType_Generator, kAudioUnitSubType_AudioFilePlayer, _graph, &filePlayerNode));
    
    AUNode mixerNode;
    TOThrowOnError(TOAUGraphAddNode(kAudioUnitType_Mixer, kAudioUnitSubType_MultiChannelMixer, _graph, &mixerNode));
    
    AUNode rioNode;
    TOThrowOnError(TOAUGraphAddNode(kAudioUnitType_Output, kAudioUnitSubType_RemoteIO, _graph, &rioNode));
    
    
    // Open AUGraph
    TOThrowOnError(AUGraphOpen(_graph));
    
    
    // Get AudioUnits
    TOThrowOnError(AUGraphNodeInfo(_graph, filePlayerNode, NULL, &_filePlayerUnit));
    TOThrowOnError(AUGraphNodeInfo(_graph, mixerNode, NULL, &_mixerUnit));
    TOThrowOnError(AUGraphNodeInfo(_graph, rioNode, NULL, &_rioUnit));
    
    
    // Mixer Unit Property setup
    UInt32 meteringMode = 1; // enabled
    TOThrowOnError(AudioUnitSetProperty(_mixerUnit,
                                        kAudioUnitProperty_MeteringMode,
                                        kAudioUnitScope_Output,
                                        0,
                                        &meteringMode,
                                        sizeof(meteringMode)));
    
    
    // Connect AUNodes/AudioUnits
    TOThrowOnError(AUGraphConnectNodeInput(_graph, filePlayerNode, 0, mixerNode, 0));
    TOThrowOnError(AUGraphConnectNodeInput(_graph, mixerNode, 0, rioNode, 0));
    
    // Initialize Graph
    TOThrowOnError(AUGraphInitialize(_graph));
    
    
    // prepare the file player unit
    TOThrowOnError(AudioUnitSetProperty(_filePlayerUnit,
                                        kAudioUnitProperty_ScheduledFileIDs,
                                        kAudioUnitScope_Global,
                                        0,
                                        &_audioFile,
                                        sizeof(_audioFile)));
    
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
	rgn.mCompletionProc = NULL;
	rgn.mCompletionProcUserData = NULL;
	rgn.mAudioFile = _audioFile;
	rgn.mLoopCount = 0;
	rgn.mStartFrame = 0;
	rgn.mFramesToPlay = nPackets * _audioFileASBD.mFramesPerPacket;
	
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


- (AudioUnitParameterValue)meterValueLeft
{
    AudioUnitParameterValue retVal;
    
    TOThrowOnError(AudioUnitGetParameter(_mixerUnit,
                                         kMultiChannelMixerParam_PostAveragePower,
                                         kAudioUnitScope_Output,
                                         0,
                                         &retVal));
    
    return retVal;
}


- (AudioUnitParameterValue)meterValueRight
{
    AudioUnitParameterValue retVal;
    
    TOThrowOnError(AudioUnitGetParameter(_mixerUnit,
                                         kMultiChannelMixerParam_PostAveragePower+1,
                                         kAudioUnitScope_Output,
                                         0,
                                         &retVal));
    
    return retVal;
}

@end
