//
//  TOViewController.m
//  RecordPlayThrough
//
//  Created by Tobias Ottenweller on 08.07.12.
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


//- (void)recorder:(TORecorder *)recorder didGetNewData:(AudioBufferList *)bufferList
//{
//    if (bufferList->mNumberBuffers > 1) {
//        NSLog(@"interleaved non MONO -  not supported yet");
//    }
//    
//    else if (bufferList->mNumberBuffers == 0) {
//        NSLog(@"no data!");
//    }
//    
//    else if (bufferList->mBuffers[0].mNumberChannels > 1) {
//        NSLog(@"noninterleaved non MONO -  not supported yet");
//    }
//    
//    else {
////        NSLog(@"got new data from recorder");
//        AudioBuffer buffer = bufferList->mBuffers[0];
//        
//        UInt32 numSamples = buffer.mDataByteSize / sizeof(AudioSampleType);
//        AudioSampleType *samples = buffer.mData;
//        
//        for (UInt32 i=0; i<numSamples; i++) {
//            AudioSampleType sample = samples[i];
//            
//            [self.waveform addObject:@(sample)];
//            
//            if (self.waveform.count > 10000) {
//                [self.waveform removeObjectAtIndex:0];
//            }
//        }
//    }
//
//    [self.waveFormView setNeedsDisplay];
//    
//    
//    AudioBuffer buffer = bufferList->mBuffers[0];
//    [self.audioMeterController setNeedsUpdateWithBuffer:buffer];
//}


- (NSArray *)points
{
    return nil;
}


- (void)updateAudioMeterView:(NSTimer *)timer
{
    double db = [self.recoder averagePowerForChannel:0];
    CGFloat value = 0.01 * db + 1;
    self.audioMeterView.value = value;
}

@end
