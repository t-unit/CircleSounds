//
//  TOPlugableSound.m
//  CircleSoundPrototype
//
//  Created by Tobias Ottenweller on 22.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOPlugableSound.h"

@implementation TOPlugableSound

- (id)init
{
    self = [super init];
    
    if (self) {
        _audioUnits = @[];
    }
    
    return self;
}


- (void)setupUnits
{
    
}


- (void)tearDownUnits
{
    
}


- (void)setupFinished
{
    
}


- (NSTimeInterval)duration
{
    return -1.0;
}


- (void)handleDocumentReset
{

}

@end
