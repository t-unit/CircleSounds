//
//  TOMeteredMixer.h
//  FilePlayMixerMeter
//
//  Created by Tobias Ottenweller on 15.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>


@interface TOMeteredMixer : NSObject

/**
 Monitor properties. Return decibel values between -∞ and 0.
 */
@property (readonly, nonatomic) AudioUnitParameterValue avgValueLeft;
@property (readonly, nonatomic) AudioUnitParameterValue avgValueRight;

@property (readonly, nonatomic) AudioUnitParameterValue peakValueLeft;
@property (readonly, nonatomic) AudioUnitParameterValue peakValueRight;


/**
 Output volume of the mixer. Supplied values should be between 0 and 1.
 The behaviour is otherwise undefined.
 */
@property (assign, nonatomic) AudioUnitParameterValue volume;

@end
