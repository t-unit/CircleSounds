//
//  TORecorderDelegate.h
//  RecordPlayThrough
//
//  Created by Tobias Ottenweller on 10.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TORecorder;


@protocol TORecorderDelegate <NSObject>

- (void)recorderDidStartRecording:(TORecorder *)recorder;
- (void)recorderDidStopRecording:(TORecorder *)recorder;

@end
