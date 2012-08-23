//
//  TOVarispeed.h
//  VarispeedTest
//
//  Created by Tobias Ottenweller on 20.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOAudioFilePlayer.h"


@interface TOVarispeed : TOAudioFilePlayer
{
    TOAudioUnit *_varispeedUnit;
}

@property (assign, nonatomic) AudioUnitParameterValue playbackRate;
@property (assign, nonatomic) AudioUnitParameterValue playbackCents;

@end
