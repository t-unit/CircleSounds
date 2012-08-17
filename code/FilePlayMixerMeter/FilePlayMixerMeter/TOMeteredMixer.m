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
    
    BOOL _unitsGettingReset;
}

- (void)setUpFilePlayerUnit;
- (void)setUp;

@end


@implementation TOMeteredMixer


void AudioFileCompletionCallback(void *userData, ScheduledAudioFileRegion *fileRegion, OSStatus result)
{    
    TOMeteredMixer *mixer = (__bridge TOMeteredMixer *)userData;
    
    if (mixer->_unitsGettingReset) {
        return;
    }
    
    mixer->_unitsGettingReset = YES;
    
    NSLog(@"playback finished (%@)", mixer);
    
    
    // stoping the graph inside it own callbacks does not work
    // adding the operations to the main queue instead
    dispatch_async(dispatch_get_main_queue(), ^{
        TOThrowOnError(AUGraphStop(mixer->_graph));
        TOThrowOnError(AUGraphUninitialize(mixer->_graph));
        TOThrowOnError(AUGraphClose(mixer->_graph));
        
        [mixer setUp];
        TOThrowOnError(AUGraphStart(mixer->_graph));
          mixer->_unitsGettingReset = NO;
    });
}


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
    // Create AUGraph
    TOThrowOnError(NewAUGraph(&_graph));
    
    
    // Create AUNodes
    TOThrowOnError(TOAUGraphAddNode(kAudioUnitType_Generator, kAudioUnitSubType_AudioFilePlayer, _graph, &_filePlayerNode));
    
    TOThrowOnError(TOAUGraphAddNode(kAudioUnitType_Mixer, kAudioUnitSubType_MultiChannelMixer, _graph, &_mixerNode));
    
    TOThrowOnError(TOAUGraphAddNode(kAudioUnitType_Output, kAudioUnitSubType_RemoteIO, _graph, &_rioNode));
    
    
    // Open AUGraph
    TOThrowOnError(AUGraphOpen(_graph));
    
    
    // Get AudioUnits
    TOThrowOnError(AUGraphNodeInfo(_graph, _filePlayerNode, NULL, &_filePlayerUnit));
    TOThrowOnError(AUGraphNodeInfo(_graph, _mixerNode, NULL, &_mixerUnit));
    TOThrowOnError(AUGraphNodeInfo(_graph, _rioNode, NULL, &_rioUnit));
    
    
    // Connect AUNodes/AudioUnits
    TOThrowOnError(AUGraphConnectNodeInput(_graph, _filePlayerNode, 0, _mixerNode, 0));
    TOThrowOnError(AUGraphConnectNodeInput(_graph, _mixerNode, 0, _rioNode, 0));
    
    
    // Initialize Graph
    TOThrowOnError(AUGraphInitialize(_graph));
    
    
    // Mixer Unit Property setup
    UInt32 meteringMode = 1; // enabled
    TOThrowOnError(AudioUnitSetProperty(_mixerUnit,
                                        kAudioUnitProperty_MeteringMode,
                                        kAudioUnitScope_Output,
                                        0,
                                        &meteringMode,
                                        sizeof(meteringMode)));
    
    [self setUpFilePlayerUnit];
}


- (void)setUpFilePlayerUnit
{
    if (!_audioFile) {
        // init audioFile
        NSURL *nyanURL = [[NSBundle mainBundle] URLForResource:@"nyan" withExtension:@"m4a"];
        TOThrowOnError(AudioFileOpenURL((__bridge CFURLRef)(nyanURL), kAudioFileReadPermission, 0, &_audioFile));
        
        TOThrowOnError(AudioUnitSetProperty(_filePlayerUnit,
                                            kAudioUnitProperty_ScheduledFileIDs,
                                            kAudioUnitScope_Global,
                                            0,
                                            &_audioFile,
                                            sizeof(_audioFile)));
    }

    
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


@end
