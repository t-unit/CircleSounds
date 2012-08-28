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
//    NSURL *audioFileURL = [[NSBundle mainBundle] URLForResource:@"24 Eine Sultanine" withExtension:@"m4a"];
        NSURL *audioFileURL = [[NSBundle mainBundle] URLForResource:@"07 Fair" withExtension:@"m4a"];
    
    
    TOWaveformDrawer *drawer = [[TOWaveformDrawer alloc] init];
    drawer.waveformColor = [UIColor redColor];
    drawer.url = audioFileURL;
    drawer.imageSize = CGSizeMake(500, 100);
    
    
    UIImage *image = [drawer waveformImage];
    self.imageView.image = image;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
