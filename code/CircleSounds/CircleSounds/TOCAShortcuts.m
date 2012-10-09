//
//  TOCAShortcuts.m
//  RecordPlayThrough
//
//  Created by Tobias Ottenweller on 08.08.12.
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
                                    userInfo:@{ kTOErrorInfoStringKey : errorInfo ? errorInfo : [NSNull null],
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


AudioStreamBasicDescription TOCanonicalStreamFormat(UInt32 nChannels, bool interleaved)
{
    AudioStreamBasicDescription asbd;
    memset (&asbd, 0, sizeof (asbd));
    
    asbd.mFormatID = kAudioFormatLinearPCM;
    UInt32 sampleSize = (UInt32)sizeof(AudioSampleType);
    asbd.mFormatFlags = kAudioFormatFlagsCanonical;
    asbd.mBitsPerChannel = 8 * sampleSize;
    asbd.mChannelsPerFrame = nChannels;
    asbd.mFramesPerPacket = 1;
    asbd.mSampleRate = 44100;
    
    if (interleaved) {
        asbd.mBytesPerPacket = asbd.mBytesPerFrame = nChannels * sampleSize;
    }
    else {
        asbd.mBytesPerPacket = asbd.mBytesPerFrame = sampleSize;
        asbd.mFormatFlags |= kAudioFormatFlagIsNonInterleaved;
    }
    
    return asbd;
}


AudioStreamBasicDescription TOCanonicalAUGraphStreamFormat(UInt32 nChannels, bool interleaved)
{
    AudioStreamBasicDescription asbd;
    memset(&asbd, 0, sizeof (asbd));
    
    asbd.mFormatID = kAudioFormatLinearPCM;
#if CA_PREFER_FIXED_POINT
    asbd.mFormatFlags = kAudioFormatFlagsCanonical | (kAudioUnitSampleFractionBits << kLinearPCMFormatFlagsSampleFractionShift);
#else
    asbd.mFormatFlags = kAudioFormatFlagsCanonical;
#endif
    asbd.mChannelsPerFrame = nChannels;
    asbd.mFramesPerPacket = 1;
    asbd.mBitsPerChannel = 8 * (UInt32)sizeof(AudioUnitSampleType);
    asbd.mSampleRate = 44100;
    
    if (interleaved) {
        asbd.mBytesPerPacket = asbd.mBytesPerFrame = nChannels * (UInt32)sizeof(AudioUnitSampleType);
    }
    else {
        asbd.mBytesPerPacket = asbd.mBytesPerFrame = (UInt32)sizeof(AudioUnitSampleType);
        asbd.mFormatFlags |= kAudioFormatFlagIsNonInterleaved;
    }
    
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
    return AUGraphAddNode(inGraph, &desc, outNode);
}


void TOPrintASBD(AudioStreamBasicDescription asbd)
{
    char formatIDString[5];
    UInt32 formatID = CFSwapInt32HostToBig (asbd.mFormatID);
    bcopy (&formatID, formatIDString, 4);
    formatIDString[4] = '\0';

    printf("Sample Rate:         %10.0f\n",   asbd.mSampleRate);
    printf("Format ID:           %10s\n",     formatIDString);
    printf("Format Flags:        %10lX\n",    asbd.mFormatFlags);
    printf("Bytes per Packet:    %10ld\n",    asbd.mBytesPerPacket);
    printf("Frames per Packet:   %10ld\n",    asbd.mFramesPerPacket);
    printf("Bytes per Frame:     %10ld\n",    asbd.mBytesPerFrame);
    printf("Channels per Frame:  %10ld\n",    asbd.mChannelsPerFrame);
    printf("Bits per Channel:    %10ld\n",    asbd.mBitsPerChannel);
}


NSDictionary *TOMetadataForAudioFileAtURL(NSURL *url)
{
    AudioFileID audioFile;
    OSStatus error = noErr;
    
    
    error = AudioFileOpenURL((__bridge CFURLRef)url,
                             kAudioFileReadPermission,
                             0,
                             &audioFile);
    
    if (error != noErr) {
        return nil;
    }
    
    
    UInt32 dictionarySize = 0;
    error = AudioFileGetPropertyInfo(audioFile,
                                     kAudioFilePropertyInfoDictionary,
                                     &dictionarySize,
                                     0);
    
    if (error != noErr) {
        AudioFileClose(audioFile);
        return nil;
    }
    
    
    CFDictionaryRef dictonary;
    error = AudioFileGetProperty(audioFile,
                                 kAudioFilePropertyInfoDictionary,
                                 &dictionarySize,
                                 &dictonary);
    
    if (error != noErr) {
        AudioFileClose(audioFile);
        return nil;
    }
    
    AudioFileClose(audioFile);
    
    
    return (__bridge NSDictionary *)(dictonary);
}



                            
                            
                            
                            

