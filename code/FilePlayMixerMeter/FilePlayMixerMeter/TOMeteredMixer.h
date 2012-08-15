//
//  TOMeteredMixer.h
//  FilePlayMixerMeter
//
//  Created by Tobias Ottenweller on 15.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TOMeteredMixer : NSObject

- (Float32)meterValueLeft;
- (Float32)meterValueRight;

@end
