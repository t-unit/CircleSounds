//
//  TOPlugableSound.h
//  CircleSoundPrototype
//
//  Created by Tobias Ottenweller on 22.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 Base class for Audio Unit wrapper classes.
 */
@interface TOPlugableSound : NSObject


+ (NSUInteger)numUnits;


/**
 Contains TOAudioUnit object. The order represents the the
 order in which they unit should be chained.
 */
@property (strong, nonatomic) NSArray *audioUnits;


- (void)setupUnitProperties;

@end
