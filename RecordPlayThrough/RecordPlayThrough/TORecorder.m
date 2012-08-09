//
//  TORecorder.m
//  RecordPlayThrough
//
//  Created by Tobias Ottenweller on 08.07.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TORecorder.h"

#import "TOCAShortcuts.h"

#import <AudioToolbox/AudioToolbox.h>


@interface TORecorder ()
{
    AudioUnit _rioUnit;
    AudioStreamBasicDescription _asbd;
    
    AudioFileID _audioFile;
    SInt64 _numPacketsWritten;
    
    BOOL _isRecording;
    BOOL _isMonitoringInput;
}

@property (assign, atomic) BOOL isReadyForRecording;
@property (assign, atomic) BOOL isSetUp;

@end



@implementation TORecorder

/**
 This callback is called when the audioUnit needs new data to play through the
 speakers.
 */
static OSStatus recorderCallback(void                       *inRefCon,
                                 AudioUnitRenderActionFlags *ioActionFlags,
                                 const AudioTimeStamp       *inTimeStamp,
                                 UInt32                      inBusNumber,
                                 UInt32                      inNumberFrames,
                                 AudioBufferList            *ioData)
{
    TORecorder *recorder = (__bridge TORecorder *)inRefCon;
    
    // get the data from the rio's input bus
    TOThrowOnError(AudioUnitRender(recorder->_rioUnit,
                                   ioActionFlags,
                                   inTimeStamp,
                                   kInputBus,
                                   inNumberFrames,
                                   ioData));
    
    
    // write the rendered audio into a file
    if (recorder->_isRecording) {
        UInt32 numPackets = ioData->mBuffers[0].mDataByteSize / recorder->_asbd.mBytesPerPacket;
        
        TOThrowOnError(AudioFileWritePackets(recorder->_audioFile,
                                             false,
                                             ioData->mBuffers[0].mDataByteSize,
                                             NULL,
                                             recorder->_numPacketsWritten,
                                             &numPackets,
                                             ioData->mBuffers[0].mData));
        
        recorder->_numPacketsWritten += numPackets;
    }
    
    
    // silence output
    if (!recorder->_isMonitoringInput) {
        for (UInt32 i=0; i < ioData->mNumberBuffers; i++) {
            AudioBuffer buffer = ioData->mBuffers[i];
            memset(buffer.mData, 0, buffer.mDataByteSize); // fill in zeros
        }
    }
	
    return noErr;
}





- (void)dealloc
{
    [self tearDown];
}


- (void)setIsRecording:(BOOL)isRecording
{
    _isRecording = isRecording;
}


- (BOOL)prepareForRecordingWithFileURL:(NSURL *)url error:(NSError *__autoreleasing *)error
{
    if (!self.isSetUp) {
        if (error) {
            *error = [NSError errorWithDomain:@"TORecorderErrorDomain" code:0 userInfo:nil];
        }
        
        return NO;
    }
    
    NSError *intError;
    
    // set up output file
    TOErrorHandler(AudioFileCreateWithURL((__bridge CFURLRef)url,
                                          kAudioFileWAVEType,
                                          &_asbd,
                                          kAudioFileWritePermission,
                                          &_audioFile),
                   &intError,
                   @"Setting up output audio file failed!");
    
    
    self->_url = url;
    self.isReadyForRecording = YES;
    
    return YES;
}


- (BOOL)startRecording
{
    if (!self.isReadyForRecording) {
        return NO;
    }

    self.isRecording = YES;
    
    return YES;
}


- (void)stopRecording
{
    if (self.isRecording) {
        self.isRecording = NO;
        self.isReadyForRecording = NO;
        
        TOThrowOnError(AudioFileClose(_audioFile));
    }
}


- (void)setUp
{
    TOThrowOnError(TOAudioUnitNewInstance(kAudioUnitType_Output,
                                          kAudioUnitSubType_RemoteIO,
                                          &_rioUnit));
    
    // Enable IO for recording
	UInt32 flag = 1;
	TOThrowOnError(AudioUnitSetProperty(_rioUnit,
                                        kAudioOutputUnitProperty_EnableIO,
                                        kAudioUnitScope_Input,
                                        kInputBus,
                                        &flag,
                                        sizeof(flag)));

	
	// Enable IO for playback
    TOThrowOnError(AudioUnitSetProperty(_rioUnit,
                                        kAudioOutputUnitProperty_EnableIO,
                                        kAudioUnitScope_Output,
                                        kOutputBus,
                                        &flag,
                                        sizeof(flag)));

    
    // Set recording/playback format
    _asbd = TOCanonicalLPCM();
    
    TOThrowOnError(AudioUnitSetProperty(_rioUnit,
                                        kAudioUnitProperty_StreamFormat,
                                        kAudioUnitScope_Output,
                                        kInputBus,
                                        &_asbd,
                                        sizeof(_asbd)));

	TOThrowOnError(AudioUnitSetProperty(_rioUnit,
                                        kAudioUnitProperty_StreamFormat,
                                        kAudioUnitScope_Input,
                                        kOutputBus,
                                        &_asbd,
                                        sizeof(_asbd)));

	// Set up callback
    AURenderCallbackStruct callbackStruct;
	callbackStruct.inputProc = recorderCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)(self);
    
	TOThrowOnError(AudioUnitSetProperty(_rioUnit,
                                        kAudioUnitProperty_SetRenderCallback,
                                        kAudioUnitScope_Global,
                                        kOutputBus,
                                        &callbackStruct,
                                        sizeof(callbackStruct)));

    
    TOThrowOnError(AudioUnitInitialize(_rioUnit));
    TOThrowOnError(AudioOutputUnitStart(_rioUnit));
    
    
    self.isSetUp = YES;
}


- (void)tearDown
{
    if (self.isSetUp) {
        [self stopRecording];
        self.isSetUp = NO;
        
        TOThrowOnError(AudioOutputUnitStop(_rioUnit));
        TOThrowOnError(AudioUnitUninitialize(_rioUnit));
    }
}

@end
