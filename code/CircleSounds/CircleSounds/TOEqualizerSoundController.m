//
//  TOEqualizerSoundController.m
//  CircleSounds
//
//  Created by Tobias Ottenweller on 29.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOEqualizerSoundController.h"

#import "TOEqualizerSound.h"
#import "TOPlugableSoundView.h"
#import "TOSoundDocument.h"
#import "TOSoundDocumentViewController.h"
#import "TOWaveformDrawer.h"
#import "TOColorInterpolator.h"
#import "TOLinearInterpolator.h"
#import "TOSoundDetailsPopoverViewController.h"
#import "TOSoundFileChangingViewController.h"


#define DEFAULT_PLAYBACK_RATE 1.0
#define DEFAULT_ROTATION 0.0

#define MAX_ROTATION (2.0*M_PI) /* in radians */
#define MAX_ROTATION_PLAYBACK_RATE 4.0

#define MIN_ROTATION (-2.0*M_PI) /* in radians */
#define MIN_ROTATION_PLAYBACK_RATE 0.25


#define DEFAULT_GAIN 0.0 /* in db */
#define DEFAULT_SCALE 1.0

#define MAX_SCALE 2.0
#define MAX_SCALE_GAIN 24.0 /* in db */

#define MIN_SCALE 0.5
#define MIN_SCALE_GAIN -24.0 /* in db */




@interface TOEqualizerSoundController () <UIGestureRecognizerDelegate, TOSoundDetailsPopoverViewControllerDelegate, TOSoundFileChangingViewControllerDelegate>

@property (assign, nonatomic) double virtualViewRotation;
@property (assign, nonatomic) CGRect initialViewBounds; /* used for scaling. initial bounds for a single pinch gesture. */
@property (assign, nonatomic) CGFloat initialViewWidth; /* used for scaling. global initial width. used to calculate scale. */
@property (assign, nonatomic) double scale; /* the actual scale of the sound view */

@property (strong, nonatomic) UIColor *playbackColorNormal;
@property (strong, nonatomic) UIColor *playbackColorFast;
@property (strong, nonatomic) UIColor *playbackColorSlow;

@property (strong, nonatomic) UIPopoverController *detailsPopoverController;
@property (strong, nonatomic) UIPopoverController *fileChooserPopoverController;

@end



@implementation TOEqualizerSoundController


+ (double)scaleFromGlobalGain:(AudioUnitParameterValue)gain
{
    if (gain > DEFAULT_GAIN) {
        return [TOLinearInterpolator yValueForX:gain
                      inLinearFunctionWithPoint:CGPointMake(MAX_SCALE_GAIN, MAX_SCALE)
                                       andPoint:CGPointMake(DEFAULT_GAIN, DEFAULT_SCALE)];
    }
    else {
        return [TOLinearInterpolator yValueForX:gain
                      inLinearFunctionWithPoint:CGPointMake(MIN_SCALE_GAIN, MIN_SCALE)
                                       andPoint:CGPointMake(DEFAULT_GAIN, DEFAULT_SCALE)];
    }
}


+ (AudioUnitParameterValue)globalGainFromScale:(double)scale
{
    if (scale > DEFAULT_SCALE) {
        return [TOLinearInterpolator yValueForX:scale
                      inLinearFunctionWithPoint:CGPointMake(MIN_SCALE, MIN_SCALE_GAIN)
                                       andPoint:CGPointMake(DEFAULT_SCALE, DEFAULT_GAIN)];
    }
    else {
        return [TOLinearInterpolator yValueForX:scale
                      inLinearFunctionWithPoint:CGPointMake(MAX_SCALE, MAX_SCALE_GAIN)
                                       andPoint:CGPointMake(DEFAULT_SCALE, DEFAULT_GAIN)];
    }
}


