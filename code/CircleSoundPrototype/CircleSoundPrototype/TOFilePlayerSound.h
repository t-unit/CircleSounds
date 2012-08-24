//
//  TOAudioFilePlayer.h
//  FilePlayerTest
//
//  Created by Tobias Ottenweller on 21.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOPlugableSound.h"


@interface TOFilePlayerSound : TOPlugableSound
{
    TOAudioUnit *_filePlayerUnit;
    AudioFileID _audioFile;
    
    AudioTimeStamp _currentFilePlayerUnitRenderTimeStamp;
    Float64 _filePlayerUnitOutputSampleRate;
    
    // audio file properties
    AudioStreamBasicDescription _audioFileASBD;
    UInt64 _audioFileNumPackets;
    
}


- (BOOL)setAudioFileURL:(NSURL *)url error:(NSError **)error;
@property (readonly, nonatomic) NSURL *audioFileURL;


/**
 Length of the audio file in seconds.
 */
@property (readonly, nonatomic) double fileDuration;


/**
 Start in seconds of the region of the file selected. 
 */
@property (assign, nonatomic) double regionStart;


/**
 Number of seconds that should be played back.
 */
@property (assign, nonatomic) double regionDuration;


/**
 Number of times the audio file should be replayed.
 0: no looping. -1: endless looping
 */
@property (assign, nonatomic) UInt32 loopCount;


/**
 Seconds before the selected file region begins to play.
 Count starts at the beginning of the document.
 */
@property (assign, nonatomic) double startTime;


/**
 Apply the changes made. Needs to be called after the
 object has been added to the document. An exception might
 get thrown otherwise.
 */
- (BOOL)applyChanges:(NSError *__autoreleasing *)error;

@end
