//
//  TOViewController.m
//  FilePlayMixerMeter
//
//  Created by Tobias Ottenweller on 15.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOViewController.h"

#import "TOMeteredMixer.h"
#import "TOAudioMeterView.h"

@interface TOViewController ()

@property (strong, nonatomic) TOMeteredMixer *mixer;

@property (strong, nonatomic) NSTimer *levelMeterUpdateTimer;

@end

@implementation TOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.mixer = [[TOMeteredMixer alloc] init];
    
    self.levelMeterUpdateTimer = [NSTimer timerWithTimeInterval:1.0/25 target:self selector:@selector(updateAudioMeterView:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.levelMeterUpdateTimer forMode:NSDefaultRunLoopMode];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)updateAudioMeterView:(NSTimer *)timer
{
//    NSLog(@"%f", [self.mixer meterValue]);
    
    // AVG
    double db = [self.mixer avgValueLeft];
    CGFloat value = 0.02 * db + 1;
    self.audioMeterView1.value = value;
    
    db = [self.mixer avgValueRight];
    value = 0.02 * db + 1;
    self.audioMeterView2.value = value;
    
    
    // PEAK
    db = [self.mixer peakValueLeft];
    value = 0.02 * db + 1;
    self.audioMeterView1.peakValue = value;
    
    db = [self.mixer peakValueRight];
    value = 0.02 * db + 1;
    self.audioMeterView2.peakValue = value;
    
}


- (IBAction)volumeSliderValueChanged:(id)sender
{
    self.mixer.volume = self.volumeSlider.value;
}


- (IBAction)globalGainValueChanged:(id)sender
{
    self.mixer.globalGain = self.globalGainSlider.value;
}


- (IBAction)gainSlider32ValueChanged:(id)sender
{
    [self.mixer setGain:self.gainSlider32.value forBandAtPosition:0];
}


- (IBAction)gainSlider64ValueChanged:(id)sender
{
    [self.mixer setGain:self.gainSlider64.value forBandAtPosition:1];
}


- (IBAction)gainSlider125ValueChanged:(id)sender
{
    [self.mixer setGain:self.gainSlider125.value forBandAtPosition:2];
}


- (IBAction)gainSlider250ValueChanged:(id)sender
{
    [self.mixer setGain:self.gainSlider250.value forBandAtPosition:3];
}


- (IBAction)gainSlider500ValueChanged:(id)sender
{
    [self.mixer setGain:self.gainSlider500.value forBandAtPosition:4];
}


- (IBAction)gainSlider1kValueChanged:(id)sender
{
    [self.mixer setGain:self.gainSlider1k.value forBandAtPosition:5];
}


- (IBAction)gainSlider2kValueChanged:(id)sender
{
    [self.mixer setGain:self.gainSlider2k.value forBandAtPosition:6];
}


- (IBAction)gainSlider4kValueChanged:(id)sender
{
    [self.mixer setGain:self.gainSlider4k.value forBandAtPosition:7];
}


- (IBAction)gainSlider8kValueChanged:(id)sender
{
    [self.mixer setGain:self.gainSlider8k.value forBandAtPosition:8];
}


- (IBAction)gainSlider16kValueChanged:(id)sender
{
    [self.mixer setGain:self.gainSlider16k.value forBandAtPosition:9];
}

@end
