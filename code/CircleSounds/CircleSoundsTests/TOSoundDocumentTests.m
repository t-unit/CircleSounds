//
//  TOSoundDocumentTests.m
//  CircleSounds
//
//  Created by Tobias Ottenweller on 22.10.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOSoundDocumentTests.h"

#import <AudioToolbox/AudioToolbox.h>
#import "TOAudioUnit.h"
#import "TOFilePlayerSound.h"


@implementation TOSoundDocumentTests

- (void)setUp
{
    [super setUp];
    
    document = [[TOMocSoundDocument alloc] init];
}


- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}


- (TOPlugableSound *)newPlugableSound
{
    TOFilePlayerSound *sound = [[TOFilePlayerSound alloc] init];
    [sound setAudioFileURL:[[NSBundle mainBundle] URLForResource:@"clong-1" withExtension:@"wav"] error:nil]; // NOTE: no error handling here!
    
    return sound;
}


- (void)testAudioUnitsAreInitialized
{
    STAssertNotNil(document.mixerUnit, @"after the document  has been created the mixer unit should have been initialized");
    STAssertFalse(document.mixerUnit->unit == NULL, @"the actual mixer audio unit should not be NULL");
    
    STAssertNotNil(document.rioUnit, @"after the document  has been created the output unit should have been initialized");
    STAssertFalse(document.rioUnit->unit == NULL, @"the actual output audio unit should not be NULL");
}


- (void)testGraphExists
{
    STAssertFalse(document.graph == NULL, @"the graph inside the document should not be NULL");
}


- (void)testGraphIsInitialized
{
    Boolean graphIsInitialized;
    STAssertTrue(AUGraphIsInitialized(document.graph, &graphIsInitialized) == noErr, @"asking the graph if it is initialized should not return an error");
    STAssertTrue(graphIsInitialized, @"the graph inside the document should be initialized");
}


- (void)testGraphIsOpen
{
    Boolean graphIsOpen;
    STAssertTrue(AUGraphIsOpen(document.graph, &graphIsOpen) == noErr, @"asking the graph if it is open should not return an error");
    STAssertTrue(graphIsOpen, @"the graph inside the document should be open");
}


- (void)testStartingAndPausingPlayback
{
    Boolean graphIsRunning;
    
    STAssertFalse(document.isRunning, @"the document should not be running at this point");
    STAssertTrue(AUGraphIsRunning(document.graph, &graphIsRunning) == noErr, @"asking the graph if it is running should not return any error");
    STAssertFalse(graphIsRunning, @"the graph should not be running at this point");
    
    [document start];
    
    STAssertTrue(document.isRunning, @"the document should be running at this point");
    STAssertTrue(AUGraphIsRunning(document.graph, &graphIsRunning) == noErr, @"asking the graph if it is running should not return any error");
    STAssertTrue(graphIsRunning, @"the graph should be running at this point");
    
    [document pause];
    
    STAssertFalse(document.isRunning, @"the document should not be running at this point");
    STAssertTrue(AUGraphIsRunning(document.graph, &graphIsRunning) == noErr, @"asking the graph if it is running should not return any error");
    STAssertFalse(graphIsRunning, @"the graph should not be running at this point");
    
}


- (void)testDocumentReset
{    
    [document start];
    usleep(1000000);
    [document pause];

    STAssertFalse(document.prePausePlaybackPosition == 0, @"there should be prePausePlaybackPosition set after pausing");
    
    [document reset];
    
    STAssertTrue(isnan(document.startSampleTime), @"after reseting the startSampleTime should be NAN");
}


- (void)testMixerInputBusUsage
{
    STAssertTrue(document.maxBusTaken == -1, @"if no plugable sound is added to the document the max bus taken ivar should be -1");
    
    
    TOPlugableSound *sound1 = [self newPlugableSound];
    [document addPlugableSoundObject:sound1];
    
    STAssertTrue(document.maxBusTaken == 0, @"after adding one sound the maximum bus taken should be 0");

//    // testing the number of input buses at the mixer unit does not work – the minimum of buses used internally seems to be 8
//    UInt32 numBuses;
//    size_t size = sizeof(numBuses);
//    
//    OSStatus status = AudioUnitGetProperty(document.mixerUnit->unit,
//                                           kAudioUnitProperty_ElementCount,
//                                           kAudioUnitScope_Input,
//                                           0,
//                                           &numBuses,
//                                           &size);
//    
//    STAssertTrue(status == noErr, @"asking the mixer unit for the number of input should not return any error");
//    STAssertEquals(numBuses, (UInt32)1, @"at this point there should be only one input bus");
    
    
    TOPlugableSound *sound2 = [self newPlugableSound];
    [document addPlugableSoundObject:sound2];
    
    STAssertTrue(document.maxBusTaken == 1, @"after adding two sound the maximum bus taken should be 1");
    
//    // testing the number of input buses at the mixer unit does not work – the minimum of buses used internally seems to be 8
//    UInt32 numBuses;
//    size_t size = sizeof(numBuses);
//
//    OSStatus status = AudioUnitGetProperty(document.mixerUnit->unit,
//                                           kAudioUnitProperty_ElementCount,
//                                           kAudioUnitScope_Input,
//                                           0,
//                                           &numBuses,
//                                           &size);
//
//    STAssertTrue(status == noErr, @"asking the mixer unit for the number of input should not return any error");
//    STAssertEquals(numBuses, (UInt32)2, @"at this point there should be two input buses");
}


- (void)testAddingAndRemovingPlugableSounds
{
    TOPlugableSound *sound = [self newPlugableSound];
    STAssertNoThrow([document addPlugableSoundObject:sound], @"no exception should be thrown when adding a sound to a document");
    STAssertThrows([document addPlugableSoundObject:sound], @"an exception should be thrown when adding a sound to a document twice");
    STAssertEqualObjects(sound, [document.plugableSounds lastObject], @"the added sound should be part of the document");
    
    [document removePlugableSoundObject:sound];
    STAssertFalse([document.plugableSounds containsObject:sound], @"after removing a sound it should not be part of the document anymore");
}


@end
