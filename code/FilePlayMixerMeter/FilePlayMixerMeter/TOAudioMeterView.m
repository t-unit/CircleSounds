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



@interface TOAudioMeterView ()

@property (strong, nonatomic) NSArray *meterElements; // an array of CALayer objects

@end



@implementation TOAudioMeterView


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self initMeterElements];
    
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self initMeterElements];
    
    return self;
}


- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self initMeterElements];
}


- (void)drawRect:(CGRect)rect
{
    NSUInteger lastVisibleElementIndex = self.meterElements.count * self.value;
    CGFloat opacityOfHighestElement = self.meterElements.count * self.value - lastVisibleElementIndex;
    
    for (NSUInteger i=0; i<self.meterElements.count; i++) {
        if (i<lastVisibleElementIndex) {
            [self.meterElements[i] setOpacity:1.0];
        }
        else if (i==lastVisibleElementIndex) {
            [[self.meterElements objectAtIndex:i] setOpacity:opacityOfHighestElement];
        }
        else {
            [self.meterElements[i] setOpacity:0.0];
        }
    }
}



#define NUM_ELEMENTS 50

- (void)initMeterElements
{
    self.layer.backgroundColor = [[UIColor blackColor] CGColor];
    
    UIColor *lowColor = [UIColor colorWithRed:0 green:0.3725 blue:0.4823 alpha:1.0];
    UIColor *higColor = [UIColor colorWithRed:0.6235 green:0 blue:0.2784 alpha:1.0];
    
    CGSize elementSize = CGSizeMake(self.bounds.size.width * 0.8, self.bounds.size.height * 0.8 / (NUM_ELEMENTS-2) - 2);
    
    NSMutableArray *meterElemets = [[NSMutableArray alloc] initWithCapacity:NUM_ELEMENTS];
    
    
    for (int i=0; i<NUM_ELEMENTS; i++) {
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
        layer.cornerRadius = 1;
        
        
        layer.opacity = 0;
        [self.layer addSublayer:layer];
        [meterElemets addObject:layer];
    }
    
    self.meterElements = [meterElemets copy]; // imutable copy
    self.value = 0.0;
}


- (void)setValue:(CGFloat)value
{
    _value = value;
    [self setNeedsDisplay];
}

@end
