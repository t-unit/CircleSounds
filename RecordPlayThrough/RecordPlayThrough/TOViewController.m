//
//  TOViewController.m
//  RecordPlayThrough
//
//  Created by Tobias Ottenweller on 08.07.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOViewController.h"

@interface TOViewController ()

@end

@implementation TOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    self.recoder = [[TORecorder alloc] init];
    [self.recoder setUp];
    
    self.recoder.isMonitoringInput = YES;
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


- (IBAction)changeMonitorSetting:(id)sender
{
    self.recoder.isMonitoringInput = !self.recoder.isMonitoringInput;
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

@end
