//
//  TORecorder.m
//  RecordPlayThrough
//
//  Created by Tobias Ottenweller on 08.07.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TORecorder.h"

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import "TOCAShortcuts.h"
#import "TORecorderDelegate.h"


@interface TORecorder ()
{
    AudioUnit _rioUnit;
    AudioStreamBasicDescription _asbd;

    AudioFileID _audioFile;
    SInt64 _numPacketsWritten;
    
    BOOL _isRecording;
    BOOL _monitoringInput;
    
    AudioSampleType _peakSample;
    AudioSampleType _avgSample;
    
    BOOL _sampleUpdateNeeded; // new values for '_peakSample' & '_avgSample' will be calculate when set to 'NO'
}

@property (assign, atomic) BOOL isReadyForRecording;
@property (assign, atomic) BOOL isSetUp;

@end



@implementation TORecorder


static inline OSStatus writeBufferToFile(TORecorder *recorder, AudioBufferList *ioData)
{
    UInt32 numPackets = ioData->mBuffers[0].mDataByteSize / recorder->_asbd.mBytesPerPacket;
    
    OSStatus status = AudioFileWritePackets(recorder->_audioFile,
                                            false,
                                            ioData->mBuffers[0].mDataByteSize,
                                            NULL,
                                            recorder->_numPacketsWritten,
                                            &numPackets,
                                            ioData->mBuffers[0].mData);
    
    recorder->_numPacketsWritten += numPackets;
    
    return status;
}


static inline void calculateAvgAndPeakSamples(TORecorder *recorder, AudioBufferList *ioData)
{
    // TODO: what to do with multichannel buffers!
    // NOTE: this assumes AudioSampleTypes inside the buffer!
    
    UInt32 numSamples = ioData->mBuffers[0].mDataByteSize / sizeof(AudioSampleType);
    AudioSampleType *samples = ioData->mBuffers[0].mData;
    
    
    SInt64 sum = 0;  // NOTE: assume that AudioSampleType is a signed integer
    AudioSampleType peak = 0;
    
    for (int i=0; i<numSamples; i++) {
        AudioSampleType curSample = abs((AudioSampleType)samples[i]);
        
        sum += curSample;
        
        if (peak < curSample) {
            peak = curSample;
        }
    }

    recorder->_avgSample = sum / numSamples;
    recorder->_peakSample = peak;
    
}

//static inline void notifiyDelegateAboutNewData(TORecorder *recorder, AudioBufferList *ioData)
//{
//    AudioBufferList *delegateBufferList = malloc(sizeof(ioData));
//    delegateBufferList->mNumberBuffers = ioData->mNumberBuffers;
//    
//    
//    for (UInt32 i=0;i<ioData->mNumberBuffers; i++) {
//        AudioBuffer buffer;
//        buffer.mNumberChannels = ioData->mBuffers[i].mNumberChannels;
//        buffer.mDataByteSize = ioData->mBuffers[i].mDataByteSize;
//        buffer.mData = malloc(buffer.mDataByteSize);
//        
//        memcpy(buffer.mData, ioData->mBuffers[i].mData, ioData->mBuffers[i].mDataByteSize);
//        
//        delegateBufferList->mBuffers[i] = buffer;
//    }
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [recorder.delegate recorder:recorder didGetNewData:delegateBufferList];
//        
//        // cleanup
//        for (UInt32 i=0; i<delegateBufferList->mNumberBuffers; i++) {
//            free(delegateBufferList->mBuffers[i].mData);
//        }
//        
//        free(delegateBufferList);
//    });
//}



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
    OSStatus err = AudioUnitRender(recorder->_rioUnit,
                                   ioActionFlags,
                                   inTimeStamp,
                                   kInputBus,
                                   inNumberFrames,
                                   ioData);
    
    
    // write the rendered audio into a file
    if (recorder->_isRecording) {
        TOThrowOnError(writeBufferToFile(recorder, ioData));
    }
    
//    // notify delegate
//    notifiyDelegateAboutNewData(recorder, ioData);
    
    // calculate peak and average
    if (recorder->_sampleUpdateNeeded) {
        calculateAvgAndPeakSamples(recorder, ioData);
        recorder->_sampleUpdateNeeded = NO;
    }
    
	

    // silence output
    if (!recorder->_monitoringInput) {
        *ioActionFlags = kAudioUnitRenderAction_OutputIsSilence;
        
        for (UInt32 i=0; i < ioData->mNumberBuffers; i++) {
            AudioBuffer buffer = ioData->mBuffers[i];
            memset(buffer.mData, 0, buffer.mDataByteSize); // fill in zeros
        }
    }

    return err;
}


- (void)dealloc
{
    [self tearDown];
}
    

- (void)setIsRecording:(BOOL)isRecording
{
    _isRecording = isRecording;
}


- (double)peakPowerForChannel:(NSUInteger)channelNumber
{
    if (channelNumber > self.numChannels) {
        return 0.0;
    }
    
    _sampleUpdateNeeded = YES;
    
    // NOTE: assume that AudioSampleType is a 16bit signed integer
    return 10.0 * log10((double)_peakSample / INT16_MAX);
}


- (double)averagePowerForChannel:(NSUInteger)channelNumber
{
    if (channelNumber > self.numChannels) {
        return 0.0;
    }
    
    _sampleUpdateNeeded = YES;
    
    // NOTE: assume that AudioSampleType is a 16bit signed integer
    return 10.0 * log10((double)_avgSample/ INT16_MAX);
}


- (BOOL)prepareForRecordingWithFileURL:(NSURL *)url error:(NSError *__autoreleasing *)error
{
    NSParameterAssert(url);
    
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
    [self.delegate recorderDidStartRecording:self];
    
    return YES;
}


- (void)stopRecording
{
    if (self.isRecording) {
        self.isRecording = NO;
        self.isReadyForRecording = NO;
        
        TOThrowOnError(AudioFileClose(_audioFile));
        
        [self.delegate recorderDidStopRecording:self];
    }
}


- (void)setUp
{
    // Set up ASBD
    _numChannels = [[AVAudioSession sharedInstance] inputNumberOfChannels];
    
    if (self.numChannels == 1) {
        _asbd = TOCanonicalMonoLPCM();
    }
    else {
        _asbd = TOCanonicalStereoLPCM();
    }
    

    // Refer to iOS developer library : Audio Session Programming Guide set preferred buffer duration to 1024 / sample rate
    [[AVAudioSession sharedInstance] setPreferredSampleRate:_asbd.mSampleRate error:nil];
    [[AVAudioSession sharedInstance] setPreferredIOBufferDuration:1024.0/_asbd.mSampleRate error:nil];
    
    
    // Get the RIO unit
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


    // Set recording/playback format
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
