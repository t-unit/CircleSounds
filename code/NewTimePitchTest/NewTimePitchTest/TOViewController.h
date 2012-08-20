//
//  TOViewController.h
//  NewTimePitchTest
//
//  Created by Tobias Ottenweller on 20.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TOTimePitch.h"


@interface TOViewController : UIViewController

@property (strong, nonatomic) TOTimePitch *timePitch;


@property (weak, nonatomic) IBOutlet UILabel *pitchLabel;

@property (weak, nonatomic) IBOutlet UISlider *pitchSlider;
- (IBAction)pitchSliderValueChanged:(id)sender;

@end
