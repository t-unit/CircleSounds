//
//  TORecordingViewController.h
//  CircleSounds
//
//  Created by Tobias Ottenweller on 08.09.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TORecorderDelegate.h"

@class TOAudioMeterView;


/**
 Allows to record audio via a TORecoder object an setting this audio
 as the sound  of an equalizer sound object.
 */
@interface TORecordingViewController : UIViewController <UITableViewDataSource, UITableViewDataSource>

@property (strong, nonatomic) TORecorder *recorder;


/* Interface Builder */
@property (weak, nonatomic) IBOutlet UISwitch *monintorSwitch;
- (IBAction)monitorSwitchValueChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UISlider *gainSlider;
- (IBAction)gainSliderValueChanged:(id)sender;


@property (weak, nonatomic) IBOutlet UIButton *recButton;
- (IBAction)recButtonTouchUpInside:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *recentRecordingsTableView;

@property (weak, nonatomic) IBOutlet TOAudioMeterView *leftAudioMeter;
@property (weak, nonatomic) IBOutlet TOAudioMeterView *rightAudioMeter;

@property (weak, nonatomic) IBOutlet UILabel *leftAudioMeterLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightAudioMeterLabel;
@end
