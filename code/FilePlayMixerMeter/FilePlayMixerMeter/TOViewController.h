//
//  TOViewController.h
//  FilePlayMixerMeter
//
//  Created by Tobias Ottenweller on 15.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TOAudioMeterView;

@interface TOViewController : UIViewController

@property (weak, nonatomic)  IBOutlet TOAudioMeterView *audioMeterView1;
@property (weak, nonatomic) IBOutlet TOAudioMeterView *audioMeterView2;


//............................................................................
// Volume (Mixer)

@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
- (IBAction)volumeSliderValueChanged:(id)sender;
@end
