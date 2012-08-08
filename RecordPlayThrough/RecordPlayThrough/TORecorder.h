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
 * Boolean defining wether current signals from the input should be played via output.
 */
@property (readwrite, atomic) BOOL isMonitoringInput;

@property (weak, nonatomic) id<TORecorderDelegate> delegate;
@property (readonly, nonatomic) NSURL *url;
@property (readonly, atomic) BOOL isRecording;

- (BOOL)prepareForRecordingWithFileURL:(NSURL *)url error:(NSError **)error;

- (BOOL)startRecording;
- (void)stopRecording;

- (void)setUp;
- (void)tearDown;

@end