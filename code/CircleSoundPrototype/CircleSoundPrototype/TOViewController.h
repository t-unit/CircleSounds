//
//  TOViewController.h
//  CircleSoundPrototype
//
//  Created by Tobias Ottenweller on 22.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TOAudioMeterView;


@interface TOViewController : UIViewController

@property (weak, nonatomic) IBOutlet TOAudioMeterView *leftMeterView;
@property (weak, nonatomic) IBOutlet TOAudioMeterView *rightMeterView;

- (IBAction)startPauseButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *startPauseButton;

- (IBAction)resetButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *resetButtonPressed;

@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;

- (IBAction)volumeSliderValueChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@end
