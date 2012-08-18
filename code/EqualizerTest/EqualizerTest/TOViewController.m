//
//  TOViewController.m
//  EqualizerTest
//
//  Created by Tobias Ottenweller on 15.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOViewController.h"
#import "TOBandEqualizer.h"


@implementation TOViewController
@synthesize label32;
@synthesize label64;
@synthesize label125;
@synthesize label250;
@synthesize label500;
@synthesize label1k;
@synthesize label2k;
@synthesize label4k;
@synthesize label8k;
@synthesize label16k;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.eq = [[TOBandEqualizer alloc] init];
    [self.eq setUp];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)gainSlider32ValueChanged:(id)sender
{
    [self.eq setGain:self.gainSlider32.value forBandAtPosition:0];
    [self updateLabels];
}


- (IBAction)gainSlider64ValueChanged:(id)sender
{
    [self.eq setGain:self.gainSlider64.value forBandAtPosition:1];
    [self updateLabels];
}


- (IBAction)gainSlider125ValueChanged:(id)sender
{
    [self.eq setGain:self.gainSlider125.value forBandAtPosition:2];
    [self updateLabels];
}


- (IBAction)gainSlider250ValueChanged:(id)sender
{
    [self.eq setGain:self.gainSlider250.value forBandAtPosition:3];
    [self updateLabels];
}


- (IBAction)gainSlider500ValueChanged:(id)sender
{
    [self.eq setGain:self.gainSlider500.value forBandAtPosition:4];
    [self updateLabels];
}


- (IBAction)gainSlider1kValueChanged:(id)sender
{
    [self.eq setGain:self.gainSlider1k.value forBandAtPosition:5];
    [self updateLabels];
}


- (IBAction)gainSlider2kValueChanged:(id)sender
{
    [self.eq setGain:self.gainSlider2k.value forBandAtPosition:6];
    [self updateLabels];
}


- (IBAction)gainSlider4kValueChanged:(id)sender
{
    [self.eq setGain:self.gainSlider4k.value forBandAtPosition:7];
    [self updateLabels];
}


- (IBAction)gainSlider8kValueChanged:(id)sender
{
    [self.eq setGain:self.gainSlider8k.value forBandAtPosition:8];
    [self updateLabels];
}


- (IBAction)gainSlider16kValueChanged:(id)sender
{
    [self.eq setGain:self.gainSlider16k.value forBandAtPosition:9];
    [self updateLabels];
}

- (void)updateLabels
{
    self.label32.text = [NSString stringWithFormat:@"%f", [self.eq gainForBandAtPosition:0]];
    self.label64.text = [NSString stringWithFormat:@"%f", [self.eq gainForBandAtPosition:1]];
    self.label125.text = [NSString stringWithFormat:@"%f", [self.eq gainForBandAtPosition:2]];
    self.label250.text = [NSString stringWithFormat:@"%f", [self.eq gainForBandAtPosition:3]];
    self.label500.text = [NSString stringWithFormat:@"%f", [self.eq gainForBandAtPosition:4]];
    self.label1k.text = [NSString stringWithFormat:@"%f", [self.eq gainForBandAtPosition:5]];
    self.label2k.text = [NSString stringWithFormat:@"%f", [self.eq gainForBandAtPosition:6]];
    self.label4k.text = [NSString stringWithFormat:@"%f", [self.eq gainForBandAtPosition:7]];
    self.label8k.text = [NSString stringWithFormat:@"%f", [self.eq gainForBandAtPosition:8]];
    self.label16k.text = [NSString stringWithFormat:@"%f", [self.eq gainForBandAtPosition:9]];
}
@end

