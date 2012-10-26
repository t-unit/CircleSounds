//
//  TOMocVarispeedSound.m
//  CircleSounds
//
//  Created by Tobias Ottenweller on 26.10.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOMocVarispeedSound.h"

@implementation TOMocVarispeedSound


- (NSTimeInterval)actualStartTime
{
    return _startTime;
}


- (void)setActualStartTime:(NSTimeInterval)actualStartTime
{
    _startTime = actualStartTime;
}


@end
