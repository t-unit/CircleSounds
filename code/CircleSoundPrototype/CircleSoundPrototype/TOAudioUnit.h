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
 A object wrapper around a audio unit and its corresponding node.
 */
@interface TOAudioUnit : NSObject

@property (assign, nonatomic) AUNode node;
@property (assign, nonatomic) AudioUnit unit;

@end
