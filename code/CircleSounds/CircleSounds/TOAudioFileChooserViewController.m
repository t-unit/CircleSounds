//
//  TOAudioFileChooserViewController.m
//  CircleSounds
//
//  Created by Tobias Ottenweller on 08.09.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOAudioFileChooserViewController.h"

#import "TOAudioFileManager.h"
#import "TORecordingViewController.h"
#import "TOCAShortcuts.h"
#import "TOSoundFileChangingViewController.h"


@interface TOAudioFileChooserViewController ()

@property (strong, nonatomic) NSArray *recordings; // contains NSURL objects pointing to the recordings
@property (strong, nonatomic) NSArray *suppliedSounds; // contains NSURL objects pointing to the sounds

@end

@implementation TOAudioFileChooserViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.recordings = [TOAudioFileManager allRecordingsURLs];
    self.suppliedSounds = [TOAudioFileManager allSuppliedSoundsURLs];
}


# pragma mark - Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 && self.recordings.count) {
        return self.recordings.count;
    }
    else {
        return self.suppliedSounds.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AudioFileChooserTableViewCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSURL *audioFileURL;
    
    
    if (indexPath.section == 0 && self.recordings.count) { // Recordings
        audioFileURL = self.recordings[indexPath.row];
    }
    else { // Sounds
        audioFileURL = self.suppliedSounds[indexPath.row];
    }
    
    NSDictionary *metadata = TOMetadataForAudioFileURL(audioFileURL);
    
    double duration = [metadata[@kAFInfoDictionary_ApproximateDurationInSeconds] doubleValue];
    NSString *artist = metadata[@kAFInfoDictionary_Artist];
    NSString *title = metadata[@kAFInfoDictionary_Title];
    
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Duration: %d:%02d", (int)duration/60, (int)duration%60];
    
    
    if (artist.length && title.length) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ – %@", artist, title];
    }
    else { // no artist or title information availible -> display the file name
        cell.textLabel.text = [audioFileURL lastPathComponent];
    }

    
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.recordings.count) {
        return 1;
    }
    else {
        return 2;
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (!self.recordings.count) {
        return nil;
    }
    
    if (section == 0) {
        return @"Recordings";
    }
    else {
        return @"Sounds";
    }
}


# pragma mark - Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *newSoundURL;
    
    if (indexPath.section == 0 && self.recordings.count) { // recordings
        newSoundURL = self.recordings[indexPath.row];
    }
    else { // sounds
        newSoundURL = self.suppliedSounds[indexPath.row];
    }
    
    TOSoundFileChangingViewController *sfcvc = (TOSoundFileChangingViewController *)self.parentViewController;
    [sfcvc handleAudioFileChangingWithURL:newSoundURL];
    
}


@end
