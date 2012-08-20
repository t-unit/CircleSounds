//
//  TOPitch.h
//  PitchTest
//
//  Created by Tobias Ottenweller on 20.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface TOTimePitch : NSObject
{
    AUGraph graph;
    
    AudioUnit filePlayerUnit;
    AudioUnit filePlayerPitchConverterUnit;
    AudioUnit pitchUnit;
    AudioUnit pitchRioConverterUnit;
    AudioUnit rioUnit;
    
    AudioFileID audioFile;
}

@property (assign, nonatomic) AudioUnitParameterValue pitchRate;

@end
