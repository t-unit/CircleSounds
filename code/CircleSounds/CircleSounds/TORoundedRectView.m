//
//  TORoundedRectView.m
//  CircleSounds
//
//  Created by Tobias Ottenweller on 30.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TORoundedRectView.h"

#import <QuartzCore/QuartzCore.h>


@implementation TORoundedRectView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}


- (void)commonInit
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 5.0;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
