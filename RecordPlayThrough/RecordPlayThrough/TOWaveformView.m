//
//  TOWaveformView.m
//  RecordPlayThrough
//
//  Created by Tobias Ottenweller on 11.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOWaveformView.h"
#import "TOWaveformViewDatatSource.h"

//#define MAX_VALUE 32768


@implementation TOWaveformView


- (void)drawRect:(CGRect)rect
{
    NSArray *points = [self.dataSource points];
    
    if (!points.count) {
        return;
    }
    
//    if (points.count > 1000) {
//        points = [points subarrayWithRange:NSMakeRange(points.count-1000, 1000)];
//    }
    
    
    CGFloat maxValue = 100.0f;//[[points valueForKeyPath:@"@max.floatValue"] floatValue];
    
    CGFloat halfHeight = self.bounds.size.height / 2;
    CGFloat offsetPerPoint = self.bounds.size.width / points.count;
    
    
    CGPoint startPoint = CGPointMake(0, halfHeight - (halfHeight/maxValue * [[points objectAtIndex:0] floatValue]));
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:startPoint];
    
    for (NSUInteger i=1; i<points.count; i+=2) {
        CGPoint p = CGPointMake(offsetPerPoint * i, halfHeight - (halfHeight/maxValue * [[points objectAtIndex:i] floatValue]));
        [path addLineToPoint:p];
    }
    
//    [path addLineToPoint:CGPointMake(self.bounds.size.width, halfHeight)];
//    [path addLineToPoint:CGPointMake(0, halfHeight)];
//    [path closePath];
    
    [[UIColor blackColor] set];
    [path stroke];
}

@end
