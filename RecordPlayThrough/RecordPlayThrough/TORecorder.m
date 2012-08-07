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
    
} TORecorderState;


@interface TORecorder ()

@property (assign, readwrite) TORecorderState state;
@property (assign, readwrite) BOOL readyForRecording;
@property (assign, readwrite) BOOL isSetUp;

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
    self->_url = url;
}


- (void)startRecording
{
    
}


- (void)stopRecording
{
    
}


- (void)setUp
{
    
}


- (void)tearDown
{
    
}


@end
