//
//  TORecorder.h
//  RecordPlayThrough
//
//  Created by Tobias Ottenweller on 08.07.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TORecorderDelegate;


@interface TORecorder : NSObject

/** 
 Boolean defining wether current signals from the input should be played via output.
 */
@property (readwrite, atomic) BOOL isMonitoringInput;


/**
 Returns the url set via 'prepareForRecordingWithURL:error:'. Does return garbage
 value before 'prepareForRecordingWithURL:error:' and after 'stopRecording' was 
 called.
 */
@property (readonly, nonatomic) NSURL *url;

@property (readonly, atomic) BOOL isRecording;
@property (weak, nonatomic) id<TORecorderDelegate> delegate;


/**
 Needs to be called before 'startRecording'. Returns 'YES' on success.
 Return 'NO' if recorder has not been 'setup' or some other error has occured.
 */
- (BOOL)prepareForRecordingWithFileURL:(NSURL *)url error:(NSError **)error;


/**
 Starts recording. Will return 'NO' and will not start recording if 
 'prepareForRecordingWithFileURL:error:' has not been called before.
 */
- (BOOL)startRecording;
- (void)stopRecording;


/**
 Needs to be called before any 'startRecording' and 'prepareForRecordingWithFileURL:error:'
 can be called. Enables monitoring.
 */
- (void)setUp;


/**
 Should be called after recording has been finished. Disables monitoring.
 */
- (void)tearDown;

@end