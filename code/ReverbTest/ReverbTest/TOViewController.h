//
//  TOViewController.h
//  ReverbTest
//
//  Created by Tobias Ottenweller on 20.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TOReverb;

@interface TOViewController : UIViewController

@property (strong, nonatomic) TOReverb *reverb;

@property (weak, nonatomic) IBOutlet UISlider *dryWetMixSlider;
@property (weak, nonatomic) IBOutlet UISlider *gainSlider;
@property (weak, nonatomic) IBOutlet UISlider *minDelaySlider;
@property (weak, nonatomic) IBOutlet UISlider *maxDelaySlider;
@property (weak, nonatomic) IBOutlet UISlider *decay0HzSlider;
@property (weak, nonatomic) IBOutlet UISlider *decayNquistSlider;
@property (weak, nonatomic) IBOutlet UISlider *reflectionsSlider;

@property (weak, nonatomic) IBOutlet UILabel *dryWetMixLabel;
@property (weak, nonatomic) IBOutlet UILabel *gainLabel;
@property (weak, nonatomic) IBOutlet UILabel *minDelayLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxDelayLabel;
@property (weak, nonatomic) IBOutlet UILabel *decay0HzLabel;
@property (weak, nonatomic) IBOutlet UILabel *decayNyquistLabel;
@property (weak, nonatomic) IBOutlet UILabel *reflectionsLabel;

- (IBAction)dryWetMixerSliderValueChanged:(id)sender;
- (IBAction)gainSliderValueChanged:(id)sender;
- (IBAction)minDelaySliderValueChanged:(id)sender;
- (IBAction)maxDelaySliderValueChanged:(id)sender;
- (IBAction)decay0HzSliderValueChanged:(id)sender;
- (IBAction)decayNyquistSliderValueChanged:(id)sender;
- (IBAction)reflectionsSliderValueChanged:(id)sender;
@end
