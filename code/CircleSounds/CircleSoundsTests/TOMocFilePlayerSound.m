//
//  TOMocFilePlayerSound.m
//  CircleSounds
//
//  Created by Tobias Ottenweller on 26.10.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOMocFilePlayerSound.h"

@implementation TOMocFilePlayerSound

- (TOAudioUnit *)filePlayerUnit
{
    return _filePlayerUnit;
}


- (void)setFilePlayerUnit:(TOAudioUnit *)filePlayerUnit
{
    _filePlayerUnit = filePlayerUnit;
}


- (AudioFileID)audioFile
{
    return _audioFile;
}


- (void)setAudioFile:(AudioFileID)audioFile
{
    _audioFile = audioFile;
}

@end
