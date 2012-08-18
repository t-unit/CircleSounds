//
//  TOBandEqualizer.h
//  EqualizerTest
//
//  Created by Tobias Ottenweller on 17.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>


@interface TOBandEqualizer : NSObject
{
    AUGraph graph;
    
    AudioUnit equalizerUnit;
    AudioUnit filePlayerUnit;
    AudioUnit rioUnit;
    
    AudioFileID audioFile;
}

- (void)setUp;


@property (readonly, nonatomic) UInt32 maxNumberOfBands;
@property (readwrite, nonatomic) UInt32 numBands; // Can only be set if the equalizer unit is uninitialized.
@property (readwrite, nonatomic) NSArray *bands;


- (AudioUnitParameterValue)gainForBandAtPosition:(NSUInteger)bandPosition;
- (void)setGain:(AudioUnitParameterValue)gain forBandAtPosition:(NSUInteger)bandPosition;

@end
