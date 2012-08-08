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
#import <AVFoundation/AVAudioSession.h>


@interface TORecorder ()

@property (assign, atomic) BOOL isReadyForRecording;
@property (assign, atomic) BOOL isSetUp;

@property (assign, nonatomic) AudioUnit rioUnit;
@property (assign, nonatomic) AudioStreamBasicDescription asbd;

@property (assign, nonatomic) AudioBufferList *inputBufferList;
@property (assign, nonatomic) UInt32 actualBufferSize;

@property (assign, nonatomic) AudioFileID audioFile;
@property (assign, nonatomic) SInt64 numPacketsWritten;

@end


/**
 This callback is called when new audio data from the microphone is
 available. It will temporary store the new data and write it to disk
 if the recorder is currently recording.
 */
static OSStatus inputCallback(void                       *inRefCon,
                              AudioUnitRenderActionFlags *ioActionFlags,
                              const AudioTimeStamp       *inTimeStamp,
                              UInt32                      inBusNumber,
                              UInt32                      inNumberFrames,
                              AudioBufferList            *ioData)
{
	TORecorder *recorder = (__bridge TORecorder *)inRefCon;
	
	// prepare buffer
    UInt32 necessaryBufferSize = inNumberFrames * recorder.asbd.mBytesPerFrame;
    
    // try not to allocate new buffers all the time
    if (recorder.actualBufferSize < necessaryBufferSize) {
        if (recorder.actualBufferSize > 0) {
            free(recorder.inputBufferList->mBuffers[0].mData);
        }
        
#if DEBUG
        printf("TORecorder: need to allocate more memory for audio buffer (new size: %ld | old size %ld)\n", necessaryBufferSize, recorder.actualBufferSize);
#endif
        
        recorder.inputBufferList->mBuffers[0].mData = malloc(necessaryBufferSize);
        recorder.actualBufferSize = necessaryBufferSize;
    }
    
    recorder.inputBufferList->mBuffers[0].mDataByteSize = necessaryBufferSize;
    

    // render audio and but the new data into the buffer
    TOThrowOnError(AudioUnitRender(recorder.rioUnit,
                                   ioActionFlags,
                                   inTimeStamp,
                                   inBusNumber,
                                   inNumberFrames,
                                   recorder.inputBufferList));
    
    
    
    // write the rendered audio into a file
    if (recorder.isRecording) {
        UInt32 numPackets = recorder.inputBufferList->mBuffers[0].mDataByteSize / recorder.asbd.mBytesPerPacket;
        
        TOThrowOnError(AudioFileWritePackets(recorder.audioFile,
                                             false,
                                             recorder.inputBufferList->mBuffers[0].mDataByteSize,
                                             NULL,
                                             recorder.numPacketsWritten,
                                             &numPackets,
                                             recorder.inputBufferList->mBuffers[0].mData));
        
        recorder.numPacketsWritten += numPackets;
    }
	
    return noErr;
}


/**
 This callback is called when the audioUnit needs new data to play through the
 speakers. 
 */
static OSStatus outputCallback(void                       *inRefCon,
                               AudioUnitRenderActionFlags *ioActionFlags,
                               const AudioTimeStamp       *inTimeStamp,
                               UInt32                      inBusNumber,
                               UInt32                      inNumberFrames,
                               AudioBufferList            *ioData)
{
    TORecorder *recorder = (__bridge TORecorder *)inRefCon;
    
    if (!recorder.isMonitoringInput || !recorder.inputBufferList->mBuffers[0].mDataByteSize) {
        for (int i=0; i < ioData->mNumberBuffers; i++) {
            AudioBuffer buffer = ioData->mBuffers[i];
            memset(buffer.mData, 0, buffer.mDataByteSize); // fill in zeros
        }
    }
    else {
        for (int i=0; i < ioData->mNumberBuffers; i++) {
            AudioBuffer buffer = ioData->mBuffers[i];

            UInt32 size = MIN(buffer.mDataByteSize, recorder.inputBufferList->mBuffers[0].mDataByteSize); // cpoy as much data as possible
            memcpy(buffer.mData, recorder.inputBufferList->mBuffers[0].mData, size);
            buffer.mDataByteSize = size; // indicate how much data we wrote into the buffer
            
        }
    }
	
    return noErr;
}



@implementation TORecorder


- (id)init
{
    self = [super init];
    
    if (self) {
    }
    
    return self;
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
    
    
    // Set input callback
	AURenderCallbackStruct callbackStruct;
	callbackStruct.inputProc = inputCallback;
	callbackStruct.inputProcRefCon = (__bridge void *)(self);
    
	TOThrowOnError(AudioUnitSetProperty(rioUnit,
                                        kAudioOutputUnitProperty_SetInputCallback,
                                        kAudioUnitScope_Global,
                                        kInputBus,
                                        &callbackStruct,
                                        sizeof(callbackStruct)));
	
	// Set output callback
	callbackStruct.inputProc = outputCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)(self);
    
	TOThrowOnError(AudioUnitSetProperty(rioUnit,
                                        kAudioUnitProperty_SetRenderCallback,
                                        kAudioUnitScope_Global,
                                        kOutputBus,
                                        &callbackStruct,
                                        sizeof(callbackStruct)));

    
    self.rioUnit = rioUnit;
    self.asbd = asbd;
    
    
    // prepare buffers
    AudioBuffer buffer;
    AudioBufferList *bufferList = malloc(sizeof(bufferList));
    	
	buffer.mNumberChannels = 2;
    
    // double the actual buffer size. this prevents allocating more memory inside the callback most of the times
	buffer.mDataByteSize = asbd.mSampleRate * [[AVAudioSession sharedInstance] IOBufferDuration] * buffer.mNumberChannels * asbd.mFramesPerPacket * asbd.mBytesPerPacket * 2;
	buffer.mData = malloc(buffer.mDataByteSize);
    
	bufferList->mNumberBuffers = 1;
	bufferList->mBuffers[0] = buffer;
    
    self.inputBufferList = bufferList;
    self.actualBufferSize = buffer.mDataByteSize;
    
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
        
        if (self.actualBufferSize) {
            free(self.inputBufferList->mBuffers[0].mData);
        }
        
        free(self.inputBufferList);
    }
}


@end
