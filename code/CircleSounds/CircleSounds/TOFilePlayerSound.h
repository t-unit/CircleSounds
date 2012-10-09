//
//  TOAudioFilePlayer.h
//  FilePlayerTest
//
//  Created by Tobias Ottenweller on 21.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOPlugableSound.h"

#import <AudioToolbox/AudioToolbox.h>

#import "TOAudioUnit.h"
#import "TOCAShortcuts.h"


/**
 Wrapper for the 'kAudioUnitSubType_AudioFilePlayer' audio unit.
 */
@interface TOFilePlayerSound : TOPlugableSound
{
    TOAudioUnit *_filePlayerUnit;
    AudioFileID _audioFile;
    
    Float64 _currentFilePlayerUnitRenderSampleTime; /* NaN if invalid */
    Float64 _filePlayerUnitOutputSampleRate;
    
    // audio file properties
    AudioStreamBasicDescription _audioFileASBD;
    UInt64 _audioFileNumPackets;
    
    NSTimeInterval _regionStart;
    NSTimeInterval _regionDuration;
    UInt32 _loopCount;
    NSTimeInterval _startTime;
    
    BOOL _filePlayerUnitFullyInitialized;
}


- (BOOL)setAudioFileURL:(NSURL *)url error:(NSError **)error;
@property (readonly, nonatomic) NSURL *audioFileURL;


/**
 Length of the audio file in seconds.
 */
@property (readonly, nonatomic) Float64 fileDuration;


/*
 Properties read from the ID3-tag of the audio file.
 Might return nil if information is not availible.
 **/
@property (readonly, nonatomic) NSString *fileSongName;
@property (readonly, nonatomic) NSString *fileSongArtist;


/**
 Start in seconds of the region of the file selected. 
 */
@property (assign, nonatomic) NSTimeInterval regionStart;


/**
 Number of seconds that should be played back.
 */
@property (assign, nonatomic) NSTimeInterval regionDuration;


/**
 Number of times the audio file should be replayed.
 0: no looping. -1: endless looping
 */
@property (assign, nonatomic) UInt32 loopCount;


/**
 Seconds before the selected file region begins to play.
 Count starts at the beginning of the document.
 */
@property (assign, nonatomic) NSTimeInterval startTime;


@end
