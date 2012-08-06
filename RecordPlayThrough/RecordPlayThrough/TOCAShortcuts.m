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
                                       reason:@"status is not 'noErr'"
                                     userInfo:@{ kTOErrorStatusStringKey : [NSString stringWithOSStatus:status] }];
    }
}



AudioStreamBasicDescription TOCanonicalLPCM()
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