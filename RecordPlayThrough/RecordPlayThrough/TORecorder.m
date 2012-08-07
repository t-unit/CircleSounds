//
//  TORecorder.m
//  RecordPlayThrough
//
//  Created by Tobias Ottenweller on 08.07.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TORecorder.h"
#import "TOCAShortcuts.h"


typedef struct {
    AudioUnit rioUnit;
    AudioStreamBasicDescription asbd;
    AudioBufferList inputBufferList;
    UInt32 actualBufferSize;
} TORecorderState;


@interface TORecorder ()

@property (assign, readwrite) BOOL readyForRecording;
@property (assign, readwrite) BOOL isSetUp;
@property (assign, readwrite) TORecorderState state;

@end


/**
 This callback is called when new audio data from the microphone is
 available.
 */
static OSStatus inputCallback(void                       *inRefCon,
                              AudioUnitRenderActionFlags *ioActionFlags,
                              const AudioTimeStamp       *inTimeStamp,
                              UInt32                      inBusNumber,
                              UInt32                      inNumberFrames,
                              AudioBufferList            *ioData)
{
	TORecorderState *recorderState = (TORecorderState *)inRefCon;
	
	// prepare buffer
    UInt32 necessaryBufferSize = inNumberFrames * recorderState->asbd.mBytesPerFrame;
    
    // try not to allocate new buffers all the time
    if (recorderState->actualBufferSize < necessaryBufferSize) {
        if (recorderState->actualBufferSize > 0) {
            free(recorderState->inputBufferList.mBuffers[0].mData);
        }
        
        recorderState->inputBufferList.mBuffers[0].mData = malloc(necessaryBufferSize);
        recorderState->actualBufferSize = necessaryBufferSize;
    }
    
    recorderState->inputBufferList.mBuffers[0].mDataByteSize = necessaryBufferSize;
    

    // render audio and but the new data into the buffer
    TOThrowOnError(AudioUnitRender(recorderState->rioUnit,
                                   ioActionFlags,
                                   inTimeStamp,
                                   inBusNumber,
                                   inNumberFrames,
                                   &recorderState->inputBufferList));
	
    return noErr;
}


/**
 This callback is called when the audioUnit needs new data to play through the
 speakers. If you don't have any, just don't write anything in the buffers
 */
static OSStatus outputCallback(void                       *inRefCon,
                               AudioUnitRenderActionFlags *ioActionFlags,
                               const AudioTimeStamp       *inTimeStamp,
                               UInt32                      inBusNumber,
                               UInt32                      inNumberFrames,
                               AudioBufferList            *ioData)
{
    TORecorderState *recorderState = (TORecorderState *)inRefCon;
    
    // Notes: ioData contains buffers (may be more than one!)
    // Fill them up as much as you can. Remember to set the size value in each buffer to match how
    // much data is in the buffer.
	
	for (int i=0; i < ioData->mNumberBuffers; i++) { // in practice we will only ever have 1 buffer, since audio format is mono
		AudioBuffer buffer = ioData->mBuffers[i];
		
        //		NSLog(@"  Buffer %d has %d channels and wants %d bytes of data.", i, buffer.mNumberChannels, buffer.mDataByteSize);
		
		// copy temporary buffer data to output buffer
		UInt32 size = MIN(buffer.mDataByteSize, recorderState->inputBufferList.mBuffers[0].mDataByteSize); // dont copy more data then we have, or then fits
		memcpy(buffer.mData, recorderState->inputBufferList.mBuffers[0].mData, size);
		buffer.mDataByteSize = size; // indicate how much data we wrote in the buffer
		
		// uncomment to hear random noise
		/*
         UInt16 *frameBuffer = buffer.mData;
         for (int j = 0; j < inNumberFrames; j++) {
         frameBuffer[j] = rand();
         }
         */
		
	}
	
    return noErr;
}




@implementation TORecorder


- (id)init
{
    self = [super init];
    
    if (self) {
        [self setUp];
    }
    
    return self;
}


- (void)setMonitorInput:(BOOL)monitorInput
{
    self->_monitorInput = monitorInput;
    
    if (self.isSetUp) {
        // enable/disable playback
        UInt32 flag = monitorInput;
        
        TOThrowOnError(AudioUnitSetProperty(self.state.rioUnit,
                                            kAudioOutputUnitProperty_EnableIO,
                                            kAudioUnitScope_Output,
                                            kOutputBus,
                                            &flag,
                                            sizeof(flag)));
    }
}



- (BOOL)prepareForRecordingWithFileURL:(NSURL *)url
{
//    if (!self.isSetUp) {
//        return NO;
//    }
    
    self->_url = url;
    
    
    // prepare buffers
    AudioBuffer buffer;
    AudioBufferList bufferList;
	
	buffer.mNumberChannels = 2;
	buffer.mDataByteSize = 0; // the size is unknown at this point (number of frames per callback is unknown)
	buffer.mData = NULL;

	bufferList.mNumberBuffers = 1;
	bufferList.mBuffers[0] = buffer;
    
    self->_state.inputBufferList = bufferList;
    self->_state.actualBufferSize = 0;
    
    
    return YES;
}


- (BOOL)startRecording
{
    if (!self.readyForRecording) {
        return NO;
    }
//    
//    TOThrowOnError(AudioOutputUnitStart(rioUnit));
//    
    return YES;
}


- (void)stopRecording
{
//    TOThrowOnError(AudioOutputUnitStop(rioUnit));
    self.readyForRecording = NO;
    
    
    if (self.state.actualBufferSize) {
        free(self.state.inputBufferList.mBuffers[0].mData);
        self->_state.actualBufferSize = 0;
        self->_state.inputBufferList.mBuffers[0].mData = NULL;
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
    if (!self.monitorInput) {
        TOThrowOnError(AudioUnitSetProperty(rioUnit,
                                            kAudioOutputUnitProperty_EnableIO,
                                            kAudioUnitScope_Output,
                                            kOutputBus,
                                            &flag,
                                            sizeof(flag)));
    }
    

    
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
	callbackStruct.inputProcRefCon = &self->_state;
    
	TOThrowOnError(AudioUnitSetProperty(rioUnit,
                                        kAudioOutputUnitProperty_SetInputCallback,
                                        kAudioUnitScope_Global,
                                        kInputBus,
                                        &callbackStruct,
                                        sizeof(callbackStruct)));
	
	// Set output callback
	callbackStruct.inputProc = outputCallback;
    callbackStruct.inputProcRefCon = &self->_state;
    
	TOThrowOnError(AudioUnitSetProperty(rioUnit,
                                        kAudioUnitProperty_SetRenderCallback,
                                        kAudioUnitScope_Global,
                                        kOutputBus,
                                        &callbackStruct,
                                        sizeof(callbackStruct)));
    
    
    flag = 0;
	TOThrowOnError(AudioUnitSetProperty(rioUnit,
                                        kAudioUnitProperty_ShouldAllocateBuffer,
                                        kAudioUnitScope_Output,
                                        kInputBus,
								  &flag,
								  sizeof(flag)));
    
    
    
    self->_state.rioUnit = rioUnit;
    self->_state.asbd = asbd;
    
    
    TOThrowOnError(AudioUnitInitialize(rioUnit));
    
    [self prepareForRecordingWithFileURL:nil];
    TOThrowOnError(AudioOutputUnitStart(rioUnit));
    
    self.isSetUp = YES;
}


- (void)tearDown
{
    
}


@end
