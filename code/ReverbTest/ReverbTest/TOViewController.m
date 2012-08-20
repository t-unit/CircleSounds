//
//  TOViewController.m
//  ReverbTest
//
//  Created by Tobias Ottenweller on 20.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOViewController.h"
#import "TOReverb.h"

@interface TOViewController ()

@end

@implementation TOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.reverb = [[TOReverb alloc] init];
    
    NSLog(@"%d", self.reverb.randomizeReflections);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)dryWetMixerSliderValueChanged:(id)sender
{
    self.reverb.dryWetMix = self.dryWetMixSlider.value;
    self.dryWetMixLabel.text = [NSString stringWithFormat:@"%f", self.reverb.dryWetMix];
}


- (IBAction)gainSliderValueChanged:(id)sender
{
    self.reverb.gain = self.gainSlider.value;
    self.gainLabel.text = [NSString stringWithFormat:@"%f", self.reverb.gain];
}


- (IBAction)minDelaySliderValueChanged:(id)sender
{
    self.reverb.minDelayTime = self.minDelaySlider.value;
    self.minDelayLabel.text = [NSString stringWithFormat:@"%f", self.reverb.minDelayTime];
}


- (IBAction)maxDelaySliderValueChanged:(id)sender
{
    self.reverb.maxDelayTime = self.maxDelaySlider.value;
    self.maxDelayLabel.text = [NSString stringWithFormat:@"%f", self.reverb.maxDelayTime];
}


- (IBAction)decay0HzSliderValueChanged:(id)sender
{
    self.reverb.decayTimeAt0Hz = self.decay0HzSlider.value;
    self.decay0HzLabel.text = [NSString stringWithFormat:@"%f", self.reverb.decayTimeAt0Hz];
}


- (IBAction)decayNyquistSliderValueChanged:(id)sender
{
    self.reverb.decayTimeAtNyquist = self.decayNquistSlider.value;
    self.decayNyquistLabel.text = [NSString stringWithFormat:@"%f", self.reverb.decayTimeAtNyquist];
}


- (IBAction)reflectionsSliderValueChanged:(id)sender
{
    self.reverb.randomizeReflections = self.reflectionsSlider.value;
    self.reflectionsLabel.text = [NSString stringWithFormat:@"%d", self.reverb.randomizeReflections];
}
@end
