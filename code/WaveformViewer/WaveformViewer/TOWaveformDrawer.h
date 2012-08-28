//
//  TOWaveformDrawer.h
//  WaveformViewer
//
//  Created by Tobias Ottenweller on 27.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum TOWaveformDrawerMode : NSInteger
{
    TOWaveformDrawerModeRectangle,
    TOWaveformDrawerModeCircle
} TOWaveformDrawerMode;


@interface TOWaveformDrawer : NSObject

@property (assign, nonatomic) TOWaveformDrawerMode mode;
@property (strong, nonatomic) UIColor *waveformColor;
@property (assign, nonatomic) CGSize imageSize;


/**
 Only used when mode is set to 'TOWaveformDrawerModeCircle'.
 The drawing algorithm will fill the area between 'innerRadius'
 and the minimum of 'size.width' and 'size.hight'.
 */
@property (assign, nonatomic) CGFloat innerRadius;


/**
 The url must not be nil. It also needs to point to a valid audio file URL.
 An exception will be thrown otherwise.
 */
@property (strong, nonatomic) NSURL *url;


/**
 Method creating an image representation of an audio file found at 'url'.
 It supports files containing any number of channels but downsamples
 all files to mono.
 Accessing this property can be fairy expensive!
 */
@property (readonly, nonatomic) UIImage *waveformImage;

@end
