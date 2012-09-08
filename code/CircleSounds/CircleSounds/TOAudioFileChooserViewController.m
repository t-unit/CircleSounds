//
//  TOAudioFileChooserViewController.m
//  CircleSounds
//
//  Created by Tobias Ottenweller on 08.09.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOAudioFileChooserViewController.h"
#import "TOAppDelegate.h"


@interface TOAudioFileChooserViewController ()

@property (strong, nonatomic) NSArray *recordings; // contains NSURL objects pointing to the recordings
@property (strong, nonatomic) NSArray *suppliedSounds; // contains NSURL objects pointing to the sounds

@end

@implementation TOAudioFileChooserViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    
    // look for availible recordings
    TOAppDelegate *appDelegate = (TOAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSError *error;
    
    NSArray *recordings = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:appDelegate.recordingsDirectory
                                                        includingPropertiesForKeys:@[]
                                                                           options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                             error:&error];
    
    if (!recordings || error) {
        self.recordings = @[]; // no recordings are availible
    }
    else {
        self.recordings = recordings;
    }
    
    
    // create the supplied sounds array
    // TODO: find a better way for gettting the urls
    self.suppliedSounds = @[[[NSBundle mainBundle] URLForResource:@"clong-1" withExtension:@"wav"],
                            [[NSBundle mainBundle] URLForResource:@"clong-2" withExtension:@"wav"],
                            [[NSBundle mainBundle] URLForResource:@"electric-drill-2" withExtension:@"wav"],
                            [[NSBundle mainBundle] URLForResource:@"freezer-hum-1" withExtension:@"wav"],
                            [[NSBundle mainBundle] URLForResource:@"grass-trimmer-1" withExtension:@"wav"],
                            [[NSBundle mainBundle] URLForResource:@"hammering-1" withExtension:@"wav"],
                            [[NSBundle mainBundle] URLForResource:@"08 Hope You're Feeling Better" withExtension:@"m4a"]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    if (indexPath.section == 0 && self.recordings.count) { // Recordings
        cell.textLabel.text = [self.recordings[indexPath.row] lastPathComponent];
        cell.detailTextLabel.text = @"Duration: ??:??"; // TODO: display duration
    }
    else { // Sounds
        cell.textLabel.text = [self.suppliedSounds[indexPath.row] lastPathComponent]; // TODO: display artist and title
        cell.detailTextLabel.text = @"Duration: ??:??"; // TODO: display duration
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


@end
