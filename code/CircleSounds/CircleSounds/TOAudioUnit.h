//
//  TOAudioUnit.h
//  FilePlayerTest
//
//  Created by Tobias Ottenweller on 22.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>


/**
 A object wrapper around a audio unit, its corresponding node and its audio component description.
 Might be used like a struct. But makes it possilbe to add objects of the class to Foundation
 collection objects.
 */
@interface TOAudioUnit : NSObject
{
@public
    AUNode node;
    AudioUnit unit;
    AudioComponentDescription description;
}

@end
