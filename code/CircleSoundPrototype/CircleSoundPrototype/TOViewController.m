//
//  TOViewController.m
//  CircleSoundPrototype
//
//  Created by Tobias Ottenweller on 22.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOViewController.h"
#import "TOSoundDocument.h"
#import "TOVarispeed.h"


@interface TOViewController ()

@property (strong, nonatomic) TOSoundDocument *document;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation TOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.document = [[TOSoundDocument alloc] init];
    [self.document start];
    
    self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(printCurrentPlaybackTime) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    
    TOVarispeed *varispeed = [[TOVarispeed alloc] init];
    varispeed.audioFileURL = [[NSBundle mainBundle] URLForResource:@"06 Birkenholzkompott" withExtension:@"mp3"];
    varispeed.regionDuration = 60;
    
    [self.document addPlugableSoundObject:varispeed];
    
    [varispeed applyChanges:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)printCurrentPlaybackTime
{
    NSLog(@"%f", self.document.currentPlaybackPos);
}

@end
