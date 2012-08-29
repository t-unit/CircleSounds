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
 Overwrite the getter if sound of the subclass ends after
 a certain amount of time. Otherwise return [super duration].
 Value is '-1.0' if sounds loops forever or if there is no sound
 at all.
 */
@property (readonly, nonatomic) NSTimeInterval duration;



/**
 Overwrite the setup and tear down method in your subclass to 
 do any additional code needs to be exectuted after the audio
 unit has been initialized or after it has been removed from
 the audio processing graph.
 */
- (void)setupUnits;
- (void)tearDownUnits;


/**
 Called after the sound object has been added to the graph
 */
- (void)setupFinished;




/**
 Overwrite this method to handle document resets (playback postion 
 reset to 0).
 */
- (void)handleDocumentReset;

@end
