//
//  NSSet+setByRemovingObject.m
//  CircleSounds
//
//  Created by Tobias Ottenweller on 11.09.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "NSSet+setByRemovingObject.h"

@implementation NSSet (setByRemovingObject)


- (NSSet *)setByRemovingObject:(id)anObject
{
    if (![self containsObject:anObject]) {
        return [self copy];
    }

    
    NSMutableSet *mutalbeSelf = [self mutableCopy];
    [mutalbeSelf removeObject:anObject];
    
    return [mutalbeSelf copy]; // return an immutable set
}

@end
