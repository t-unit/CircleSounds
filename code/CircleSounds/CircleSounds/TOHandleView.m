//
//  TOHandleView.m
//  CircleSounds
//
//  Created by Tobias Ottenweller on 04.09.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOHandleView.h"

@implementation TOHandleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGFloat firstLineXPos = self.bounds.size.width / 2.0 - 2;
    CGFloat secondLineXPos = self.bounds.size.width / 2.0 + 2;
    
    CGFloat upperYPos = self.bounds.size.height * 0.2;
    CGFloat lowerYPos = self.bounds.size.height * 0.8;
    
    // fill background
    [[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5] set];
    [[UIBezierPath bezierPathWithRect:CGRectMake(firstLineXPos - 4, 0, 12, self.bounds.size.height)] fill];
 
    
    // draw handles
    UIBezierPath *handlePath = [[UIBezierPath alloc] init];
    
    [handlePath moveToPoint:CGPointMake(firstLineXPos, upperYPos)];
    [handlePath addLineToPoint:CGPointMake(firstLineXPos, lowerYPos)];
    
    [handlePath moveToPoint:CGPointMake(secondLineXPos, upperYPos)];
    [handlePath addLineToPoint:CGPointMake(secondLineXPos, lowerYPos)];
    
    
    [[UIColor darkGrayColor] set];
    handlePath.lineWidth = 3.0;
    [handlePath stroke];
}

@end
