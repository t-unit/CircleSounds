//
//  TOSoundDetailsPopoverViewController.m
//  CircleSounds
//
//  Created by Tobias Ottenweller on 03.09.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOSoundDetailsPopoverViewController.h"

#import "TOSoundDetailsPopoverViewControllerDelegate.h"
#import "TOEqualizerSound.h"
#import "TOWaveformDrawer.h"
#import "TOHandleView.h"


@interface TOSoundDetailsPopoverViewController ()

@end

@implementation TOSoundDetailsPopoverViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setViewPropertiesUsingSound];
	[self setupGestureRecognizer];
}


- (void)setViewPropertiesUsingSound
{
    if (self.sound.audioFileURL) {
        [self setWaveformImage];
    }
    
    
    self.loopCountLabel.text = [NSString stringWithFormat:@"%ld", self.sound.loopCount];
    self.loopCountStepper.value = self.sound.loopCount;
    self.songArtistLabel.text = self.sound.fileSongArtist;
    self.songNameLabel.text = self.sound.fileSongName;
    self.songDurationLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)self.sound.duration/60, (int)self.sound.duration%60];
    
    
    for (NSUInteger i=0; i<self.sound.bands.count; i++) {
        UISlider *slider = (UISlider *)[self.equalizerCanvas viewWithTag:i];
        slider.value = [self.sound gainForBandAtPosition:i];
    }
    
    double startToDurationRatio = self.sound.regionStart / self.sound.fileDuration;
    double translation = startToDurationRatio * self.waveformImageView.frame.size.width;
    
    self.leftTrimmGestureCatcher.transform = CGAffineTransformTranslate(self.leftTrimmGestureCatcher.transform, translation, 0);
    self.leftTrimmOverlay.transform = self.leftTrimmGestureCatcher.transform;
    
    
    double endToDurtionRatio = (self.sound.regionStart + self.sound.regionDuration) / self.sound.fileDuration;
    
    translation = -(self.waveformImageView.frame.size.width * (-endToDurtionRatio + 1));
    
    self.rightTrimmGestureCatcher.transform = CGAffineTransformTranslate(self.rightTrimmGestureCatcher.transform, translation, 0);
    self.rightTrimmOverlay.transform = self.rightTrimmGestureCatcher.transform;
}


- (void)setWaveformImage
{
    // let the drawing of the waveform happen on a background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        TOWaveformDrawer *drawer = [[TOWaveformDrawer alloc] init];
        drawer.mode = TOWaveformDrawerModeRectangle;
        drawer.waveformColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        drawer.imageSize = self.waveformImageView.bounds.size;
        
        UIImage *image = [drawer waveformFromImageAtURL:self.sound.audioFileURL];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.waveformImageView.image = image;
        });
    });
}

#pragma mark - Gesture Recognition

- (void)setupGestureRecognizer
{
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftHandleGesture:)];
    [self.leftTrimmGestureCatcher addGestureRecognizer:panGestureRecognizer];
    
    panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightHandleGesture:)];
    [self.rightTrimmGestureCatcher addGestureRecognizer:panGestureRecognizer];
}


- (void)handleLeftHandleGesture:(UIPanGestureRecognizer *)sender
{
    CGFloat translationX = [sender translationInView:self.view].x;

    
    switch (sender.state) {
            
        case UIGestureRecognizerStateChanged:
        {
            CGAffineTransform rightTransform = self.rightTrimmGestureCatcher.transform;
            CGAffineTransform leftTransform = self.leftTrimmGestureCatcher.transform;
            
            // don't translate out of the super view
            if (leftTransform.tx <= 0 && translationX < 0) {
                self.leftTrimmGestureCatcher.transform = CGAffineTransformMakeTranslation(0, 0);
                self.leftTrimmOverlay.transform = self.leftTrimmGestureCatcher.transform;
                
                break;
            }
            
            // don't translate over the other trimm gesture catcher
            if (translationX > 0 &&
                fabsf(rightTransform.tx) + fabsf(leftTransform.tx) + self.leftTrimmGestureCatcher.frame.size.width + 4 >= self.waveformImageView.frame.size.width) {
                
                translationX = self.waveformImageView.frame.size.width - fabsf(rightTransform.tx) - self.leftTrimmGestureCatcher.frame.size.width - 4;
                
                self.leftTrimmGestureCatcher.transform = CGAffineTransformMakeTranslation(translationX, 0);
                self.leftTrimmOverlay.transform = self.leftTrimmGestureCatcher.transform;
                
                break;
            }
            
            // apply the translation
            self.leftTrimmGestureCatcher.transform = CGAffineTransformTranslate(self.leftTrimmGestureCatcher.transform, translationX, 0);
            self.leftTrimmOverlay.transform = self.leftTrimmGestureCatcher.transform;
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            double startToDurationRatio = self.leftTrimmGestureCatcher.transform.tx / self.waveformImageView.frame.size.width;
            self.sound.regionStart = self.sound.fileDuration * startToDurationRatio;
            
            break;
        }
            
        default:
            break;
    }
    
    [sender setTranslation:CGPointZero inView:self.view];
}


