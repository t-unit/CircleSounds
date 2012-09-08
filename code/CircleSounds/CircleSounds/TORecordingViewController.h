//
//  TORecordingViewController.h
//  CircleSounds
//
//  Created by Tobias Ottenweller on 08.09.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TOAudioMeterView;


@interface TORecordingViewController : UIViewController <UITableViewDataSource, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UISwitch *monintorSwitch;
- (IBAction)monitorSwitchValueChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *recButton;
- (IBAction)recButtonTouchUpInside:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *recentRecordingsTableView;

@property (weak, nonatomic) IBOutlet TOAudioMeterView *leftAudioMeter;
@property (weak, nonatomic) IBOutlet TOAudioMeterView *rightAudioMeter;

@end
