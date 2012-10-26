//
//  TOVarispeedSoundTests.m
//  CircleSounds
//
//  Created by Tobias Ottenweller on 22.10.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOVarispeedSoundTests.h"

@implementation TOVarispeedSoundTests

- (void)setUp
{
    [super setUp];
    
    sound = [[TOMocVarispeedSound alloc] init];
}


- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}


- (void)setAudioFileURL
{
    [sound setAudioFileURL:[[NSBundle mainBundle] URLForResource:@"clong-1" withExtension:@"wav"]
                     error:nil]; // NOTE: no error handling here!
}


- (void)testStartTimeSetting
{
    [self setAudioFileURL];
    
    [sound setStartTime:1.0];
    STAssertEquals(sound.actualStartTime, 1.0, @"if the playback speed is 1.0 the startime should match the actual start time");
    
    [sound setPlaybackRate:2.0];
    STAssertEquals(sound.actualStartTime, 2.0, @"if the playback speed is 2.0 the startime should be start time times two");
}


@end
