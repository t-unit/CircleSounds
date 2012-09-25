//
//  TOViewController.h
//  EqualizerTest
//
//  Created by Tobias Ottenweller on 15.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TOBandEqualizer;


@interface TOViewController : UIViewController

@property (strong, nonatomic) TOBandEqualizer *eq;


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

@property (weak, nonatomic) IBOutlet UISlider *gainSlider;
- (IBAction)gainSliderValueChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *label32;
@property (weak, nonatomic) IBOutlet UILabel *label64;
@property (weak, nonatomic) IBOutlet UILabel *label125;
@property (weak, nonatomic) IBOutlet UILabel *label250;
@property (weak, nonatomic) IBOutlet UILabel *label500;
@property (weak, nonatomic) IBOutlet UILabel *label1k;
@property (weak, nonatomic) IBOutlet UILabel *label2k;
@property (weak, nonatomic) IBOutlet UILabel *label4k;
@property (weak, nonatomic) IBOutlet UILabel *label8k;
@property (weak, nonatomic) IBOutlet UILabel *label16k;
@property (weak, nonatomic) IBOutlet UILabel *gainLabel;

@end
