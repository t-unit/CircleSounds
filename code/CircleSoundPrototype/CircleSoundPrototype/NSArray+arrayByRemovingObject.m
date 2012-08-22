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
    NSMutableArray *newArray = [self mutableCopy];
    [newArray removeObject:anObject];
    
    return [newArray copy];
}

@end
