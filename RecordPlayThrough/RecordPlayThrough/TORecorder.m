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

@property (assign, atomic) BOOL isReadyForRecording;
@property (assign, atomic) BOOL isSetUp;

@property (assign, nonatomic) AudioUnit rioUnit;
@property (assign, nonatomic) AudioStreamBasicDescription asbd;

@property (assign, nonatomic) AudioFileID audioFile;
@property (assign, nonatomic) SInt64 numPacketsWritten;

@end


/**
 This callback is called when the audioUnit needs new data to play through the
 speakers. 
 */
static OSStatus recorderCallback(void                     *inRefCon,
                               AudioUnitRenderActionFlags *ioActionFlags,
                               const AudioTimeStamp       *inTimeStamp,
                               UInt32                      inBusNumber,
                               UInt32                      inNumberFrames,
                               AudioBufferList            *ioData)
{
    TORecorder *recorder = (__bridge TORecorder *)inRefCon;
    
    // get the data from the rio's input bus
    TOThrowOnError(AudioUnitRender(recorder.rioUnit,
                                   ioActionFlags,
                                   inTimeStamp,
                                   kInputBus,
                                   inNumberFrames,
                                   ioData));
    
    
    // write the rendered audio into a file
    if (recorder.isRecording) {
        UInt32 numPackets = ioData->mBuffers[0].mDataByteSize / recorder.asbd.mBytesPerPacket;
        
        TOThrowOnError(AudioFileWritePackets(recorder.audioFile,
                                             false,
                                             ioData->mBuffers[0].mDataByteSize,
                                             NULL,
                                             recorder.numPacketsWritten,
                                             &numPackets,
                                             ioData->mBuffers[0].mData));
        
        recorder.numPacketsWritten += numPackets;
    }
    
    
    // silence output
    if (!recorder.isMonitoringInput) {
        for (UInt32 i=0; i < ioData->mNumberBuffers; i++) {
            AudioBuffer buffer = ioData->mBuffers[i];
            memset(buffer.mData, 0, buffer.mDataByteSize); // fill in zeros
        }
    }
	
    return noErr;
}



@implementation TORecorder

- (void)dealloc
{
    [self tearDown];
}


- (void)setIsRecording:(BOOL)isRecording
{
    @synchronized(self)
    {
        _isRecording = isRecording;
    }
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
        
        TOThrowOnError(AudioFileClose(self.audioFile));
    }
}


- (void)setUp
{
    AudioUnit rioUnit;
    TOThrowOnError(TOAudioUnitNewInstance(kAudioUnitType_Output,
                                          kAudioUnitSubType_RemoteIO,
                                          &rioUnit));
    
    // Enable IO for recording
	UInt32 flag = 1;
	TOThrowOnError(AudioUnitSetProperty(rioUnit,
                                        kAudioOutputUnitProperty_EnableIO,
                                        kAudioUnitScope_Input,
                                        kInputBus,
                                        &flag,
                                        sizeof(flag)));

	
	// Enable IO for playback
    TOThrowOnError(AudioUnitSetProperty(rioUnit,
                                        kAudioOutputUnitProperty_EnableIO,
                                        kAudioUnitScope_Output,
                                        kOutputBus,
                                        &flag,
                                        sizeof(flag)));

    
    // Set recording/playback format
    AudioStreamBasicDescription asbd = TOCanonicalLPCM();
    
    TOThrowOnError(AudioUnitSetProperty(rioUnit,
                                        kAudioUnitProperty_StreamFormat,
                                        kAudioUnitScope_Output,
                                        kInputBus,
                                        &asbd,
                                        sizeof(asbd)));

	TOThrowOnError(AudioUnitSetProperty(rioUnit,
                                        kAudioUnitProperty_StreamFormat,
                                        kAudioUnitScope_Input,
                                        kOutputBus,
                                        &asbd,
                                        sizeof(asbd)));

	// Set up callback
    AURenderCallbackStruct callbackStruct;
	callbackStruct.inputProc = recorderCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)(self);
    
	TOThrowOnError(AudioUnitSetProperty(rioUnit,
                                        kAudioUnitProperty_SetRenderCallback,
                                        kAudioUnitScope_Global,
                                        kOutputBus,
                                        &callbackStruct,
                                        sizeof(callbackStruct)));

    
    self.rioUnit = rioUnit;
    self.asbd = asbd;
    
    TOThrowOnError(AudioUnitInitialize(rioUnit));
    TOThrowOnError(AudioOutputUnitStart(rioUnit));
    
    
    self.isSetUp = YES;
}


- (void)tearDown
{
    if (self.isSetUp) {
        [self stopRecording];
        self.isSetUp = NO;
        
        TOThrowOnError(AudioOutputUnitStop(self.rioUnit));
        TOThrowOnError(AudioUnitUninitialize(self.rioUnit));
    }
}

@end
