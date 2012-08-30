//
//  TOPlugableSoundViewController.m
//  CircleSounds
//
//  Created by Tobias Ottenweller on 29.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOPlugableSoundController.h"

#import "TOEqualizerSound.h"
#import "TOPlugableSoundView.h"
#import "TOSoundDocument.h"
#import "TOSoundDocumentViewController.h"
#import "TOWaveformDrawer.h"
#import "TOColorInterpolator.h"


#define DEFAULT_PLAYBACK_RATE 1.0

#define MAX_ROTATION (2*M_PI) /* in radians */
#define MAX_ROTATION_PLAYBACK_RATE 4.0

#define MIN_ROTATION (-2*M_PI) /* in radians */
#define MIN_ROTATION_PLAYBACK_RATE 0.25


#define DEFAULT_GAIN 0 /* in db */

#define MAX_SCALE 2.0
#define MAX_SCALE_GAIN 24 /* in db */

#define MIN_SCALE 0.5
#define MIN_SCALE_GAIN -24 /* in db */




@interface TOPlugableSoundController () <UIGestureRecognizerDelegate>

@property (assign, nonatomic) double virtualViewRotation;
@property (assign, nonatomic) CGRect initialViewBounds; /* used for scaling. initial bounds for a single pinch gesture. */
@property (assign, nonatomic) CGFloat initialViewWidth; /* used for scaling. global initial width. used to calculate scale. */
@property (assign, nonatomic) double scale; /* the actual scale of the sound view */

@property (strong, nonatomic) UIColor *playbackColorNormal;
@property (strong, nonatomic) UIColor *playbackColorFast;
@property (strong, nonatomic) UIColor *playbackColorSlow;

@end



@implementation TOPlugableSoundController


- (id)init
{
    return nil;
}



- (id)initWithPlugableSound:(TOEqualizerSound *)sound atPosition:(CGRect)viewFrame;
{
    self = [super init];
    
    if (self) {
        NSParameterAssert(sound);
        
        _sound = sound;
        
        _soundView = [[TOPlugableSoundView alloc] initWithFrame:viewFrame];
        self.initialViewWidth = self.soundView.bounds.size.width;
        self.scale = 1.0;
        
        self.playbackColorNormal = [UIColor colorWithRed:46/255.0 green:169/255.0 blue:255/255.0 alpha:1.0];
        self.playbackColorFast = [UIColor colorWithRed:238/255.0 green:255/255.0 blue:51/255.0 alpha:1.0];
        self.playbackColorSlow = [UIColor colorWithRed:92/255.0 green:92/255.0 blue:91/255.0 alpha:1.0];
        
        
        
        
        self.soundView.color = self.playbackColorNormal; // TODO: remove after proper setup code is availible!
        
        
        
        
        [self setupGestureRecognizer];
        
        if (self.sound.audioFileURL) {
            [self setWaveformImage];
        }
        
        [self.sound addObserver:self forKeyPath:@"audioFileURL" options:0 context:NULL];
    }
    
    return self;
}


- (void)setWaveformImage
{
    // let the drawing of the waveform happen on a background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        TOWaveformDrawer *drawer = [[TOWaveformDrawer alloc] init];
        drawer.mode = TOWaveformDrawerModeCircle;
        drawer.waveformColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        drawer.imageSize = self.soundView.bounds.size;
        drawer.innerRadius = self.soundView.bounds.size.width * 0.3;
        
        UIImage *image = [drawer waveformFromImageAtURL:self.sound.audioFileURL];
        
        
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


- (void)displayDetailsSheet
{
    // TODO: display a details sheet
}


#pragma mark - Sound (View) manipulation

- (void)updatePlaybackSpeed
{
    // angle: -2 * M_PI <--> playback speed: 0.25 <--> color: playbackColorSlow
    // angle:         0 <--> playback speed: 1.00 <--> color: playbackColorNormal
    // angle:  2 * M_PI <--> playback speed: 4.00 <--> color: playbackColorFast
    
    
    if (self.virtualViewRotation > DEFAULT_PLAYBACK_RATE) {
        self.sound.playbackRate = ((MAX_ROTATION_PLAYBACK_RATE - DEFAULT_PLAYBACK_RATE) / MAX_ROTATION) * self.virtualViewRotation + DEFAULT_PLAYBACK_RATE;
        
        self.soundView.color = [TOColorInterpolator colorAtValue:self.sound.playbackRate
                                               betweenLowerValue:DEFAULT_PLAYBACK_RATE
                                                       withColor:self.playbackColorNormal
                                                  andHigherValue:MAX_ROTATION_PLAYBACK_RATE
                                                       withColor:self.playbackColorFast];
    }
    else {
        self.sound.playbackRate = ((MIN_ROTATION_PLAYBACK_RATE - DEFAULT_PLAYBACK_RATE) / MIN_ROTATION) * self.virtualViewRotation + DEFAULT_PLAYBACK_RATE;
        
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
    
    
    double soundStartToDocLengthRatio = soundViewFrame.origin.x / self.documentController.canvas.frame.size.width;
    self.sound.startTime = self.documentController.soundDocument.duration * soundStartToDocLengthRatio;
    
    NSLog(@"start time: %f", self.sound.startTime);
}


- (void)updatePlaybackVolume
{
    if (self.scale > 1.0) {
        double a = ((MAX_SCALE_GAIN - DEFAULT_GAIN) / (MAX_SCALE - 1));
        double b = DEFAULT_GAIN - a;
        
        self.sound.globalGain =   a * self.scale + b;
    }
    else
    {
        double a = ((MIN_SCALE_GAIN - DEFAULT_GAIN) / (MIN_SCALE - 1));
        double b = DEFAULT_GAIN - a;
        
        self.sound.globalGain = a * self.scale  + b;
    }
}


#pragma mark - Gesture Recognizer

- (void)setupGestureRecognizer
{
    // rotation (playback speed / color)
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
        
        [self updatePlaybackSpeed];
    }
}


- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self displayDetailsSheet];
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
        
        [self updatePlaybackVolume];
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

@end
