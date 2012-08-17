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
@property (strong, nonatomic) NSArray *peakElements; // an array of CALayer objects

@end



@implementation TOAudioMeterView


- (void)drawRect:(CGRect)rect
{
    self.layer.backgroundColor = [[UIColor blackColor] CGColor];
    CGSize elementSize = CGSizeMake(self.bounds.size.width * 0.8, roundf(self.bounds.size.height * 0.8 / (NUM_ELEMENTS-2) - 2));
    
    
    // layer properties
    UIColor *lowColor = [UIColor colorWithRed:0 green:0.3725 blue:0.4823 alpha:1.0];
    UIColor *higColor = [UIColor colorWithRed:0.6235 green:0 blue:0.2784 alpha:1.0];
    UIColor *peakColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
    
    NSMutableArray *meterElemets = [[NSMutableArray alloc] initWithCapacity:NUM_ELEMENTS];
    NSMutableArray *peakElemets = [[NSMutableArray alloc] initWithCapacity:NUM_ELEMENTS];
    
    
    // placehoder rects properties
    [[UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0] set];
    
    
    
    for (int i=0; i<NUM_ELEMENTS; i++) {
        CGRect layerFrame;
        layerFrame.size = elementSize;
        layerFrame.origin.x = self.bounds.size.width * 0.1;
        layerFrame.origin.y = self.bounds.size.height * 0.9 - i * elementSize.height - i;
        
        
        // create the layer element
        CALayer *meterLayer = [self createMeterLayerWithFrame:layerFrame];
        meterLayer.backgroundColor = [[TOColorInterpolator colorAtValue:1.0/NUM_ELEMENTS*i
                                                 betweenLowerValue:0
                                                         withColor:lowColor
                                                    andHigherValue:1
                                                         withColor:higColor] CGColor];

        [self.layer addSublayer:meterLayer];
        [meterElemets addObject:meterLayer];
        
        
        // create peak layer element
        CALayer *peakLayer = [self createMeterLayerWithFrame:layerFrame];
        peakLayer.backgroundColor = peakColor.CGColor;
        
        [self.layer addSublayer:peakLayer];
        [peakElemets addObject:peakLayer];
        
        
        // draw the placholder rect
        UIBezierPath *placeholderPath = [UIBezierPath bezierPathWithRoundedRect:layerFrame cornerRadius:CORNER_RADIUS];
        placeholderPath.lineWidth = 0.5;
        
        [placeholderPath stroke];
    }
    
    self.meterElements = [meterElemets copy];
    self.peakElements = [peakElemets copy];
}


- (CALayer *)createMeterLayerWithFrame:(CGRect)frame
{
    CALayer *layer = [[CALayer alloc] init];
    layer.contentsScale = self.layer.contentsScale;
    layer.frame = frame;

    layer.cornerRadius = CORNER_RADIUS;
    layer.opacity = 0;
    
    return layer;
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


- (void)setPeakValue:(CGFloat)peakValue
{
    _peakValue = peakValue;
    
    for (CALayer *layer in self.peakElements) {
        layer.opacity = 0.0;
    }
    
    
    NSUInteger visibleElementIndex = self.peakElements.count * self.peakValue;
    [self.peakElements[visibleElementIndex] setOpacity:1.0];
}

@end