+ (AudioUnitParameterValue)playbackRateFromRotation:(double)rotation
{
    if (rotation > DEFAULT_ROTATION) {
        
        return [TOLinearInterpolator yValueForX:rotation
                      inLinearFunctionWithPoint:CGPointMake(DEFAULT_ROTATION, DEFAULT_PLAYBACK_RATE)
                                       andPoint:CGPointMake(MAX_ROTATION, MAX_ROTATION_PLAYBACK_RATE)];
    }
    else {
        
        return [TOLinearInterpolator yValueForX:rotation
                      inLinearFunctionWithPoint:CGPointMake(DEFAULT_ROTATION, DEFAULT_PLAYBACK_RATE)
                                       andPoint:CGPointMake(MIN_ROTATION, MIN_ROTATION_PLAYBACK_RATE)];
    }
}


+ (double)rotationFromPlaybackRate:(AudioUnitParameterValue)playbackRate
{

    if (playbackRate > DEFAULT_PLAYBACK_RATE) {
        return [TOLinearInterpolator yValueForX:playbackRate
                      inLinearFunctionWithPoint:CGPointMake(DEFAULT_PLAYBACK_RATE, DEFAULT_ROTATION)
                                       andPoint:CGPointMake(MAX_ROTATION_PLAYBACK_RATE, MAX_ROTATION)];
    }
    else {
        return [TOLinearInterpolator yValueForX:playbackRate
                      inLinearFunctionWithPoint:CGPointMake(DEFAULT_PLAYBACK_RATE, DEFAULT_ROTATION)
                                       andPoint:CGPointMake(MIN_ROTATION_PLAYBACK_RATE, MIN_ROTATION)];
    }
}


+ (AudioUnitParameterValue)startTimeWithViewSoundViewFrame:(CGRect)soundFrame inCanvasFrame:(CGRect)canvasFrame withTotalDuration:(double)duration
{
    CGFloat centerX = soundFrame.origin.x + (soundFrame.size.width / 2.0f);
    AudioUnitParameterValue startTime = duration * centerX / canvasFrame.size.width;
    
    return startTime;
}


+ (CGRect)soundFrameForStartTime:(double)startTime inCanvasFrame:(CGRect)canvasFrame withTotalDuration:(double)duration usingOriginalFrame:(CGRect)soundFrame
{
    CGFloat newCenterX = startTime / duration * canvasFrame.size.width;
    soundFrame.origin.x = newCenterX - (soundFrame.size.width / 2.0f);
    
    return soundFrame;
}



- (id)init
{
    return nil;
}



- (id)initWithPlugableSound:(TOEqualizerSound *)sound atPosition:(CGRect)viewFrame documentController:(TOSoundDocumentViewController *)documentController;
{
    self = [super init];
    
    if (self) {
        NSParameterAssert(sound);
        
        _sound = sound;
        _soundView = [[TOPlugableSoundView alloc] initWithFrame:viewFrame];
        _documentController = documentController;
        
        [self setupViewProperties];
        [self setupGestureRecognizer];
        
        
        if (self.sound.audioFileURL) {
            [self setWaveformImage];
        }
        
        [self.sound addObserver:self forKeyPath:@"audioFileURL" options:0 context:NULL];
    }
    
    return self;
}


- (void)dealloc
{
    [self.sound removeObserver:self forKeyPath:@"audioFileURL"];
}


- (void)setupViewProperties
{
    // playback rate & view color
    self.playbackColorNormal = [UIColor colorWithRed:0.180 green:0.663 blue:1.000 alpha:1.000];
    self.playbackColorFast = [UIColor colorWithRed:0.933 green:1.000 blue:0.200 alpha:1.000];
    self.playbackColorSlow = [UIColor colorWithRed:0.361 green:0.361 blue:0.357 alpha:1.000];
    
    self.virtualViewRotation = [[self class] rotationFromPlaybackRate:self.sound.playbackRate];
    [self updateViewColor];
    
    
    // view scale & gain
    self.initialViewWidth = self.soundView.bounds.size.width;
    self.scale = [[self class] scaleFromGlobalGain:self.sound.globalGain];
    
    
    // start time & view postion
    self.sound.startTime = [[self class] startTimeWithViewSoundViewFrame:self.soundView.frame
                                                           inCanvasFrame:self.documentController.canvas.frame
                                                       withTotalDuration:self.documentController.soundDocument.duration];
}


