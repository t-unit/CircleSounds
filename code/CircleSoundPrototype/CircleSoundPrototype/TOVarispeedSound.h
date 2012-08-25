//
//  TOVarispeed.h
//  VarispeedTest
//
//  Created by Tobias Ottenweller on 20.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOFilePlayerSound.h"


@interface TOVarispeedSound : TOFilePlayerSound
{
    TOAudioUnit *_varispeedUnit;
    NSTimeInterval _realFilePlayerStartTime;
    
    AudioUnitParameterValue _playbackRate;
}

@property (assign, nonatomic) AudioUnitParameterValue playbackRate;

@end
