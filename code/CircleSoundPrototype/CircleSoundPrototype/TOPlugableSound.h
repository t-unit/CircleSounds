//
//  TOPlugableSound.h
//  CircleSoundPrototype
//
//  Created by Tobias Ottenweller on 22.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "TOCAShortcuts.h"
#import "TOAudioUnit.h"

@class TOSoundDocument;


/**
 Base class for Audio Unit wrapper classes.
 */
@interface TOPlugableSound : NSObject
{
    NSArray *_audioUnits;
}


+ (NSUInteger)numUnits;


/**
 Contains TOAudioUnit object. The order represents the the
 order in which they unit should be chained.
 */
@property (readonly, nonatomic) NSArray *audioUnits;


/**
 A reference to the document the object is currently part of.
 */
@property (weak, nonatomic) TOSoundDocument *document;



/**
 Overwrite the setup and tear down method in your subclass to 
 do any additional code needs to be exectuted after the audio
 unit has been initialized or after it has been removed from
 the audio processing graph.
 */
- (void)setupUnits;
- (void)tearDownUnits;

@end