- (void)setWaveformImage
{
    // let the drawing of the waveform happen on a background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        TOWaveformDrawer *drawer = [[TOWaveformDrawer alloc] init];
        drawer.mode = TOWaveformDrawerModeCircle;
        drawer.waveformColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        drawer.imageSize = CGSizeMake(self.initialViewWidth * 1.5, self.initialViewWidth * 1.5);
        drawer.innerRadius = self.initialViewWidth * 0.40;
        
        UIImage *image = [drawer waveformFromAudioFileAtURL:self.sound.audioFileURL];
        
        // setting the image must happen on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            self.soundView.waveformImage = image;
        });
    });
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isEqual:self.sound] && [keyPath isEqualToString:@"audioFileURL"]) {
        [self setWaveformImage];
    }
}


#pragma mark - Popover handling

- (void)displayDetailsPopover
{
    TOSoundDetailsPopoverViewController *detailsViewController = [self.documentController.storyboard instantiateViewControllerWithIdentifier:@"popover view controller"];
    detailsViewController.delegate = self;
    detailsViewController.sound = self.sound;
    
    self.detailsPopoverController = [[UIPopoverController alloc] initWithContentViewController:detailsViewController];
    CGRect popoverRect = CGRectMake(self.soundView.frame.origin.x + self.soundView.frame.size.width/2, self.soundView.frame.origin.y + self.soundView.frame.size.height, 1, 1);
    
    [self.detailsPopoverController presentPopoverFromRect:popoverRect
                                                   inView:self.documentController.view
                                 permittedArrowDirections:UIPopoverArrowDirectionAny
                                                 animated:YES];
}


- (void)displayAudioFileChooserPopover
{
    TOSoundFileChangingViewController *audioFileChooserViewController = [self.documentController.storyboard instantiateViewControllerWithIdentifier:@"sound audio file view controller"];
    audioFileChooserViewController.delegate = self;
    audioFileChooserViewController.sound = self.sound;
    
    self.fileChooserPopoverController = [[UIPopoverController alloc] initWithContentViewController:audioFileChooserViewController];
    CGRect popoverRect = CGRectMake(self.soundView.frame.origin.x + self.soundView.frame.size.width/2, self.soundView.frame.origin.y + self.soundView.frame.size.height, 1, 1);
    
    [self.fileChooserPopoverController presentPopoverFromRect:popoverRect
                                                       inView:self.documentController.view
                                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                                     animated:YES];
    
}


#pragma mark - Sound (View) Property Manipulation

- (void)updateViewColor
{
    if (self.virtualViewRotation > DEFAULT_ROTATION) {
        self.soundView.color = [TOColorInterpolator colorAtValue:self.sound.playbackRate
                                               betweenLowerValue:DEFAULT_PLAYBACK_RATE
                                                       withColor:self.playbackColorNormal
                                                  andHigherValue:MAX_ROTATION_PLAYBACK_RATE
                                                       withColor:self.playbackColorFast];
    }
    else {
        self.soundView.color = [TOColorInterpolator colorAtValue:self.sound.playbackRate
                                               betweenLowerValue:MIN_ROTATION_PLAYBACK_RATE
                                                       withColor:self.playbackColorSlow
                                                  andHigherValue:DEFAULT_PLAYBACK_RATE
                                                       withColor:self.playbackColorNormal];
    }
}


- (void)updatePlaybackStartPostionWithTranslation:(CGPoint)translation
{
    CGRect soundViewFrame = self.soundView.frame;
    
    soundViewFrame.origin.x += translation.x;
    soundViewFrame.origin.y += translation.y;
    
    self.soundView.frame = soundViewFrame;
    
    
    self.sound.startTime = [[self class] startTimeWithViewSoundViewFrame:soundViewFrame
                                                           inCanvasFrame:self.documentController.canvas.frame
                                                       withTotalDuration:self.documentController.soundDocument.duration];
}


