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

+ (NSUInteger)numUnits
{
    return [super numUnits] + 1;
}


- (id)init
{
    self = [super init];
    
    if (self) {
        _filePlayerUnit = [[TOAudioUnit alloc] init];
        _filePlayerUnit->description = TOAudioComponentDescription(kAudioUnitType_Generator, kAudioUnitSubType_AudioFilePlayer);
        
        _audioUnits = [_audioUnits arrayByAddingObject:_filePlayerUnit];
    }
    
    return self;
}


- (void)tearDownUnits
{
    if (_audioFile) {
        TOThrowOnError(AudioFileClose(_audioFile));
    }
    
    [super tearDownUnits];
}


- (BOOL)applyChanges:(NSError *__autoreleasing *)error
{
    //............................................................................
    // audio file setup
    if (_audioFile) {
        TOThrowOnError(AudioFileClose(_audioFile));
    }
    
    NSError *intError = nil;

    TOErrorHandler(AudioFileOpenURL((__bridge CFURLRef)(self.audioFileURL),
                                    kAudioFileReadPermission,
                                    0,
                                    &_audioFile),
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
	rgn.mAudioFile = _audioFile;
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
	startTime.mSampleTime = -1;
    
    
    
    //............................................................................
    // set the file player properties
    TOThrowOnError(AudioUnitSetProperty(_filePlayerUnit->unit,
                                        kAudioUnitProperty_ScheduledFileIDs,
                                        kAudioUnitScope_Global,
                                        0,
                                        &_audioFile,
                                        sizeof(_audioFile)));
	
    
	
	
	TOThrowOnError(AudioUnitSetProperty(_filePlayerUnit->unit,
                                        kAudioUnitProperty_ScheduledFileRegion,
                                        kAudioUnitScope_Global,
                                        0,
                                        &rgn,
                                        sizeof(rgn)));
    
    
	// prime the file player AU with default values
	UInt32 defaultVal = 0;
	TOThrowOnError(AudioUnitSetProperty(_filePlayerUnit->unit,
                                        kAudioUnitProperty_ScheduledFilePrime,
                                        kAudioUnitScope_Global,
                                        0,
                                        &defaultVal,
                                        sizeof(defaultVal)));
	
    
	TOThrowOnError(AudioUnitSetProperty(_filePlayerUnit->unit,
                                        kAudioUnitProperty_ScheduleStartTimeStamp,
                                        kAudioUnitScope_Global,
                                        0,
                                        &startTime,
                                        sizeof(startTime)));

    return YES;
}


@end
