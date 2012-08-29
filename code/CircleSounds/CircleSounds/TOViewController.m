//
//  TOViewController.m
//  CircleSounds
//
//  Created by Tobias Ottenweller on 29.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOViewController.h"

#import "TOPlugableSoundController.h"
#import "TOPlugableSoundView.h"
#import "TOEqualizerSound.h"


@interface TOViewController ()

@property (strong, nonatomic) TOPlugableSoundController *soundController;

@end

@implementation TOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    TOEqualizerSound *sound = [[TOEqualizerSound alloc] init];
    
    self.soundController = [[TOPlugableSoundController alloc] initWithPlugableSound:sound
                                                                         atPosition:CGRectMake(100, 100, 400, 400)];
    
    [self.view addSubview:self.soundController.soundView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
