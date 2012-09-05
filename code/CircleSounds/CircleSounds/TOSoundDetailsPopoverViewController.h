//
//  TOSoundDetailsPopoverViewController.h
//  CircleSounds
//
//  Created by Tobias Ottenweller on 03.09.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TOEqualizerSound;
@class TOHandleView;
@protocol TOSoundDetailsPopoverViewControllerDelegate;



@interface TOSoundDetailsPopoverViewController : UIViewController

@property (strong, nonatomic) TOEqualizerSound *sound;
@property (weak, nonatomic) id<TOSoundDetailsPopoverViewControllerDelegate> delegate;


/* Interface Builder Properties and Callbacks */
@property (weak, nonatomic) IBOutlet UIImageView *waveformImageView;

@property (weak, nonatomic) IBOutlet TOHandleView *leftTrimmGestureCatcher;
@property (weak, nonatomic) IBOutlet UIView *leftTrimmOverlay;

@property (weak, nonatomic) IBOutlet TOHandleView *rightTrimmGestureCatcher;
@property (weak, nonatomic) IBOutlet UIView *rightTrimmOverlay;


@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
- (IBAction)segmentedControlValueChanged:(id)sender;


@property (weak, nonatomic) IBOutlet UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *songArtistLabel;
@property (weak, nonatomic) IBOutlet UILabel *songDurationLabel;

@property (weak, nonatomic) IBOutlet UILabel *loopCountLabel;
- (IBAction)loopCountStepperValueChanged:(id)sender;


- (IBAction)removeButtonPressed:(id)sender;
- (IBAction)resetEffectsButtonPressed:(id)sender;
- (IBAction)changeSoundButtonPressed:(id)sender;

@end
