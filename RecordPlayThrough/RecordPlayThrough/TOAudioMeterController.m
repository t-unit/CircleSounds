//
//  TOAudioMeterController.m
//  RecordPlayThrough
//
//  Created by Tobias Ottenweller on 11.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOAudioMeterController.h"
#import "TOAudioMeterView.h"


@implementation TOAudioMeterController


- (void)setNeedsUpdateWithBuffer:(AudioBuffer)buffer
{
    // TODO: what to do with multichannel buffers!

    UInt32 numSamples = buffer.mDataByteSize / sizeof(AudioSampleType);
    AudioSampleType *samples = buffer.mData;
    
    AudioSampleType maxValue = 0.0;
    
    for (UInt32 i=0; i<numSamples; i++) {
        AudioSampleType sample = samples[i];
        
        if (sample < 0) {
            sample = -sample;
        }
        
        if (sample > maxValue) {
            maxValue = sample;
        }
    }
    
    self.audioMeterView.value = 1.0 / self.normalizedMax * maxValue;
}

@end
