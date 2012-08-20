//
//  TOVarispeed.h
//  VarispeedTest
//
//  Created by Tobias Ottenweller on 20.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>


@interface TOVarispeed : NSObject
{
    AUGraph graph;
    
    AudioUnit filePlayerUnit;
    AudioUnit varispeedUnit;
    AudioUnit rioUnit;
    
    AudioFileID audioFile;
}

@property (assign, nonatomic) AudioUnitParameterValue playbackRate;
@property (assign, nonatomic) AudioUnitParameterValue playbackCents;


@end