#pragma mark - Gesture Recognizer

- (void)setupGestureRecognizer
{
    // rotation (playback rate / color)
    UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
    rotationGestureRecognizer.delegate = self;
    [self.soundView addGestureRecognizer:rotationGestureRecognizer];
    
    
    // tap (advanced settings)
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGestureRecognizer.delegate = self;
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    [self.soundView addGestureRecognizer:tapGestureRecognizer];
    
    
    // pinch (volume / size)
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinchGestureRecognizer.delegate = self;
    [self.soundView addGestureRecognizer:pinchGestureRecognizer];
    
    
    // pan (playback start / position)
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panGestureRecognizer.delegate = self;
    panGestureRecognizer.maximumNumberOfTouches = 1;
    panGestureRecognizer.minimumNumberOfTouches = 1;
    [self.soundView addGestureRecognizer:panGestureRecognizer];
}


- (void)handleRotation:(UIRotationGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateCancelled || sender.state == UIGestureRecognizerStateFailed) {
        return;
    }
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        sender.rotation = self.virtualViewRotation;
    }
    else {
        self.virtualViewRotation = sender.rotation;
        
        if (self.virtualViewRotation < MIN_ROTATION) {
            self.virtualViewRotation = MIN_ROTATION;
        }
        else if (self.virtualViewRotation > MAX_ROTATION) {
            self.virtualViewRotation = MAX_ROTATION;
        }
        
        self.sound.playbackRate = [[self class] playbackRateFromRotation:self.virtualViewRotation];
        [self updateViewColor];
    }
}


- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self displayDetailsPopover];
    }
}


- (void)handlePinch:(UIPinchGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateCancelled || sender.state == UIGestureRecognizerStateFailed) {
        return;
    }
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.initialViewBounds = self.soundView.bounds;
    }

    CGAffineTransform scaledTransform = CGAffineTransformScale(CGAffineTransformIdentity, sender.scale, sender.scale);
    CGRect newBounds = CGRectApplyAffineTransform(self.initialViewBounds, scaledTransform);
    
    double newScale = newBounds.size.width / self.initialViewWidth;
    
    if (newScale > MIN_SCALE && newScale < MAX_SCALE) {
        self.soundView.bounds = newBounds;
        self.scale = newScale;
        
        self.sound.globalGain = [[self class] globalGainFromScale:self.scale];
    }
}


- (void)handlePan:(UIPanGestureRecognizer *)sender
{
    if (sender.state != UIGestureRecognizerStateChanged && sender.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    CGPoint translation = [sender translationInView:self.soundView];
    [self updatePlaybackStartPostionWithTranslation:translation];
    
    [sender setTranslation:CGPointZero inView:self.soundView];
}


#pragma mark - Gesture Recognizer Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES; // enable pinching and rotating at the same time
}


#pragma mark - Details View Controller Delegate Methods

- (void)detailsController:(TOSoundDetailsPopoverViewController *)detailsController soundShouldBeRemovedFromDocument:(TOEqualizerSound *)sound
{
    [self.detailsPopoverController dismissPopoverAnimated:NO];
    [self.documentController removeSoundController:self];
}


- (void)detailsControllerChangeSoundFileButtonPressed:(TOSoundDetailsPopoverViewController *)detailsController
{
    [self.detailsPopoverController dismissPopoverAnimated:NO];
    [self displayAudioFileChooserPopover];
}


#pragma mark - Sound File Changing View Cotnroller Delegate Methods

- (void)soundFileChangingViewControllerDidChangeSoundFile:(TOSoundFileChangingViewController *)sender
{
    [self.fileChooserPopoverController dismissPopoverAnimated:NO];
}

@end