- (void)handleRightHandleGesture:(UIPanGestureRecognizer *)sender
{
    CGFloat translationX = [sender translationInView:self.view].x;
    
    
    switch (sender.state) {
            
        case UIGestureRecognizerStateChanged:
        {
            CGAffineTransform rightTransform = self.rightTrimmGestureCatcher.transform;
            CGAffineTransform leftTransform = self.leftTrimmGestureCatcher.transform;
            
            // don't translate out of the super view
            if (rightTransform.tx >= 0 && translationX > 0) {
                self.rightTrimmGestureCatcher.transform = CGAffineTransformMakeTranslation(0, 0);
                self.rightTrimmOverlay.transform = self.rightTrimmGestureCatcher.transform;
                
                break;
            }
            
            // don't translate over the other trimm gesture catcher
            if (translationX < 0 &&
                fabsf(rightTransform.tx) + fabsf(leftTransform.tx) + self.leftTrimmGestureCatcher.frame.size.width + 4 >= self.waveformImageView.frame.size.width) {
                
                translationX = -(self.waveformImageView.frame.size.width-fabsf(leftTransform.tx)) + self.leftTrimmGestureCatcher.frame.size.width + 4;
                
                self.rightTrimmGestureCatcher.transform = CGAffineTransformMakeTranslation(translationX, 0);
                self.rightTrimmOverlay.transform = self.rightTrimmGestureCatcher.transform;
                
                break;
            }
            
            // apply the translation
            self.rightTrimmGestureCatcher.transform = CGAffineTransformTranslate(self.rightTrimmGestureCatcher.transform, translationX, 0);
            self.rightTrimmOverlay.transform = self.rightTrimmGestureCatcher.transform;
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            double endToDurationRatio = -(((1-self.rightTrimmGestureCatcher.transform.tx) / self.waveformImageView.frame.size.width) - 1);
            double endTime = self.sound.fileDuration * endToDurationRatio;
            
            self.sound.regionDuration = endTime - self.sound.regionStart;
            
            NSLog(@"ratio: %f endTime: %f", endToDurationRatio, endTime);

            break;
        }
            
        default:
            break;
    }
    
    [sender setTranslation:CGPointZero inView:self.view];
}


#pragma mark - Buttons Event Handling

- (IBAction)loopCountStepperValueChanged:(id)sender
{
    self.sound.loopCount = self.loopCountStepper.value;
    self.loopCountLabel.text = [NSString stringWithFormat:@"%ld", self.sound.loopCount];
}


- (IBAction)removeButtonPressed:(id)sender
{
    [self.delegate detailsController:self soundShouldBeRemovedFromDocument:self.sound];
}


- (IBAction)resetEffectsButtonPressed:(id)sender
{
    self.sound.loopCount = 1;
    self.loopCountLabel.text = [NSString stringWithFormat:@"%ld", self.sound.loopCount];
    self.loopCountStepper.value = self.sound.loopCount;
    
    self.sound.globalGain = 0;
    self.sound.playbackRate = 1.0;
    
    for (NSUInteger i=0; i<self.sound.bands.count; i++) {
        UISlider *slider = (UISlider *)[self.equalizerCanvas viewWithTag:i];
        slider.value = 0;
        
        [self.sound setGain:0 forBandAtPosition:i];
    }
    
}


- (IBAction)changeSoundButtonPressed:(id)sender
{
    [self.delegate detailsControllerChangeSoundFileButtonPressed:self];
}


#pragma mark - EQ

- (IBAction)eqSliderValueChanged:(UISlider *)sender
{
    NSInteger bandIndex = sender.tag;
    [self.sound setGain:sender.value forBandAtPosition:bandIndex];
}

@end
