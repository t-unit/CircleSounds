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


@interface TOViewController ()

@property (strong, nonatomic) TOSoundDocument *document;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) TOEqualizerSound *sound1;
@property (strong, nonatomic) TOEqualizerSound *sound2;

@end

@implementation TOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.document = [[TOSoundDocument alloc] init];
    self.document.duration = 60;
    
    [self.document start];
    
    self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(printCurrentPlaybackTime) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    
    TOEqualizerSound *eqSound = [[TOEqualizerSound alloc] init];
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"06 Birkenholzkompott" withExtension:@"mp3"];
    [eqSound setAudioFileURL:fileURL error:nil];
    
    eqSound.regionDuration = 60;
    eqSound.regionStart = 50;
    eqSound.startTime = 5;
    eqSound.playbackRate = 4;
    
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


- (void)printCurrentPlaybackTime
{
    NSLog(@"%f", self.document.currentPlaybackPosition);
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

@end
