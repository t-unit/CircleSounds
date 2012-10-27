//
//  TOEqualizerSoundTests.m
//  CircleSounds
//
//  Created by Tobias Ottenweller on 22.10.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOEqualizerSoundTests.h"
#import "TOSoundDocument.h"

@implementation TOEqualizerSoundTests

- (void)setUp
{
    [super setUp];
    
    sound = [[TOMocEqualizerSound alloc] init];
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


- (void)testAudioUnitCreation
{
    TOSoundDocument *document = [[TOSoundDocument alloc] init];
    [self setAudioFileURL];
    
    [document addPlugableSoundObject:sound];
    STAssertNotNil(sound.equalizerUnit, @"after the plugable sound has been added to the document it should have been initialized");
    
    STAssertTrue([sound.audioUnits containsObject:sound.equalizerUnit], @"the created audio unit should be inside the audio unit array");
}

@end
