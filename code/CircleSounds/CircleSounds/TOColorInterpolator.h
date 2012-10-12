//
//  WAColorInterpolator.h
//  CircleSounds
//
//  Created by Tobias Ottenweller on 5/7/12.
//  Copyright (c) Tobias Ottenweller. All rights reserved.
//

#import "TOLinearInterpolator.h"

@interface TOColorInterpolator : TOLinearInterpolator


/**
 Creates a interpolated Color object between to other given colors.
 The supplied colors must not be nil. An exception will be thrown otherwise.
 */
+ (UIColor *)colorAtValue:(float)value betweenLowerValue:(float)lowerValue withColor:(UIColor *)lowerColor andHigherValue:(float)higherValue withColor:(UIColor *)higherColor;

@end
