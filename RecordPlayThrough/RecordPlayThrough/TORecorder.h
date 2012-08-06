//
//  TORecorder.h
//  RecordPlayThrough
//
//  Created by Tobias Ottenweller on 08.07.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "TOCAShortcuts.h"

@protocol TORecorderDelegate;


@interface TORecorder : NSObject

/** 
 * Boolean defining wether current signals from the input should be played via output.
 */
@property (readwrite, atomic) BOOL monitorInput;

//@property (assign, atomic) <some_type> monitorVolume;
//@property (assign, atomic) <some_type> recordingVolume;

- (void)prepareForRecordingWithFileURL:(NSURL *)url;

- (void)startRecording;
- (void)stopRecording;

@end