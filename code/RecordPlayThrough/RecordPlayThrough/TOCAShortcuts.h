//
//  TOCAShortcuts.h
//  RecordPlayThrough
//
//  Created by Tobias Ottenweller on 08.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

extern NSString *kTOErrorInfoStringKey;
extern NSString *kTOErrorStatusStringKey;

#define kOutputBus 0
#define kInputBus 1


/*
 
 
 
    DO NOT USE THIS VERSION!!!!!!!!!!!!!!!!!
 
    (HAVE A LOOK AT FilePlayMixerMeter)
 
 
 */


///---------------------------------------------------------------------------------------
/// @name Error Handling
///---------------------------------------------------------------------------------------


/** Error handling wraper for functions returning OSStatus.
 
 The function will create an NSError object if 'status' is anything else but 'noErr'.
 
 @param status The status which should be checked for any error.
 
 @param error A pointer of pointer of a NSError object. The error object should be nil
        when supplied. If status is not 'noErr' an NSError will be created contain two 
        value pairs inside the 'userInfo' dictionary:
 
 - 'kTOErrorInfoStringKey': the supplied errorInfo string
 - 'kTOErrorStatusStringKey': a string representation of the error code
 
        The supplied pointer must not be nil.
 
 @param errorInfo String object used for additional information about the operation where 
        the error occured. Supplying 'nil' is OK.
 
 @exception This function will raise an exeception if error is nil.
*/
void TOErrorHandler(OSStatus status, NSError *__autoreleasing *error, NSString *errorInfo);



/** Exception throwing handler for function returning OSStatus.
 
 The function will throw an NSException if status is anything else then noErr.
 
 @param status The status which should be checked for any error.
 @exception NSException Thrown if the given status is not 'noErr'.
*/
void TOThrowOnError(OSStatus status);



///---------------------------------------------------------------------------------------
/// @name Convinience Audio Object Creation
///---------------------------------------------------------------------------------------


/**
 Convenience functions returning an ASBD filled with an easy to handle
 linear PCM format. The canonical PCM formats for this project.
*/

AudioStreamBasicDescription TOCanonicalStereoLPCM();
AudioStreamBasicDescription TOCanonicalMonoLPCM();



/**
 @function TOAudioComponentDescription
 
 @abstract Creates a AudioComponentDescription based on 'componentType' and 
           'componentSubType'. 'componentManufacturer' will be assumed to 
           be 'kAudioUnitManufacturer_Apple'. Both 'componentFlagsMask' and 
           'componentFlags' will be assumed '0'.
*/
AudioComponentDescription TOAudioComponentDescription(OSType componentType, OSType componentSubType);




OSStatus TOAudioUnitNewInstanceWithDescription(AudioComponentDescription inComponentDesc, AudioComponent *outComponent, AudioUnit *outAudioUnit);


OSStatus TOAudioUnitNewInstance(OSType inComponentType, OSType inComponentSubType, AudioUnit *outAudioUnit);





