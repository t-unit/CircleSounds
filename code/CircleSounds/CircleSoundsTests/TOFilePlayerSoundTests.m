//
//  TOFilePlayerSoundTests.m
//  CircleSounds
//
//  Created by Tobias Ottenweller on 22.10.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOFilePlayerSoundTests.h"
#import "TOSoundDocument.h"


@implementation TOFilePlayerSoundTests

- (void)setUp
{
    [super setUp];
    
    sound = [[TOMocFilePlayerSound alloc] init];
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


- (void)testAudioFile
{
    NSURL *validURL = [[NSBundle mainBundle] URLForResource:@"clong-1" withExtension:@"wav"];
    NSURL *invalidURL = [[NSBundle mainBundle] URLForResource:@"InfoPlist" withExtension:@"strings"];
    NSError *error = nil;
    
    BOOL success = [sound setAudioFileURL:validURL error:&error];
    STAssertNil(error, @"there should not be an error object if we supply a valid audio file URL");
    STAssertTrue(success, @"setAudioFileURL should return 'YES' if we supply a valid audio file URL");
    STAssertEqualObjects(validURL, [sound audioFileURL], @"getting the audio file URL should return the same URL  that has been set earlier");
    STAssertTrue([sound audioFile] != NULL, @"the audio file id should not be NULL after an URL has been set");
    
    success = [sound setAudioFileURL:invalidURL error:&error];
    STAssertNotNil(error, @"there should be an error object when setting a invalid audio file 'URL'");
    STAssertFalse(success, @"setting a invalid audio file 'URL' should return 'NO'");
    STAssertFalse([invalidURL isEqual:[sound audioFileURL]], @"a invalid audio file 'URL' should not be used internally");
    
}


- (void)testFileDuration
{
    STAssertEquals((Float64)0, [sound fileDuration], @"with no audio file set the sound object should return '0' as file duration");
    
    [self setAudioFileURL];
    STAssertFalse(0 == [sound fileDuration], @"with no audio file set the sound object should return '0' as file duration");
}


- (void)testAudioUnitCreation
{
    TOSoundDocument *document = [[TOSoundDocument alloc] init];
    [self setAudioFileURL];
    
    [document addPlugableSoundObject:sound];
    STAssertNotNil(sound.filePlayerUnit, @"after the plugable sound has been added to the document it should have been initialized");
    STAssertFalse(sound.filePlayerUnit->unit == NULL, @"the actual audio unit should not be NULL");
    
    STAssertTrue([sound.audioUnits containsObject:sound.filePlayerUnit], @"the created audio unit should be inside the audio unit array");
}

@end
