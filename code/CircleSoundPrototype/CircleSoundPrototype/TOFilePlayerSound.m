//
//  TOAudioFilePlayer.m
//  FilePlayerTest
//
//  Created by Tobias Ottenweller on 21.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOFilePlayerSound.h"

#import "TOCAShortcuts.h"
#import "TOSoundDocument.h"


@implementation TOFilePlayerSound


OSStatus FilePlayerUnitRenderNotifyCallblack (void                        *inRefCon,
                                              AudioUnitRenderActionFlags  *ioActionFlags,
                                              const AudioTimeStamp        *inTimeStamp,
                                              UInt32                      inBusNumber,
                                              UInt32                      inNumberFrames,
                                              AudioBufferList             *ioData
                                             )
{
    TOFilePlayerSound *filePlayer = (__bridge TOFilePlayerSound *)(inRefCon);
    
    if (*ioActionFlags & kAudioUnitRenderAction_PostRender) {
        filePlayer->_currentFilePlayerUnitRenderTimeStamp = *inTimeStamp;
    }
    
    return noErr;
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


- (void)setupUnits
{
    [super setupUnits];
    
    // set up the notify render callback
    TOThrowOnError(AudioUnitAddRenderNotify(_filePlayerUnit->unit,
                                            FilePlayerUnitRenderNotifyCallblack,
                                            (__bridge void *)(self)));
    
    
    // obtain the output sample rate of the file player unit
    // (used later on to calculate the current playback time in seconds)
    UInt32 propSize = sizeof(_filePlayerUnitOutputSampleRate);
    
    TOThrowOnError(AudioUnitGetProperty(_filePlayerUnit->unit,
                                        kAudioUnitProperty_SampleRate,
                                        kAudioUnitScope_Output,
                                        0,
                                        &_filePlayerUnitOutputSampleRate,
                                        &propSize));
}


- (NSTimeInterval)duration
{
    if (self.loopCount == -1) {
        return -1;
    }
    else if (self.audioFileURL && self.regionDuration) {
        return self.regionStart + self.regionDuration * self.loopCount;
    }
    else {
        return [super duration];
    }
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
    double currentTime = self.document.currentPlaybackPosition;
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
    Float64 timeOffset = self.startTime - currentTime; /* in seconds */
    
    if (timeOffset < 0.0) {
        timeOffset = 0.0;
    }
    
    Float64 sampleStartTime = _currentFilePlayerUnitRenderTimeStamp.mSampleTime + timeOffset * _filePlayerUnitOutputSampleRate;
    
    AudioTimeStamp startTime;
	memset (&startTime, 0, sizeof(startTime));
	startTime.mFlags = kAudioTimeStampSampleTimeValid;
	startTime.mSampleTime = sampleStartTime;
    
    
    
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
