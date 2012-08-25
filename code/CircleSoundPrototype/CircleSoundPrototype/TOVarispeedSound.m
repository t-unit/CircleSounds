//
//  TOVarispeed.m
//  VarispeedTest
//
//  Created by Tobias Ottenweller on 20.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOVarispeedSound.h"
#import "TOSoundDocument.h"


@implementation TOVarispeedSound

- (id)init
{
    self = [super init];
    
    if (self) {
        _varispeedUnit = [[TOAudioUnit alloc] init];
        _varispeedUnit->description = TOAudioComponentDescription(kAudioUnitType_FormatConverter, kAudioUnitSubType_Varispeed);
        
        _audioUnits = [_audioUnits arrayByAddingObject:_varispeedUnit];
        
        self.playbackRate = 1.0;
    }
    
    return self;
}


- (void)setupUnits
{
    [super setupUnits];
    [self applyPlaybackRate];
}


- (void)handleDocumentReset
{
    _startTime = [self calculateStartTime:self.startTime];
    [super handleDocumentReset];
}


#pragma mark - Varispeed Unit Parameter Wrapper Methods

- (void)setPlaybackRate:(AudioUnitParameterValue)playbackRate
{
    _playbackRate = playbackRate;
    self.startTime = self.startTime; /* this will call the setter which will set the correct start time */
    
    if (_varispeedUnit->unit) {
        [self applyPlaybackRate];
    }
}


- (void)applyPlaybackRate
{
    TOThrowOnError(AudioUnitSetParameter(_varispeedUnit->unit,
                                         kVarispeedParam_PlaybackRate,
                                         kAudioUnitScope_Global,
                                         0,
                                         self.playbackRate,
                                         0));

    [super setStartTime:[self calculateStartTime:_realFilePlayerStartTime]];

}


#pragma mark - Audio File Player Overwrite Methods

- (void)setStartTime:(NSTimeInterval)startTime
{
    _realFilePlayerStartTime = startTime;
    [super setStartTime:[self calculateStartTime:startTime]];
}


- (NSTimeInterval)startTime
{
    return _realFilePlayerStartTime;
}


/**
 Depending on the playback rate the varispeed unit will
 ask the file player for more or less samples during
 the same time. So the start time of the file player
 needs to be adjusted.
 */
- (NSTimeInterval)calculateStartTime:(NSTimeInterval)startTime
{
    NSTimeInterval currentTime = self.document.currentPlaybackPosition;
    NSTimeInterval offset =  startTime - currentTime;
    
    
    if (currentTime == 0.0) { // units getting reset {
        startTime *= self.playbackRate;
    }
    else if (offset < 0.0) {
        startTime += offset / self.playbackRate - offset;
    }
    else {
        startTime += offset * self.playbackRate - offset;
    }
    
    return startTime;
}

@end
