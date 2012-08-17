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
@property (weak, nonatomic) TOAudioMeterView *audioMeterView1;
@property (weak, nonatomic) TOAudioMeterView *audioMeterView2;
@property (strong, nonatomic) NSTimer *levelMeterUpdateTimer;

@end

@implementation TOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.mixer = [[TOMeteredMixer alloc] init];
    
    
    TOAudioMeterView *amv = [[TOAudioMeterView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width/2, self.view.bounds.size.height)];
    [self.view addSubview:amv];
    self.audioMeterView1 = amv;
    
    amv = [[TOAudioMeterView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2, 0, self.view.bounds.size.width/2, self.view.bounds.size.height)];
    [self.view addSubview:amv];
    self.audioMeterView2 = amv;
    
    
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
    
    double db = [self.mixer avgValueLeft];
    CGFloat value = 0.02 * db + 1;
    self.audioMeterView1.value = value;
    
    db = [self.mixer avgValueRight];
    value = 0.02 * db + 1;
    self.audioMeterView2.value = value;
}

@end
