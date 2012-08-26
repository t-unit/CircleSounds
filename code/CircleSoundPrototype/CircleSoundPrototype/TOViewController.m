//
//  TOViewController.m
//  CircleSoundPrototype
//
//  Created by Tobias Ottenweller on 22.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOViewController.h"
#import "TOSoundDocument.h"
#import "TOEqualizerSound.h"
#import "TOAudioMeterView.h"


@interface TOViewController ()

@property (strong, nonatomic) TOSoundDocument *document;
@property (strong, nonatomic) NSTimer *timeAndMeterUpdateTimer;
@property (strong, nonatomic) TOEqualizerSound *sound1;
@property (strong, nonatomic) TOEqualizerSound *sound2;

@end

@implementation TOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.document = [[TOSoundDocument alloc] init];
    self.document.duration = 60;
    
    [self startPauseButtonPressed:nil]; // start the document
    
    
    self.timeAndMeterUpdateTimer = [NSTimer timerWithTimeInterval:1.0/25.0 target:self selector:@selector(updateTimeAndMeter) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timeAndMeterUpdateTimer forMode:NSDefaultRunLoopMode];
    
    TOEqualizerSound *eqSound = [[TOEqualizerSound alloc] init];
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"06 Birkenholzkompott" withExtension:@"mp3"];
    [eqSound setAudioFileURL:fileURL error:nil];
    
    eqSound.regionDuration = 60;
    eqSound.regionStart = 50;
    eqSound.startTime = 5;
    eqSound.playbackRate = 4;
//    eqSound.bands = @[ @32, @64, @125, @250, @500, @1000, @2000, @4000, @8000, @16000 ];
//    
//    for (NSUInteger i=0; i<5; i++) {
//        [eqSound setGain:-96 forBandAtPosition:i];
//    }
    
    [self.document addPlugableSoundObject:eqSound];
    
    self.sound1 = eqSound;
    self.document.loop = YES;
    
    [self performSelector:@selector(addAdditionalSound) withObject:nil afterDelay:30];
    [self performSelector:@selector(removeSound) withObject:nil afterDelay:40];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)updateTimeAndMeter
{
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%.2f", self.document.currentPlaybackPosition];
    
    //
    // 0 == -50db
    // 1 ==   0db
    //
    
    // AVG
    double db = [self.document avgValueLeft];
    CGFloat value = 0.02 * db + 1;
    self.leftMeterView.value = value;
    
    db = [self.document avgValueRight];
    value = 0.02 * db + 1;
    self.rightMeterView.value = value;
    
    
    // PEAK
    db = [self.document peakValueLeft];
    value = 0.02 * db + 1;
    self.leftMeterView.peakValue = value;
    
    db = [self.document peakValueRight];
    value = 0.02 * db + 1;
    self.rightMeterView.peakValue = value;
}


- (void)addAdditionalSound
{
    TOEqualizerSound *eqSound = [[TOEqualizerSound alloc] init];
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"06 Birkenholzkompott" withExtension:@"mp3"];
    [eqSound setAudioFileURL:fileURL error:nil];
    
    [self.document addPlugableSoundObject:eqSound];
    
    eqSound.regionDuration = 60;
    eqSound.startTime = 5;
    
    self.sound2 = eqSound;
}


- (void)removeSound
{
    [self.document removePlugableSoundObject:self.sound1];
    
    self.sound2.startTime = 50;
    self.sound2.playbackRate = 3;
    
    [self addAdditionalSound];
}


- (IBAction)startPauseButtonPressed:(id)sender
{
    if (self.document.isRunning) {
        [self.document pause];
        self.startPauseButton.selected = NO;
    }
    else {
        [self.document start];
        self.startPauseButton.selected = YES;
    }
}


- (IBAction)resetButtonPressed:(id)sender
{
    [self.document reset];
}


- (IBAction)volumeSliderValueChanged:(id)sender
{
    self.document.volume = self.volumeSlider.value;
}

@end
