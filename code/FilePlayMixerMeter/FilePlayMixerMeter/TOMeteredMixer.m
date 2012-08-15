//
//  TOMeteredMixer.m
//  FilePlayMixerMeter
//
//  Created by Tobias Ottenweller on 15.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOMeteredMixer.h"

#import <AudioToolbox/AudioToolbox.h>
#import "TOCAShortcuts.h"


@interface TOMeteredMixer ()
{
    AUGraph _graph;
    
    AudioUnit _rioUnit;
    AudioUnit _mixerUnit;
    AudioUnit _filePlayerUnit;
    
    AudioFileID _file;
}



@end


@implementation TOMeteredMixer


- (id)init
{
    self = [super init];
    
    if (self) {
        <#statements#>
    }
}


- (void)setUp
{
    // Create AUGraph
    TOThrowOnError(NewAUGraph(_graph));
    
    
    // Create AUNodes
    AUNode filePlayerNode;
    TOThrowOnError(TOAUGraphAddNode(kAudioUnitType_Generator, kAudioUnitSubType_AudioFilePlayer, _graph, &filePlayerNode));
    
    AUNode mixerNode;
    TOThrowOnError(TOAUGraphAddNode(kAudioUnitType_Mixer, kAudioUnitSubType_MultiChannelMixer, _graph, &mixerNode))
    
    AUNode rioNode;
    TOThrowOnError(TOAUGraphAddNode(kAudioUnitType_Output, kAudioUnitSubType_RemoteIO, _graph, &rioNode));
    
    
    // Open AUGraph
    TOThrowOnError(AUGraphOpen(_graph));
    
    
    // Get AudioUnits
    TOThrowOnError(AUGraphNodeInfo(_graph, filePlayerNode, NULL, &_filePlayerUnit));
    TOThrowOnError(AUGraphNodeInfo(_graph, mixerNode, NULL, &_mixerUnit));
    TOThrowOnError(AUGraphNodeInfo(_graph, rioNode, NULL, &_rioUnit));
    
    
    // Mixer Unit Property setup
    UInt32 meteringMode = 1; // enabled
    TOThrowOnError(AudioUnitSetProperty(_mixerUnit,
                                        kAudioUnitProperty_MeteringMode,
                                        kAudioUnitScope_Output,
                                        0,
                                        &meteringMode,
                                        sizeof(meteringMode)));
    
    
    // Connect AUNodes/AudioUnits
    TOThrowOnError(AUGraphConnectNodeInput(_graph, filePlayerNode, 0, mixerNode, 0));
}

@end
