//
//  TORecordingViewController.m
//  CircleSounds
//
//  Created by Tobias Ottenweller on 08.09.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TORecordingViewController.h"

#import "TOSoundFileChangingViewController.h"
#import "TORecorder.h"
#import "TOEqualizerSound.h"
#import "TOSoundDocument.h"
#import "TOAudioFileManager.h"
#import "TOAudioMeterView.h"



@interface TORecordingViewController ()

@property (assign, nonatomic) BOOL restartDocumentWhenDisapearing;
@property (strong, nonatomic) NSArray *recordings; // contains NSURL objects pointing to the recordings
@property (strong, nonatomic) NSTimer *audioMeterUpdateTimer;

@end


@implementation TORecordingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.recordings = [TOAudioFileManager allRecordingsURLs];
    self.recorder = [[TORecorder alloc] init];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    TOSoundFileChangingViewController *sfcvc = (TOSoundFileChangingViewController *)self.parentViewController;
    
    if ([sfcvc.sound.document isRunning]) {
        self.restartDocumentWhenDisapearing = YES;
        
        [sfcvc.sound.document pause];
    }
    
    [self.recorder setUp];
    
    [self.monintorSwitch setOn:self.recorder.monitoringInput];
    self.gainSlider.value = self.recorder.gain;
    
    if (self.recorder.numChannels == 1) {
        self.leftAudioMeter.hidden = YES;
        self.leftAudioMeterLabel.hidden = YES;
        self.rightAudioMeterLabel.hidden = YES;
    }
    
    
    self.audioMeterUpdateTimer = [NSTimer timerWithTimeInterval:1.0/25
                                                         target:self
                                                       selector:@selector(updateAudioMeterView:)
                                                       userInfo:nil
                                                        repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:self.audioMeterUpdateTimer forMode:NSDefaultRunLoopMode];
    
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if ([self.recorder isRecording]) {
        [self.recorder stopRecording];
    }
    
    [self.recorder tearDown];
    [self.audioMeterUpdateTimer invalidate];
    
    TOSoundFileChangingViewController *sfcvc = (TOSoundFileChangingViewController *)self.parentViewController;
    
    if (self.restartDocumentWhenDisapearing) {
        [sfcvc.sound.document start];
    }
}

/**
 Returns a new URL for recordings not used by another recording.
 */
- (NSURL *)newRecordingURL
{
    NSURL *baseURL = [TOAudioFileManager recordingsDirectory];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    
    NSString *recordingFileName = [NSString stringWithFormat:@"Recording from %@", [dateFormatter stringFromDate:[NSDate date]]];
    NSURL *fileURL = [baseURL URLByAppendingPathComponent:recordingFileName];
    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileURL.path]) {
        
        NSUInteger number = 1;
        NSURL *fileURLWithNumber = fileURL;
        
        while ([[NSFileManager defaultManager] fileExistsAtPath:fileURLWithNumber.path]) {
            fileURLWithNumber = [fileURL URLByAppendingPathExtension:[NSString stringWithFormat:@" – %d", number]];
            number++;
        }
        
        fileURL = fileURLWithNumber;
    }
    
    return fileURL;
}


- (IBAction)monitorSwitchValueChanged:(id)sender
{
    self.recorder.monitoringInput = self.monintorSwitch.isOn;
}


- (IBAction)recButtonTouchUpInside:(id)sender
{
    if (self.recorder.isRecording) {
        [self.recorder stopRecording];
    }
    else {
        NSError *error;
        
        BOOL success = [self.recorder prepareForRecordingWithFileURL:[self newRecordingURL]
                                                error:&error];
        
        if (!success || error) {
            [[[UIAlertView alloc] initWithTitle:@"Something went wrong!"
                                       message:@"Starting the recording failed."
                                       delegate:nil cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
        else {
            [self.recorder startRecording];
        }
    }
}


- (IBAction)gainSliderValueChanged:(id)sender
{
    self.recorder.gain = self.gainSlider.value;
}


- (void)updateAudioMeterView:(NSTimer *)timer
{
    // display between -50db and 0db
    
    double avgDb = [self.recorder averagePowerForChannel:0];
    double peakDb = [self.recorder peakPowerForChannel:0];
    
    CGFloat avgValue = 0.02 * avgDb + 1;
    CGFloat peakValue = 0.02 * peakDb + 1;

    if (self.recorder.numChannels == 2) {
        self.rightAudioMeter.value = avgValue;
        self.rightAudioMeter.peakValue = peakValue;
        
        
        double avgDb = [self.recorder averagePowerForChannel:1];
        double peakDb = [self.recorder peakPowerForChannel:1];
        
        CGFloat avgValue = 0.02 * avgDb + 1;
        CGFloat peakValue = 0.02 * peakDb + 1;
        
        
        self.rightAudioMeter.value = avgValue;
        self.rightAudioMeter.peakValue = peakValue;
    }
    else {
        self.rightAudioMeter.value = avgValue;
        self.rightAudioMeter.peakValue = peakValue;
    }
}


# pragma mark - Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.recordings.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RecordingViewControllerTableViewCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    cell.textLabel.text = [self.recordings[indexPath.row] lastPathComponent];
    
    
    NSDictionary *metadata = TOMetadataForAudioFileURL(self.recordings[indexPath.row]);
    
    double duration = [metadata[@kAFInfoDictionary_ApproximateDurationInSeconds] doubleValue];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Duration: %d:%02d", (int)duration/60, (int)duration%60];

    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}


# pragma mark - Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TOSoundFileChangingViewController *sfcvc = (TOSoundFileChangingViewController *)self.parentViewController;
    [sfcvc handleAudioFileChangingWithURL:self.recordings[indexPath.row]];
}


#pragma mark - Recorder Delegate Methods

- (void)recorderDidStartRecording:(TORecorder *)recorder
{
    self.recButton.selected = YES;
}


- (void)recorderDidStopRecording:(TORecorder *)recorder
{
    self.recButton.selected = NO;
    
    
    // update the table view
    self.recordings = [TOAudioFileManager allRecordingsURLs];
    [self.recentRecordingsTableView reloadData];
}

@end
