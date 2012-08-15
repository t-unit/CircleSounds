//
//  WAColorInterpolator.h
//  WeatherApp
//
//  Created by Tobias Ottenweller on 5/7/12.
//  Copyright (c) Tobias Ottenweller. All rights reserved.
//

#import "TOBaseInterpolator.h"

@interface TOColorInterpolator : TOBaseInterpolator

+ (UIColor *)colorAtValue:(float)value betweenLowerValue:(float)lowerValue withColor:(UIColor *)lowerColor andHigherValue:(float)higherValue withColor:(UIColor *)higherColor;

@end
