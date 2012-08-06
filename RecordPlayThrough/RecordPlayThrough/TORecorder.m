//
//  TORecorder.m
//  RecordPlayThrough
//
//  Created by Tobias Ottenweller on 08.07.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TORecorder.h"

typedef struct {
    AudioUnit rioUnit;
    AudioStreamBasicDescription asbd;
    
} TORecorderState;


@interface TORecorder ()

@property (assign, readwrite) TORecorderState state;

@end

@implementation TORecorder


- (id)init
{
    self = [super init];
    
    if (self) {
//        kAudioOutputUnitProperty_ChannelMap
    }
    
    return self;
}


- (void)prepareForRecordingWithFileURL:(NSURL *)url
{
    
}


- (void)startRecording
{
    
}


- (void)stopRecording
{
    
}

@end
