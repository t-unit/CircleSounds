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



@interface TORecordingViewController ()

@property (assign, nonatomic) BOOL restartDocumentWhenDisapearing;
@property (strong, nonatomic) NSArray *recordings; // contains NSURL objects pointing to the recordings

@end


@implementation TORecordingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.recordings = [TOAudioFileManager allRecordingsURLs];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    TOSoundFileChangingViewController *sfcvc = (TOSoundFileChangingViewController *)self.parentViewController;
    
    if ([sfcvc.sound.document isRunning]) {
        self.restartDocumentWhenDisapearing = YES;
        
        [sfcvc.sound.document pause];
    }
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    
    TOSoundFileChangingViewController *sfcvc = (TOSoundFileChangingViewController *)self.parentViewController;
    
    if (self.restartDocumentWhenDisapearing) {
        [sfcvc.sound.document start];
    }
}


- (IBAction)monitorSwitchValueChanged:(id)sender {
}
- (IBAction)recButtonTouchUpInside:(id)sender {
}



# pragma mark - Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
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
    
}

- (IBAction)gainSliderValueChanged:(id)sender {
}
@end
