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
    
    NSInteger _numChannels;
    double _gain;
    
    BOOL _isRecording;
    BOOL _monitoringInput;
    
    AudioSampleType *_peakSamples;
    double *_avgSamples; // using double here even though the real value is SInt16. a double makes it possible to
                         // calculate _avgSamples by not allocating memory during calculation. During calcualtion
                         // this variable contains the sum of all samples!
    
    BOOL _sampleUpdateNeeded; // new values for '_peakSamples' & '_avgSamples' will be calculate when set to 'NO'
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


/**
 Calculates the average Sample and finds the peak sample inside 'ioData' for each channel.
 NOTE: this function assumes AudioSampleTypes inside the buffer!
 */
static inline void calculateAvgAndPeakSamples(TORecorder *ioRecorder, AudioBufferList *inData)
{    
    // set stored values to zero
    memset(ioRecorder->_avgSamples, 0, sizeof(double) * ioRecorder->_numChannels);
    memset(ioRecorder->_peakSamples, 0, sizeof(AudioSampleType) * ioRecorder->_numChannels);
    
    
    UInt32 currentChannel = 0;
    
    for (UInt32 i=0; i<inData->mNumberBuffers; i++) {
        
        UInt32 numChannels = inData->mBuffers[i].mNumberChannels;
        UInt32 numSamples = inData->mBuffers[i].mDataByteSize / sizeof(AudioSampleType);
        AudioSampleType *samples = inData->mBuffers[i].mData;

        for (UInt32 i=0; i<numSamples; i++) {
            
            for (UInt32 j=0; j<numChannels; j++) {
                
                AudioSampleType curSample = abs((AudioSampleType)samples[i]);
                ioRecorder->_avgSamples[currentChannel+j] += curSample;
                
                if (ioRecorder->_peakSamples[currentChannel+j] < curSample) {
                    ioRecorder->_peakSamples[currentChannel+j] = curSample;
                }
                
                i++;
            }
        }
        
        
        for (UInt32 i=0; i<numChannels; i++) {
            ioRecorder->_avgSamples[currentChannel] /= numSamples;
            
            currentChannel++;
        }
    }
}


static inline void applyGain(TORecorder *inRecorder, AudioBufferList *ioData)
{
    for (UInt32 i=0; i<ioData->mNumberBuffers; i++) {
        
        UInt32 numSamples = ioData->mBuffers[i].mDataByteSize / sizeof(AudioSampleType);
        AudioSampleType *samples = ioData->mBuffers[i].mData;
        
        for (UInt32 i=0; i<numSamples; i++) {
            samples[i] *= inRecorder->_gain;
        }
    }
}


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
    
    // gain
    applyGain(recorder, ioData);
    
    
    // write the rendered audio into a file
    if (recorder->_isRecording) {
        TOThrowOnError(writeBufferToFile(recorder, ioData));
    }

    
    // calculate peak and average
    if (recorder->_sampleUpdateNeeded) {
        calculateAvgAndPeakSamples(recorder, ioData);
        recorder->_sampleUpdateNeeded = NO;
    }
	

    // silence output
    if (!recorder->_monitoringInput) {
        *ioActionFlags |= kAudioUnitRenderAction_OutputIsSilence;
        
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


- (double)peakPowerForChannel:(NSInteger)channelNumber
{
    if (channelNumber > self.numChannels || !self.isSetUp) {
        return 0.0;
    }
    
    _sampleUpdateNeeded = YES;
    
    // NOTE: assume that AudioSampleType is a 16bit signed integer
    return 10.0 * log10((double)_peakSamples[channelNumber] / INT16_MAX);
}


- (double)averagePowerForChannel:(NSInteger)channelNumber
{
    if (channelNumber > self.numChannels || !self.isSetUp) {
        return 0.0;
    }
    
    _sampleUpdateNeeded = YES;
    
    // NOTE: assume that AudioSampleType is a 16bit signed integer
    return 10.0 * log10(_avgSamples[channelNumber] / INT16_MAX);
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
    if (self.isSetUp) {
        return;
    }
    
    self.gain = 1.0;
    
    // Set up ASBD
    _numChannels = [[AVAudioSession sharedInstance] inputNumberOfChannels];
    
    if (self.numChannels == 1) {
        _asbd = TOCanonicalMonoLPCM();
    }
    else {
        _asbd = TOCanonicalStereoLPCM();
    }
    
    
    // allocate memory for peak an average samples
    _avgSamples = malloc(sizeof(AudioSampleType) * _numChannels);
    _peakSamples = malloc(sizeof(AudioSampleType) * _numChannels);
    

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
        
        free(_avgSamples);
        free(_peakSamples);
    }
}

@end
