//
//  TOAudioMeterView.m
//  RecordPlayThrough
//
//  Created by Tobias Ottenweller on 11.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOAudioMeterView.h"

#import "TOColorInterpolator.h"
#import <QuartzCore/QuartzCore.h>


#define NUM_ELEMENTS 50
#define CORNER_RADIUS 1.0

@interface TOAudioMeterView ()

@property (strong, nonatomic) NSArray *meterElements; // an array of CALayer objects

@end



@implementation TOAudioMeterView


- (void)drawRect:(CGRect)rect
{
    self.layer.backgroundColor = [[UIColor blackColor] CGColor];
    CGSize elementSize = CGSizeMake(self.bounds.size.width * 0.8, roundf(self.bounds.size.height * 0.8 / (NUM_ELEMENTS-2) - 2));
    
    
    // layer properties
    UIColor *lowColor = [UIColor colorWithRed:0 green:0.3725 blue:0.4823 alpha:1.0];
    UIColor *higColor = [UIColor colorWithRed:0.6235 green:0 blue:0.2784 alpha:1.0];
    NSMutableArray *meterElemets = [[NSMutableArray alloc] initWithCapacity:NUM_ELEMENTS];
    
    
    // placehoder rects properties
    [[UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0] set];
    CGFloat cornerRadius = 1.0;
    
    
    
    for (int i=0; i<NUM_ELEMENTS; i++) {
        
        // create the layer element
        CALayer *layer = [[CALayer alloc] init];
        layer.contentsScale = self.layer.contentsScale;
        
        CGRect layerFrame;
        layerFrame.size = elementSize;
        layerFrame.origin.x = self.bounds.size.width * 0.1;
        layerFrame.origin.y = self.bounds.size.height * 0.9 - i * elementSize.height - i;
        
        layer.frame = layerFrame;
        
        layer.backgroundColor = [[TOColorInterpolator colorAtValue:1.0/NUM_ELEMENTS*i
                                                 betweenLowerValue:0
                                                         withColor:lowColor
                                                    andHigherValue:1
                                                         withColor:higColor] CGColor];
        layer.cornerRadius = cornerRadius;
        layer.opacity = 0;
        [self.layer addSublayer:layer];
        [meterElemets addObject:layer];
        
        
        // draw the placholder rect
        UIBezierPath *placeholderPath = [UIBezierPath bezierPathWithRoundedRect:layerFrame cornerRadius:cornerRadius];
        placeholderPath.lineWidth = 0.5;
        
        [placeholderPath stroke];
    }
    
    self.meterElements = [meterElemets copy];
}


- (void)setValue:(CGFloat)value
{
    _value = value;
    
    
    //
    // set the visibility of the meter elements according to the current value
    //
    
    NSUInteger lastVisibleElementIndex = self.meterElements.count * self.value;
    CGFloat opacityOfHighestElement = self.meterElements.count * self.value - lastVisibleElementIndex;
    
    
    NSUInteger i = 0;
    
    for (; i<lastVisibleElementIndex; i++) {
        [self.meterElements[i] setOpacity:1.0];
    }
    
    
    i++;
    [[self.meterElements objectAtIndex:i] setOpacity:opacityOfHighestElement];
    
    
    for (; i<self.meterElements.count; i++) {
        [self.meterElements[i] setOpacity:0.0];
    }
}

@end
