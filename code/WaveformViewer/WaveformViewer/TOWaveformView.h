//
//  TOWaveformView.h
//  RecordPlayThrough
//
//  Created by Tobias Ottenweller on 11.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TOWaveformViewDatatSource;


@interface TOWaveformView : UIView

@property (assign, nonatomic) NSUInteger numChannels;
@property (weak, nonatomic) id<TOWaveformViewDatatSource> dataSource;


@end
