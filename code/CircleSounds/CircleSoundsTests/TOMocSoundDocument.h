//
//  TOMocSoundDocument.h
//  CircleSounds
//
//  Created by Tobias Ottenweller on 28.10.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOSoundDocument.h"

@interface TOMocSoundDocument : TOSoundDocument

@property (strong, nonatomic) TOAudioUnit *mixerUnit;
@property (strong, nonatomic) TOAudioUnit *rioUnit;

@property (assign, nonatomic) AUGraph graph;

@property (assign, nonatomic) NSTimeInterval prePausePlaybackPosition;
@property (assign, nonatomic) Float64 startSampleTime;

@property (assign, nonatomic) UInt32 maxBusTaken;

@end
