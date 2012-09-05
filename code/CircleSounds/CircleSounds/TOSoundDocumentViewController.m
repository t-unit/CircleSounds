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

#define SOUND_VIEW_WIDTH 150
#define SOUND_VIEW_HEIGHT 150


@interface TOSoundDocumentViewController ()

@property (strong, nonatomic) NSTimer *timeAndMeterUpdateTimer;

@end


@implementation TOSoundDocumentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.leftMeterView.mode = TOAudioMeterViewModeLandscape;
    self.rightMeterView.mode = TOAudioMeterViewModeLandscape;
    
    self.soundControllers = @[];
	self.soundDocument = [[TOSoundDocument alloc] init];
    self.soundDocument.duration = 60;
    
    self.timeAndMeterUpdateTimer = [NSTimer timerWithTimeInterval:1.0/25.0 target:self selector:@selector(updateTimeAndMeter) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timeAndMeterUpdateTimer forMode:NSDefaultRunLoopMode];
    
    
    // add double tap gesture for adding new sounds
    UIView *gestureCather = [[UIView alloc] initWithFrame:self.canvas.bounds];
    gestureCather.autoresizesSubviews = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.canvas addSubview:gestureCather];
    
    UITapGestureRecognizer *doubleTapGestureRecoginizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapGestureRecoginizer.numberOfTapsRequired = 2;
    doubleTapGestureRecoginizer.numberOfTouchesRequired = 1;
    [gestureCather addGestureRecognizer:doubleTapGestureRecoginizer];
}


- (void)addNewSoundAtPosition:(CGPoint)pos
{
    TOEqualizerSound *sound = [[TOEqualizerSound alloc] init];
    
    NSURL *soundFileURL = [[NSBundle mainBundle] URLForResource:@"08 Hope You're Feeling Better" withExtension:@"m4a"];
    [sound setAudioFileURL:soundFileURL error:nil]; // TODO: proper error handling
    
    sound.regionDuration = sound.fileDuration;
    
    CGRect newSoundViewFrame = CGRectMake(pos.x - (SOUND_VIEW_WIDTH/2), pos.y - (SOUND_VIEW_HEIGHT/2), SOUND_VIEW_WIDTH, SOUND_VIEW_HEIGHT);
    
    TOPlugableSoundController *soundController = [[TOPlugableSoundController alloc] initWithPlugableSound:sound
                                                                                               atPosition:newSoundViewFrame
                                                                                       documentController:self];
    
    self.soundControllers = [self.soundControllers arrayByAddingObject:soundController];
    
    
    [self.soundDocument addPlugableSoundObject:sound];
    [self.canvas addSubview:soundController.soundView];
    
    [self.canvas bringSubviewToFront:self.currentPositionView];
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
    // Current Time Label
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%.2f", self.soundDocument.currentPlaybackPosition];
    
    
    // Meter Views
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
    
    
    // Current Position View
    CGFloat xTranslation = self.canvas.bounds.size.width/self.soundDocument.duration*self.soundDocument.currentPlaybackPosition;
    
    self.currentPositionView.transform = CGAffineTransformMakeTranslation(xTranslation, 0.0f);
}


- (IBAction)loopSwitchValueChanged:(id)sender
{
    self.soundDocument.loop = self.loopSwitch.on;
}


- (void)handleDoubleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self addNewSoundAtPosition:[sender locationInView:self.canvas]];
    }
}


//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    // The Storyboard Segue is named popover in this case:
//    if ([segue.identifier isEqualToString:@"show"]) {
//        UIPopoverController *popController = [(UIStoryboardPopoverSegue *)segue popoverController];
//        
//        popController
//        
//        
//        NSLog(@"sender: %@", sender);
//    }
//}

@end
