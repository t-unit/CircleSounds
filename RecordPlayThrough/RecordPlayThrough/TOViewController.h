//
//  TOViewController.h
//  RecordPlayThrough
//
//  Created by Tobias Ottenweller on 08.07.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TORecorder.h"
#import "TORecorderDelegate.h"


@interface TOViewController : UIViewController <TORecorderDelegate>

@property (strong, nonatomic) TORecorder *recoder;

@property (weak, nonatomic) IBOutlet UIButton *monitorButton;
@property (weak, nonatomic) IBOutlet UITextField *filenameField;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;


- (IBAction)changeMonitorSetting:(id)sender;
- (IBAction)prepareRecorder:(id)sender;
- (IBAction)recordPressed:(id)sender;

@end
