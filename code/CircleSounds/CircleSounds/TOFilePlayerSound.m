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


@interface TOFilePlayerSound ()

- (void)applySchedulingChanges;

@end


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
        
        if (isnan(filePlayer->_currentFilePlayerUnitRenderSampleTime)) {
            filePlayer->_currentFilePlayerUnitRenderSampleTime = inTimeStamp->mSampleTime;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (filePlayer->_audioFile) {
                    [filePlayer applySchedulingChanges];
                }
            });
        }
        else {
            filePlayer->_currentFilePlayerUnitRenderSampleTime = inTimeStamp->mSampleTime;
        }
    }
    
    return noErr;
}


- (id)init
{
    self = [super init];
    
    if (self) {
        _filePlayerUnit = [[TOAudioUnit alloc] init];
        _filePlayerUnit->description = TOAudioComponentDescription(kAudioUnitType_Generator, kAudioUnitSubType_AudioFilePlayer);
        
        _currentFilePlayerUnitRenderSampleTime = NAN;
        _loopCount = 1;
        
        _audioUnits = [_audioUnits arrayByAddingObject:_filePlayerUnit];
    }
    
    return self;
}


- (void)tearDownUnits
{
    if (_audioFile) {
        TOThrowOnError(AudioFileClose(_audioFile));
    }
    
    _filePlayerUnitFullyInitialized = NO;
    
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


- (void)setupFinished
{
    _filePlayerUnitFullyInitialized = YES;
    [self applyFileChanges];
}


- (NSTimeInterval)duration
{
    if (_loopCount == -1) {
        return -1;
    }
    else if (_audioFileURL && _regionDuration) {
        return _regionStart + _regionDuration * _loopCount;
    }
    else {
        return [super duration];
    }
}


- (void)handleDocumentReset
{
    [super handleDocumentReset];
    
    if (_audioFile) {
        [self applySchedulingChanges];
    }
}


#pragma mark - Property Setter & Getter

- (BOOL)setAudioFileURL:(NSURL *)url error:(NSError **)error
{
    [self willChangeValueForKey:@"audioFileURL"];
    _audioFileURL = url;
    [self didChangeValueForKey:@"audioFileURL"];
    
    
    if (_audioFile) {
        TOThrowOnError(AudioFileClose(_audioFile));
    }
    
    
    //............................................................................
    // audio file setup
    
    NSError *intError = nil;
    
    TOErrorHandler(AudioFileOpenURL((__bridge CFURLRef)(_audioFileURL),
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
    UInt32 propSize = sizeof(_audioFileASBD);
    TOErrorHandler(AudioFileGetProperty(_audioFile,
                                        kAudioFilePropertyDataFormat,
                                        &propSize,
                                        &_audioFileASBD),
                   &intError,
                   @"Failed to read file stream format");
    
    if (intError) {
        if (error) {
            *error = intError;
        }
        
        return NO;
    }
    
    
	UInt32 propsize = sizeof(_audioFileNumPackets);
	TOErrorHandler(AudioFileGetProperty(_audioFile,
                                        kAudioFilePropertyAudioDataPacketCount,
                                        &propsize,
                                        &_audioFileNumPackets),
                   &intError,
                   @"Failed to read file packet count");
    
    if (intError) {
        if (error) {
            *error = intError;
        }
        
        return NO;
    }
    
    
    [self readAudioFileProperties];
    return YES;
}


- (void)readAudioFileProperties
{
    UInt32 dictionarySize = 0;
    TOThrowOnError(AudioFileGetPropertyInfo(_audioFile,
                                            kAudioFilePropertyInfoDictionary,
                                            &dictionarySize,
                                            0));
    
    CFDictionaryRef dictionaryRef;
    TOThrowOnError(AudioFileGetProperty(_audioFile,
                                        kAudioFilePropertyInfoDictionary,
                                        &dictionarySize,
                                        &dictionaryRef));
    
    
    NSDictionary *dictionary = (__bridge NSDictionary *)(dictionaryRef);
    
    _fileSongName = dictionary[@kAFInfoDictionary_Title];
    _fileSongArtist = dictionary[@kAFInfoDictionary_Artist];
    
    CFRelease(dictionaryRef);
}


- (Float64)fileDuration
{
    if (!_audioFile) {
        return 0.0;
    }
    
    Float64 fileDuration;
    
    UInt32 propSize = sizeof(fileDuration);
    TOThrowOnError(AudioFileGetProperty(_audioFile,
                                        kAudioFilePropertyEstimatedDuration,
                                        &propSize,
                                        &fileDuration));
    
    return fileDuration;
}


- (void)setRegionStart:(double)regionStart
{
    _regionStart = regionStart;
    
    if (_filePlayerUnitFullyInitialized) {
        [self applySchedulingChanges];
    }
}


- (void)setRegionDuration:(double)regionDuration
{
    _regionDuration = regionDuration;
    
    if (_filePlayerUnitFullyInitialized) {
        [self applySchedulingChanges];
    }
}


- (void)setLoopCount:(UInt32)loopCount
{
    _loopCount = loopCount;
    
    if (_filePlayerUnitFullyInitialized) {
        [self applySchedulingChanges];
    }
}


- (void)setStartTime:(double)startTime
{
    _startTime = startTime;
    
    if (_filePlayerUnitFullyInitialized) {
        [self applySchedulingChanges];
    }
}


- (void)applySchedulingChanges
{
    if (isnan(_currentFilePlayerUnitRenderSampleTime)) {
#if DEBUG
        NSLog(@"%@ invalid sample time. Scheduling not possible!", self);
#endif
        return;
    }
    
    
    
    
    TOThrowOnError(AudioUnitReset(_filePlayerUnit->unit,
                                  kAudioUnitScope_Input,
                                  0));
    
    //............................................................................
    // region
    
    SInt64 startFrame;
    Float64 currentTime = self.document.currentPlaybackPosition;
    UInt32 framesToPlay;
    UInt32 numFramesInFile = _audioFileNumPackets * _audioFileASBD.mFramesPerPacket;
    
    
    if (currentTime < _startTime) {
        startFrame = _regionStart * _audioFileASBD.mSampleRate;
        framesToPlay = _regionDuration * _audioFileASBD.mSampleRate;
    }
    else {
        startFrame = currentTime * _audioFileASBD.mSampleRate;
        framesToPlay = (_regionDuration - (currentTime - _startTime)) * _audioFileASBD.mSampleRate;
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
	rgn.mLoopCount = _loopCount;
	rgn.mStartFrame = startFrame;
	rgn.mFramesToPlay = framesToPlay;
    
    
    TOThrowOnError(AudioUnitSetProperty(_filePlayerUnit->unit,
                                        kAudioUnitProperty_ScheduledFileRegion,
                                        kAudioUnitScope_Global,
                                        0,
                                        &rgn,
                                        sizeof(rgn)));
    
    UInt32 defaultVal = 0;
	TOThrowOnError(AudioUnitSetProperty(_filePlayerUnit->unit,
                                        kAudioUnitProperty_ScheduledFilePrime,
                                        kAudioUnitScope_Global,
                                        0,
                                        &defaultVal,
                                        sizeof(defaultVal)));
    
    
    
    //............................................................................
    // start time
    
    Float64 timeOffset = _startTime - currentTime; /* in seconds */
    Float64 sampleStartTime;
    
    
    if (timeOffset > 0.0) {
        sampleStartTime = _currentFilePlayerUnitRenderSampleTime + timeOffset * _filePlayerUnitOutputSampleRate;
    }
    else {
        sampleStartTime = -1.0;
    }
    
    
    AudioTimeStamp startTime;
	memset (&startTime, 0, sizeof(startTime));
	startTime.mFlags = kAudioTimeStampSampleTimeValid;
	startTime.mSampleTime = sampleStartTime;
    
    
    printf("sample start time: %f\n", sampleStartTime);
    
    
    TOThrowOnError(AudioUnitSetProperty(_filePlayerUnit->unit,
                                        kAudioUnitProperty_ScheduleStartTimeStamp,
                                        kAudioUnitScope_Global,
                                        0,
                                        &startTime,
                                        sizeof(startTime)));
}


- (void)applyFileChanges
{
    TOThrowOnError(AudioUnitSetProperty(_filePlayerUnit->unit,
                                        kAudioUnitProperty_ScheduledFileIDs,
                                        kAudioUnitScope_Global,
                                        0,
                                        &_audioFile,
                                        sizeof(_audioFile)));
    
    [self applySchedulingChanges];
}

@end
