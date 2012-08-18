//
//  TOViewController.h
//  FilePlayMixerMeter
//
//  Created by Tobias Ottenweller on 15.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TOAudioMeterView;

@interface TOViewController : UIViewController

@property (weak, nonatomic)  IBOutlet TOAudioMeterView *audioMeterView1;
@property (weak, nonatomic) IBOutlet TOAudioMeterView *audioMeterView2;



//............................................................................
// EQ

@property (weak, nonatomic) IBOutlet UISlider *globalGainSlider;
- (IBAction)globalGainValueChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UISlider *gainSlider32;
- (IBAction)gainSlider32ValueChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UISlider *gainSlider64;
- (IBAction)gainSlider64ValueChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UISlider *gainSlider125;
- (IBAction)gainSlider125ValueChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UISlider *gainSlider250;
- (IBAction)gainSlider250ValueChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UISlider *gainSlider500;
- (IBAction)gainSlider500ValueChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UISlider *gainSlider1k;
- (IBAction)gainSlider1kValueChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UISlider *gainSlider2k;
- (IBAction)gainSlider2kValueChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UISlider *gainSlider4k;
- (IBAction)gainSlider4kValueChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UISlider *gainSlider8k;
- (IBAction)gainSlider8kValueChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UISlider *gainSlider16k;
- (IBAction)gainSlider16kValueChanged:(id)sender;



//............................................................................
// Volume (Mixer)

@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
- (IBAction)volumeSliderValueChanged:(id)sender;
@end
