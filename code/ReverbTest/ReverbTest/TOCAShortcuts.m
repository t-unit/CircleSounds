//
//  TOCAShortcuts.m
//  NewTimePitchTest
//
//  Created by Tobias Ottenweller on 08.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOCAShortcuts.h"
#import "NSString+OSStatus.h"


void TOThrowOnError(OSStatus status)
{
    if (status != noErr) {
        @throw [NSException exceptionWithName:@"TOAudioErrorException"
                                       reason:[NSString stringWithFormat:@"Status is not 'noErr'! Status is %@ (%d).", [NSString stringWithOSStatus:status], (int)status]
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
    memset (&asbd, 0, sizeof (asbd));
    
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

    printf("  Sample Rate:         %10.0f\n",   asbd.mSampleRate);
    printf("  Format ID:           %10s\n",     formatIDString);
    printf("  Format Flags:        %10X\n",    (unsigned int)asbd.mFormatFlags);
    printf("  Bytes per Packet:    %10u\n",    (unsigned int)asbd.mBytesPerPacket);
    printf("  Frames per Packet:   %10u\n",    (unsigned int)asbd.mFramesPerPacket);
    printf("  Bytes per Frame:     %10u\n",    (unsigned int)asbd.mBytesPerFrame);
    printf("  Channels per Frame:  %10u\n",    (unsigned int)asbd.mChannelsPerFrame);
    printf("  Bits per Channel:    %10u\n",    (unsigned int)asbd.mBitsPerChannel);
}

                                          
                                   
                            
                            
                            
                            

