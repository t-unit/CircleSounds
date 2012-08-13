//
//  TORecorderDelegate.h
//  RecordPlayThrough
//
//  Created by Tobias Ottenweller on 10.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class TORecorder;


@protocol TORecorderDelegate <NSObject>

- (void)recorderDidStartRecording:(TORecorder *)recorder;
- (void)recorderDidStopRecording:(TORecorder *)recorder;
//- (void)recorder:(TORecorder *) recorder didGetNewData:(AudioBufferList *)bufferList;

@end
