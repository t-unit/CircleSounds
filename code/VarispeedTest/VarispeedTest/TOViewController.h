//
//  TOViewController.h
//  VarispeedTest
//
//  Created by Tobias Ottenweller on 20.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TOVarispeed;


@interface TOViewController : UIViewController

@property (strong, nonatomic) TOVarispeed *varispeed;

@property (weak, nonatomic) IBOutlet UISlider *rateSlider;
- (IBAction)rateSliderValueChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;


@property (weak, nonatomic) IBOutlet UISlider *centsSlider;
- (IBAction)centsSliderValueChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *centsLabel;

@end
