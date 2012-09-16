//
//  TOViewController.m
//  RecordPlayThrough
//
//  Created by Tobias Ottenweller on 08.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface TOViewController ()

//@property (strong, nonatomic) NSMutableArray *waveform;
@property (strong, nonatomic) NSTimer *levelMeterUpdateTimer;

@end


@implementation TOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.waveFormView.dataSource = self;
    
    self.recoder = [[TORecorder alloc] init];
    self.recoder.delegate = self;
    
    TOAudioMeterView *amv = [[TOAudioMeterView alloc] initWithFrame:CGRectMake(40, 200, 80, 400)];
    [self.view addSubview:amv];
    self.audioMeterView = amv;
    
    self.levelMeterUpdateTimer = [NSTimer timerWithTimeInterval:1.0/25 target:self selector:@selector(updateAudioMeterView:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.levelMeterUpdateTimer forMode:NSDefaultRunLoopMode];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.recoder setUp];
    self.recoder.monitoringInput = YES;
}


- (IBAction)changeMonitorSetting:(id)sender
{
    self.recoder.monitoringInput = !self.recoder.monitoringInput;
    self.monitorButton.selected = !self.monitorButton.selected;
}


- (IBAction)prepareRecorder:(id)sender
{
    NSString *filename = self.filenameField.text;
    NSURL *documentDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    NSURL *fileURL = [documentDirectory URLByAppendingPathComponent:filename];
    
    NSError *error;
    
    [self.recoder prepareForRecordingWithFileURL:fileURL error:&error];
    
    if (error) {
        NSLog(@"%@", error);
    }
}


- (IBAction)recordPressed:(id)sender
{
    if (self.recoder.isRecording) {
        [self.recoder stopRecording];
    }
    else {
        [self.recoder startRecording];
    }
    
}

- (IBAction)gainChanged:(id)sender
{
    self.recoder.gain = self.gainSlider.value;
}


- (void)recorderDidStartRecording:(TORecorder *)recorder
{
    NSLog(@"recorder did start recording");
    self.recordButton.selected = YES;
}


- (void)recorderDidStopRecording:(TORecorder *)recorder
{
    NSLog(@"recorder did stop recording");
    self.recordButton.selected = NO;
}


- (void)updateAudioMeterView:(NSTimer *)timer
{
    // display between -50db and 0db
    
    double db = [self.recoder peakPowerForChannel:0];
    CGFloat value = 0.02 * db + 1;
    self.audioMeterView.value = value;
}

- (void)viewDidUnload {
    [self setGainSlider:nil];
    [super viewDidUnload];
}
@end
