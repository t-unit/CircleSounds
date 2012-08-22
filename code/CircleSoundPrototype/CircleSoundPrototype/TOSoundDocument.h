//
//  TOSoundDocument.h
//  CircleSoundPrototype
//
//  Created by Tobias Ottenweller on 22.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class TOPlugableSound;


@interface TOSoundDocument : NSObject

@property (readonly, nonatomic) NSArray *plugableSounds;

@property (readonly, nonatomic) double currentPlaybackPos; // in seconds

@property (readonly, nonatomic) AudioTimeStamp currentAudioTimeStamp;

@property (readonly, nonatomic) double graphSampleRate;


- (void)addPlugableSoundsObject:(TOPlugableSound *)soundObject;


- (void)start;
- (void)stop;
- (void)reset;

@end
