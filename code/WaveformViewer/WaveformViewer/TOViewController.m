//
//  TOViewController.m
//  WaveformViewer
//
//  Created by Tobias Ottenweller on 27.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOViewController.h"
#import "TOWaveformDrawer.h"

@interface TOViewController ()

@end

@implementation TOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
//    NSURL *audioFileURL = [[NSBundle mainBundle] URLForResource:@"Scirocco" withExtension:@"mp3"];
        NSURL *audioFileURL = [[NSBundle mainBundle] URLForResource:@"pump_im" withExtension:@"mp3"];
    
    
    TOWaveformDrawer *drawer = [[TOWaveformDrawer alloc] init];
    drawer.mode = TOWaveformDrawerModeRectangle;
    drawer.waveformColor = [UIColor colorWithRed:50/255.0 green:200/255.0 blue:255/255.0 alpha:1];
    drawer.imageSize = CGSizeMake(500, 100);
    
    
    UIImage *image = [drawer waveformFromImageAtURL:audioFileURL];
    self.imageView.image = image;
    
    
    drawer.mode = TOWaveformDrawerModeCircle;
    drawer.imageSize = CGSizeMake(500, 500);
    drawer.innerRadius = 150;
    image = [drawer waveformFromImageAtURL:audioFileURL];
    self.imageView2.image = image;
    
    NSLog(@"done");
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
