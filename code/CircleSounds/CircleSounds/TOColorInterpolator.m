//
//  WAColorInterpolator.m
//  CircleSounds
//
//  Created by Tobias Ottenweller on 5/7/12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOColorInterpolator.h"

@implementation TOColorInterpolator

+ (UIColor *)colorAtValue:(float)value betweenLowerValue:(float)lowerValue withColor:(UIColor *)lowerColor andHigherValue:(float)higherValue withColor:(UIColor *)higherColor
{
    NSParameterAssert(lowerColor);
    NSParameterAssert(higherColor);
    
    // make sure not to return any garbage colors (invalid values for red, green or blue)
    if (value <= lowerValue) {
        return lowerColor;
    }
    else if (value >= higherValue) {
        return higherColor;
    }
    
    
    CGFloat lowerRed, lowerGreen, lowerBlue, lowerAlpha;
    [lowerColor getRed:&lowerRed green:&lowerGreen blue:&lowerBlue alpha:&lowerAlpha];
    
    CGFloat higherRed, higherGreen, higherBlue, higherAlpha;
    [higherColor getRed:&higherRed green:&higherGreen blue:&higherBlue alpha:&higherAlpha];
    
    
    CGFloat red = [self yValueForX:value inLinearFunctionWithPoint:CGPointMake(lowerValue, lowerRed) andPoint:CGPointMake(higherValue, higherRed)];
    CGFloat green = [self yValueForX:value inLinearFunctionWithPoint:CGPointMake(lowerValue, lowerGreen) andPoint:CGPointMake(higherValue, higherGreen)];
    CGFloat blue = [self yValueForX:value inLinearFunctionWithPoint:CGPointMake(lowerValue, lowerBlue) andPoint:CGPointMake(higherValue, higherBlue)];
    CGFloat alpha = [self yValueForX:value inLinearFunctionWithPoint:CGPointMake(lowerValue, lowerAlpha) andPoint:CGPointMake(higherValue, higherAlpha)];
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
