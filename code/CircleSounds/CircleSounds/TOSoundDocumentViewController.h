//
//  TOSoundDocumentViewController.h
//  CircleSounds
//
//  Created by Tobias Ottenweller on 29.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TOSoundDocumentDelegate.h"

@class TOSoundDocument;
@class TOAudioMeterView;
@class TOEqualizerSoundController;


@interface TOSoundDocumentViewController : UIViewController <TOSoundDocumentDelegate>

@property (strong, nonatomic) TOSoundDocument *soundDocument;
@property (strong, nonatomic) NSArray *soundControllers;

- (void)addNewSoundAtPosition:(CGPoint)pos;
- (void)removeSoundController:(TOEqualizerSoundController *)soundController;


/* Interface Builder Properties and Callbacks */
@property (weak, nonatomic) IBOutlet UIView *canvas;

@property (weak, nonatomic) IBOutlet TOAudioMeterView *leftMeterView;
@property (weak, nonatomic) IBOutlet TOAudioMeterView *rightMeterView;

- (IBAction)startPauseButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *startPauseButton;

- (IBAction)resetButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *resetButtonPressed;

@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;

- (IBAction)volumeSliderValueChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;

- (IBAction)loopSwitchValueChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *loopSwitch;

@property (weak, nonatomic) IBOutlet UIView *currentPositionView;
@property (weak, nonatomic) IBOutlet UIView *addSoundGestureCatcherView;

@end
