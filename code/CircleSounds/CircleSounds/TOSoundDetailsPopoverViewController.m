//
//  TOSoundDetailsPopoverViewController.m
//  CircleSounds
//
//  Created by Tobias Ottenweller on 03.09.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOSoundDetailsPopoverViewController.h"

@interface TOSoundDetailsPopoverViewController ()

@end

@implementation TOSoundDetailsPopoverViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)segmentedControlValueChanged:(id)sender {
}
- (IBAction)loopCountStepperValueChanged:(id)sender {
}

- (IBAction)removeButtonPressed:(id)sender {
}

- (IBAction)resetEffectsButtonPressed:(id)sender {
}

- (IBAction)changeSoundButtonPressed:(id)sender {
}
@end
