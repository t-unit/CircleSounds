//
//  TOCAShortcutsTests.m
//  CircleSounds
//
//  Created by Tobias Ottenweller on 22.10.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOCAShortcutsTests.h"
#import "TOCAShortcuts.h"
#import "NSString+OSStatus.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation TOCAShortcutsTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}


- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}


- (void)testThrowOnError
{
    STAssertThrows(TOThrowOnError(!noErr), @"'TOThrowOnError' should throw an exception if supplied error code is not '0'");
    STAssertThrows(TOThrowOnError(-1), @"'TOThrowOnError' should throw an exception if supplied error code is not '0'");
    STAssertThrows(TOThrowOnError(1), @"'TOThrowOnError' should throw an exception if supplied error code is not '0'");
    STAssertThrows(TOThrowOnError(425234), @"'TOThrowOnError' should throw an exception if supplied error code is not '0'");
    STAssertThrows(TOThrowOnError(-1328934), @"'TOThrowOnError' should throw an exception if supplied error code is not '0'");
}


- (void)testThrowNotOnValidOperation
{
    STAssertNoThrow(TOThrowOnError(noErr), @"'TOThrowOnError' should not throw an exception if supplied error code is '0'");
}


- (void)testErrorHandlerWithNormalOperation
{
    NSError *error = nil;
    
    BOOL success = TOErrorHandler(noErr, &error, nil);
    STAssertTrue(success, @"'TOErrorHandler' should return 'YES' on success");
    STAssertNil(error, @"'TOErrorHandler' should not return an error object on sucess");
    
    
    success = TOErrorHandler(noErr, &error, @"testing error reason");
    STAssertTrue(success, @"'TOErrorHandler' should return 'YES' on success");
    STAssertNil(error, @"'TOErrorHandler' should not return an error object on sucess");
    
    
    success = TOErrorHandler(noErr, NULL, @"testing error reason");
    STAssertTrue(success, @"'TOErrorHandler' should return 'YES' on success");
}


- (void)testErrorHandlerOnError
{
    NSError *error = nil;
    
    BOOL success = TOErrorHandler(!noErr, NULL, nil);
    STAssertFalse(success, @"'TOErrorHandler' should return 'NO' on failure");
    
    int errorCode = 23;
    success = TOErrorHandler(errorCode, &error, nil);
    STAssertFalse(success, @"'TOErrorHandler' should return 'NO' on failure");
    STAssertNotNil(error, @"'TOErrorHandler' should return an error object on failure");
    STAssertEqualObjects([NSString stringWithOSStatus:errorCode], [[error userInfo] valueForKey:kTOErrorStatusStringKey], @"information inside the error's user info dictionary should match the supplied error status");
    
    NSString *errorInfoString = @"error info string";
    success = TOErrorHandler(-8976, &error, errorInfoString);
    STAssertFalse(success, @"'TOErrorHandler' should return 'NO' on failure");
    STAssertNotNil(error, @"'TOErrorHandler' should return an error object on failure");
    STAssertEqualObjects(errorInfoString, [[error userInfo] valueForKey:kTOErrorInfoStringKey], @"information inside the error's user info dictionary should match the supplied error info string");
    
}


- (void)testAudioComponentDescriptionCreation
{
    AudioComponentDescription description = TOAudioComponentDescription(kAudioUnitType_Generator, kAudioUnitSubType_AudioFilePlayer);
    
    STAssertEquals((OSType)kAudioUnitType_Generator, description.componentType, @"component type must match the supplied constant");
    STAssertEquals((OSType)kAudioUnitSubType_AudioFilePlayer, description.componentSubType, @"component subtype must match the supplied constant");
    STAssertEquals((OSType)kAudioUnitManufacturer_Apple, description.componentManufacturer, @"component manufacuterer match match apple");
    STAssertEquals((UInt32)0, description.componentFlags, @"flags must be '0'");
    STAssertEquals((UInt32)0, description.componentFlagsMask, @"flags mask must be '0'");
}


- (void)testAudioUnitNewInstanceWithDescription
{
    AudioComponentDescription description = TOAudioComponentDescription(kAudioUnitType_Generator, kAudioUnitSubType_AudioFilePlayer);
    AudioComponent component;
    AudioUnit unit;
    
    OSStatus status = TOAudioUnitNewInstanceWithDescription(description, &component, &unit);
    STAssertEquals((OSStatus)noErr, status, @"audio unit should have been created without an error");

    status = TOAudioUnitNewInstanceWithDescription(description, NULL, &unit);
    STAssertEquals((OSStatus)noErr, status, @"audio unit should have been created without an error");
    
    status = TOAudioUnitNewInstanceWithDescription(description, &component, NULL);
    STAssertFalse(status == noErr, @"audio unit should have been created without an error");
    
    STAssertEquals(AudioUnitInitialize(unit), (OSStatus)noErr, @"audio unit should have been initialized (this makes sure 'TOAudioComponentDescription' did return a valid audio unit");
    
}


- (void)testAudioUnitNewInstance
{
    AudioUnit unit;
    
    OSStatus status = TOAudioUnitNewInstance(kAudioUnitType_Generator, kAudioUnitSubType_AudioFilePlayer, &unit);
    STAssertEquals((OSStatus)noErr, status, @"a new audio unit instance should have been created");
    
    status = TOAudioUnitNewInstance(kAudioUnitType_Generator, 'ikhy', &unit); // invalid subtype!
    STAssertFalse(noErr == status, @"a new audio unit instance should have been created");
}


@end
