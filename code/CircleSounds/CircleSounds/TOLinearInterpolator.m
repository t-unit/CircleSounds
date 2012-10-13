//
//  WABaseInterpolator.m
//  CircleSounds
//
//  Created by Tobias Ottenweller on 5/7/12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOLinearInterpolator.h"

@implementation TOLinearInterpolator

+ (double)yValueForX:(double)x inLinearFunctionWithPoint:(CGPoint)p1 andPoint:(CGPoint)p2
{
    if (p1.x == p2.x) { // prevent NaNs while calculating 'm'
        return p1.y; // at this point should be exact the same value as p2.y
    }
    
    // m = (y2 - y1) / (x2 - x1)
    CGFloat m = (p2.y - p1.y) / (p2.x - p1.x);
    
    // t = y - mx
    CGFloat t = p1.y - m * p1.x;
    
    return m * x + t;
}

@end
