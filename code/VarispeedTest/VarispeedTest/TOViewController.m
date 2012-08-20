//
//  TOViewController.m
//  VarispeedTest
//
//  Created by Tobias Ottenweller on 20.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOViewController.h"
#import "TOVarispeed.h"

@interface TOViewController ()

@end

@implementation TOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.varispeed = [[TOVarispeed alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)rateSliderValueChanged:(id)sender
{
    self.varispeed.playbackRate = self.rateSlider.value;
    
    self.centsSlider.value = self.varispeed.playbackCents;
    
    self.centsLabel.text = [NSString stringWithFormat:@"%f", self.varispeed.playbackCents];
    self.rateLabel.text = [NSString stringWithFormat:@"%f", self.varispeed.playbackRate];
}


- (IBAction)centsSliderValueChanged:(id)sender
{
    self.varispeed.playbackCents = self.centsSlider.value;
 
    self.rateSlider.value = self.varispeed.playbackRate;
    
    self.centsLabel.text = [NSString stringWithFormat:@"%f", self.varispeed.playbackCents];
    self.rateLabel.text = [NSString stringWithFormat:@"%f", self.varispeed.playbackRate];
}
@end
