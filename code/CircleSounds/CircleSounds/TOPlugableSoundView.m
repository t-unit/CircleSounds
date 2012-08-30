//
//  TOPlugableSoundView.m
//  CircleSounds
//
//  Created by Tobias Ottenweller on 29.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOPlugableSoundView.h"


@interface TOPlugableSoundView ()

@property (weak, nonatomic) UIImageView *imageView;

@end


@implementation TOPlugableSoundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        CGRect imageViewRect = frame;
        imageViewRect.origin.x = 0;
        imageViewRect.origin.y = 0;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageViewRect];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        imageView.backgroundColor = [UIColor clearColor];
        
        self.imageView = imageView;
        [self addSubview:imageView];
        
    }
    return self;
}



- (void)drawRect:(CGRect)rect
{
    [self.color set];
    [[UIBezierPath bezierPathWithOvalInRect:self.bounds] fill];
}



- (void)setColor:(UIColor *)color
{
    _color = color;
    [self setNeedsDisplay];
}


- (void)setWaveformImage:(UIImage *)waveformImage
{
    self.imageView.image = waveformImage;
}


- (UIImage *)waveformImage
{
    return self.imageView.image;
}

@end
