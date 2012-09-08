//
//  TOCAShortcuts.h
//  RecordPlayThrough
//
//  Created by Tobias Ottenweller on 08.07.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>


#define kOutputBus 0 /* the output bus of an IO Unit */
#define kInputBus 1 /* the input bus of an IO Unit */


///---------------------------------------------------------------------------------------
/// Error Handling
///---------------------------------------------------------------------------------------

extern NSString *kTOErrorInfoStringKey;
extern NSString *kTOErrorStatusStringKey;


/** 
 Error handling wraper for functions returning OSStatus.
 The function will create an NSError object if 'status' is anything else but 'noErr'.
 
 'error' should be a pointer of pointer of a NSError object. The error object should be 
 nil when supplied. If status is not 'noErr' an NSError will be created contain two value 
 pairs inside the 'userInfo' dictionary:
 
    - 'kTOErrorInfoStringKey': the supplied errorInfo string
    - 'kTOErrorStatusStringKey': a string representation of the error code
 
 This function will raise an exeception if error is nil.
 
 'errorInfo' needs to be a string object used for additional information about the 
 operation where the error occured. Supplying 'nil' is OK.
*/
void TOErrorHandler(OSStatus status, NSError *__autoreleasing *error, NSString *errorInfo);



/** 
 Exception throwing handler for function returning OSStatus.
 The function will throw an NSException if status is anything else then noErr.
*/
void TOThrowOnError(OSStatus status);



///---------------------------------------------------------------------------------------
/// Convinience Audio Object Creation
///---------------------------------------------------------------------------------------


/**
 Convenience functions returning an ASBD filled with an easy to handle
 linear PCM format. The canonical PCM formats for this project.
 The implementation is based on the C++ class 'CAStreamBasicDescription'
 availbible inside the 'iPublicUtility' published by Apple.
*/

AudioStreamBasicDescription TOCanonicalStreamFormat(UInt32 nChannels, bool interleaved);

AudioStreamBasicDescription TOCanonicalAUGraphStreamFormat(UInt32 nChannels, bool interleaved);



/**
 Creates a AudioComponentDescription based on 'componentType' and 'componentSubType'. 
 'componentManufacturer' will be assumed to be 'kAudioUnitManufacturer_Apple'. Both 
 'componentFlagsMask' and 'componentFlags' will be assumed '0'.
*/
AudioComponentDescription TOAudioComponentDescription(OSType componentType, OSType componentSubType);



/**
 Creates a new Audio Unit using 'inComponentDesc'. An audio component can be obtained by supplying
 a pointer. But supplying 'NULL' is OK.
 */
OSStatus TOAudioUnitNewInstanceWithDescription(AudioComponentDescription inComponentDesc, AudioComponent *outComponent, AudioUnit *outAudioUnit);


OSStatus TOAudioUnitNewInstance(OSType inComponentType, OSType inComponentSubType, AudioUnit *outAudioUnit);


OSStatus TOAUGraphAddNode(OSType inComponentType, OSType inComponentSubType, AUGraph inGraph, AUNode *outNode);



///---------------------------------------------------------------------------------------
/// Printing Functions
///---------------------------------------------------------------------------------------


void TOPrintASBD(AudioStreamBasicDescription asbd);



///---------------------------------------------------------------------------------------
/// Convinience Audio File Funtions
///---------------------------------------------------------------------------------------


/**
 Reads metadata from an audio file using the AudioFile API.
 See documentation of 'kAudioFilePropertyInfoDictionary' for
 availible keys inside the returned dictionary.
 
 This function will return 'nil if the supplied URL does
 not point to a valid audio file or if any other error 
 occures.
 */
NSDictionary *TOMetadataForAudioFileURL(NSURL *url);









