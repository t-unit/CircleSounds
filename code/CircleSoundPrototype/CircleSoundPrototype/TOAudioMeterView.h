//
//  TOAudioMeterView.h
//  RecordPlayThrough
//
//  Created by Tobias Ottenweller on 11.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum TOAudioMeterViewMode : NSInteger
{
    TOAudioMeterViewModePortrait,
    TOAudioMeterViewModeLandscape
    
} TOAudioMeterViewMode;



@interface TOAudioMeterView : UIView

/**
 A number between 0 and 1. 
 0 means no indicator element is visible.
 1 means all inidicator elements are visible.
 */
@property (assign, nonatomic) CGFloat value;


/**
 A number between 0 and 1.
 0 means nothing will be displayed.
 peakValue>0 and peakValue<1: a single bar at
 the correct position will be displayed.
 */
@property (assign, nonatomic) CGFloat peakValue;

@property (assign, nonatomic) TOAudioMeterViewMode mode;

@end
