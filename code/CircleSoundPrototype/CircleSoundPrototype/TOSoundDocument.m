//
//  TOSoundDocument.m
//  CircleSoundPrototype
//
//  Created by Tobias Ottenweller on 22.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOSoundDocument.h"
#import <AVFoundation/AVFoundation.h>

#define GRAPH_SAMPLE_RATE 44100.0


@implementation TOSoundDocument


#pragma mark - Audio Callbacks


#pragma mark - Audio Session

- (void)setupAudioSession
{
    NSError *error = nil;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    [session setActive:YES error:&error];
    
    [session setPreferredSampleRate:GRAPH_SAMPLE_RATE error:&error];
    [[AVAudioSession sharedInstance] setPreferredIOBufferDuration:1024.0/GRAPH_SAMPLE_RATE error:&error];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAudioInterruption:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:session];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAudioRouteChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:session];
    
}


- (void)handleAudioInterruption:(NSNotification *)note
{
    
}


- (void)handleAudioRouteChange:(NSNotification *)note
{
    
}


# pragma mark - Start, Stop and Restart

- (void)start
{
    
}


- (void)stop
{
    
}


- (void)reset
{
    
}


# pragma mark - Property Setter and Getter

- (double)graphSampleRate
{
    return GRAPH_SAMPLE_RATE;
}


@end
