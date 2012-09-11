//
//  NSArray+arrayByRemovingObject.m
//  CircleSoundPrototype
//
//  Created by Tobias Ottenweller on 22.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "NSArray+arrayByRemovingObject.h"


@implementation NSArray (arrayByRemovingObject)

- (NSArray *)arrayByRemovingObject:(id)anObject
{
    if (![self containsObject:anObject]) {
        return [self copy];
    }
    
    
    NSMutableArray *mutableSelf = [self mutableCopy];
    [mutableSelf removeObject:anObject];
    
    return [mutableSelf copy]; // return an immutalbe array
}

@end
