//
//  TOVarispeedSoundTests.m
//  CircleSounds
//
//  Created by Tobias Ottenweller on 22.10.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOVarispeedSoundTests.h"
#import "TOSoundDocument.h"


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
    
    [sound setPlaybackRate:0.25];
    STAssertEquals(sound.actualStartTime, 0.25, @"if the playback speed is 0.25 the startime should be start time should be 0.25");
}


- (void)testAudioUnitCreation
{
    TOSoundDocument *document = [[TOSoundDocument alloc] init];
    [self setAudioFileURL];
    
    [document addPlugableSoundObject:sound];
    STAssertNotNil(sound.varispeedUnit, @"after the plugable sound has been added to the document it should have been initialized");
    STAssertFalse(sound.varispeedUnit->unit == NULL, @"the actual audio unit should not be NULL");
    
    STAssertTrue([sound.audioUnits containsObject:sound.varispeedUnit], @"the created audio unit should be inside the audio unit array");
}

@end
