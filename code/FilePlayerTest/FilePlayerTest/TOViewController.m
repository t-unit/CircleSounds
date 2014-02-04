//
//  TOViewController.m
//  FilePlayerTest
//
//  Created by Tobias Ottenweller on 21.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOViewController.h"

@interface TOViewController ()

@end

@implementation TOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.audioFilePlayer = [[TOAudioFilePlayer alloc] init];
    
    self.audioFilePlayer.audioFileURL = [[NSBundle mainBundle] URLForResource:@"pump_im" withExtension:@"mp3"];
    self.audioFilePlayer.regionStart = 0;
    self.audioFilePlayer.regionDuration = 1000;
    
    [self.audioFilePlayer applyChanges:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
