//
//  TOAudioMeterController.h
//  RecordPlayThrough
//
//  Created by Tobias Ottenweller on 11.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@class TOAudioMeterView;


@interface TOAudioMeterController : NSObject

@property (weak, nonatomic) TOAudioMeterView *audioMeterView;
@property (assign, nonatomic) AudioSampleType normalizedMax;

- (void)setNeedsUpdateWithBuffer:(AudioBuffer)buffer;

@end
