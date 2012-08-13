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

    
    int sum = 0;
    for (int i=0; i<numSamples; i++) {
        sum += abs((int) samples[i]);
    }
    
    int averageVolume = sum / numSamples;

    
    // now convert to logarithm and scale log10(0->32768) into 0->1 for display
    float logVolume = log10f( (float) averageVolume );
    logVolume = logVolume / log10(32768);
    
    self.audioMeterView.value = logVolume;
}

@end
