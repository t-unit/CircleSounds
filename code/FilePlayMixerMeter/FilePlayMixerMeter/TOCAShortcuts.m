//
//  TOCAShortcuts.m
//  RecordPlayThrough
//
//  Created by Tobias Ottenweller on 08.07.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOCAShortcuts.h"
#import "NSString+OSStatus.h"

NSString *kTOErrorInfoStringKey = @"kTOErrorInfoStringKey";
NSString *kTOErrorStatusStringKey = @"kTOErrorStatusStringKey";


void TOErrorHandler(OSStatus status, NSError *__autoreleasing *error, NSString *errorInfo)
{
    if (!error) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"point to error is nil"
                                     userInfo:nil];
    }
    
    if (status == noErr) {
        return;
    }
    
    *error = [[NSError alloc] initWithDomain:@"TOAudioErrorDomain"
                                        code:status
                                    userInfo:@{ kTOErrorInfoStringKey : errorInfo?errorInfo:[NSNull null],
                                                kTOErrorStatusStringKey : [NSString stringWithOSStatus:status] } ];
}


void TOThrowOnError(OSStatus status)
{
    if (status != noErr) {
        @throw [NSException exceptionWithName:@"TOAudioErrorException"
                                       reason:[NSString stringWithFormat:@"Status is not 'noErr'! Status is %@ (%ld).", [NSString stringWithOSStatus:status], status]
                                     userInfo:nil];
    }
}



AudioStreamBasicDescription TOCanonicalStereoLPCM()
{
    AudioStreamBasicDescription asbd;
    memset (&asbd, 0, sizeof (asbd));
	asbd.mSampleRate = 44100;
	asbd.mFormatID = kAudioFormatLinearPCM;
	asbd.mFormatFlags = kAudioFormatFlagsCanonical;
	asbd.mBytesPerPacket = 4;
	asbd.mFramesPerPacket = 1;
	asbd.mBytesPerFrame = 4;
	asbd.mChannelsPerFrame = 2;
	asbd.mBitsPerChannel = 16;

    return asbd;
}


AudioStreamBasicDescription TOCanonicalMonoLPCM()
{
    AudioStreamBasicDescription asbd;
    memset (&asbd, 0, sizeof (asbd));
	asbd.mSampleRate = 44100;
	asbd.mFormatID = kAudioFormatLinearPCM;
	asbd.mFormatFlags = kAudioFormatFlagsCanonical;
	asbd.mBytesPerPacket = 2
    ;
	asbd.mFramesPerPacket = 1;
	asbd.mBytesPerFrame = 2;
	asbd.mChannelsPerFrame = 1;
	asbd.mBitsPerChannel = 16;
    
    return asbd;
}


AudioComponentDescription TOAudioComponentDescription(OSType componentType, OSType componentSubType)
{
    AudioComponentDescription desc;
	desc.componentType = componentType;
	desc.componentSubType = componentSubType;
	desc.componentFlags = 0;
	desc.componentFlagsMask = 0;
	desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    return desc;
}


OSStatus TOAudioUnitNewInstanceWithDescription(AudioComponentDescription inComponentDesc, AudioComponent *outComponent, AudioUnit *outAudioUnit)
{
    // Get component
	AudioComponent component = AudioComponentFindNext(NULL, &inComponentDesc);
	
	// Get audio unit
	OSStatus status = AudioComponentInstanceNew(component, outAudioUnit);
    
    if (outComponent) {
        outComponent = &component;
    }

    return status;
}


OSStatus TOAudioUnitNewInstance(OSType inComponentType, OSType inComponentSubType, AudioUnit *outAudioUnit)
{
    AudioComponentDescription desc = TOAudioComponentDescription(inComponentType, inComponentSubType);
    return TOAudioUnitNewInstanceWithDescription(desc, NULL, outAudioUnit);
}


OSStatus TOAUGraphAddNode(OSType inComponentType, OSType inComponentSubType, AUGraph inGraph, AUNode *outNode)
{
    AudioComponentDescription desc = TOAudioComponentDescription(inComponentType, inComponentSubType);
    return AUGraphAddNode(inGraph, desc, outNode);
}

