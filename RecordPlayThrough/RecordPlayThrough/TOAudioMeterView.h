//
//  TOAudioMeterView.h
//  RecordPlayThrough
//
//  Created by Tobias Ottenweller on 11.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TOAudioMeterView : UIView

/**
 A number between 0 and 1. 
 0 means no indicator element is visible.
 1 means all inidicator elements are visible.
 */
@property (assign, nonatomic) CGFloat value;

@end
