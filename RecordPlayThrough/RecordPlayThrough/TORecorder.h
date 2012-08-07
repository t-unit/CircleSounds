//
//  TORecorder.h
//  RecordPlayThrough
//
//  Created by Tobias Ottenweller on 08.07.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@protocol TORecorderDelegate;


@interface TORecorder : NSObject

/** 
 * Boolean defining wether current signals from the input should be played via output.
 */
@property (readwrite, nonatomic, setter = setMonitorInput:) BOOL monitorInput;
@property (weak, nonatomic) id<TORecorderDelegate> delegate;
@property (readonly, nonatomic) NSURL *url;
@property (readonly, nonatomic) BOOL isRecording;

- (BOOL)prepareForRecordingWithFileURL:(NSURL *)url;

- (BOOL)startRecording;
- (void)stopRecording;

@end