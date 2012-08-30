//
//  TOSoundDocumentViewController.m
//  CircleSounds
//
//  Created by Tobias Ottenweller on 29.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOSoundDocumentViewController.h"

#import "TOSoundDocument.h"
#import "TOAudioMeterView.h"
#import "TOEqualizerSound.h"
#import "TOPlugableSoundController.h"
#import "TOPlugableSoundView.h"




@interface TOSoundDocumentViewController ()

@property (strong, nonatomic) NSTimer *timeAndMeterUpdateTimer;

@end


@implementation TOSoundDocumentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.leftMeterView.mode = TOAudioMeterViewModeLandscape;
    self.rightMeterView.mode = TOAudioMeterViewModeLandscape;
    
    
	self.soundDocument = [[TOSoundDocument alloc] init];
    self.soundDocument.duration = 60;
    
    self.timeAndMeterUpdateTimer = [NSTimer timerWithTimeInterval:1.0/25.0 target:self selector:@selector(updateTimeAndMeter) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timeAndMeterUpdateTimer forMode:NSDefaultRunLoopMode];
    
    TOEqualizerSound *sound = [[TOEqualizerSound alloc] init];
    
    NSURL *soundFileURL = [[NSBundle mainBundle] URLForResource:@"08 Hope You're Feeling Better" withExtension:@"m4a"];
    [sound setAudioFileURL:soundFileURL error:nil]; // TODO: proper error handling
    
    sound.regionDuration = sound.fileDuration;
    
    TOPlugableSoundController *soundController = [[TOPlugableSoundController alloc] initWithPlugableSound:sound atPosition:CGRectMake(0, self.canvas.bounds.size.height/2, 150, 150)];
    self.soundControllers = @[soundController];
    soundController.documentController = self;
    
    [self.soundDocument addPlugableSoundObject:sound];
    [self.canvas addSubview:soundController.soundView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)startPauseButtonPressed:(id)sender
{
    if (self.soundDocument.isRunning) {
        [self.soundDocument pause];
        self.startPauseButton.selected = NO;
    }
    else {
        [self.soundDocument start];
        self.startPauseButton.selected = YES;
    }
}


- (IBAction)resetButtonPressed:(id)sender
{
    [self.soundDocument reset];
}


- (IBAction)volumeSliderValueChanged:(id)sender
{
    self.soundDocument.volume = self.volumeSlider.value;
}


- (void)updateTimeAndMeter
{
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%.2f", self.soundDocument.currentPlaybackPosition];
    
    //
    // 0 == -50db
    // 1 ==   0db
    //
    
    // AVG
    double db = [self.soundDocument avgValueLeft];
    CGFloat value = 0.02 * db + 1;
    self.leftMeterView.value = value;
    
    db = [self.soundDocument avgValueRight];
    value = 0.02 * db + 1;
    self.rightMeterView.value = value;
    
    
    // PEAK
    db = [self.soundDocument peakValueLeft];
    value = 0.02 * db + 1;
    self.leftMeterView.peakValue = value;
    
    db = [self.soundDocument peakValueRight];
    value = 0.02 * db + 1;
    self.rightMeterView.peakValue = value;
}


- (IBAction)loopSwitchValueChanged:(id)sender
{
    self.soundDocument.loop = self.loopSwitch.on;
}
@end
