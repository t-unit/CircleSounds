//
//  TOCAShortcuts.h
//  NewTimePitchTest
//
//  Created by Tobias Ottenweller on 08.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>


/** 
 Exception throwing handler for function returning OSStatus.
 Will throw an NSException if status is anything else then 'noErr'.
*/
void TOThrowOnError(OSStatus status);


AudioStreamBasicDescription TOCanonicalStreamFormat(UInt32 nChannels, bool interleaved);
AudioStreamBasicDescription TOCanonicalAUGraphStreamFormat(UInt32 nChannels, bool interleaved);


AudioComponentDescription TOAudioComponentDescription(OSType componentType, OSType componentSubType);


OSStatus TOAUGraphAddNode(OSType inComponentType, OSType inComponentSubType, AUGraph inGraph, AUNode *outNode);


void TOPrintASBD(AudioStreamBasicDescription asbd);





