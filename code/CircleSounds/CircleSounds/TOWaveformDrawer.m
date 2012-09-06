//
//  TOWaveformDrawer.m
//  WaveformViewer
//
//  Created by Tobias Ottenweller on 27.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOWaveformDrawer.h"
#import <AudioToolbox/AudioToolbox.h>
#import "TOCAShortcuts.h"


@interface TOWaveformDrawer ()

// audio file details
@property (assign, nonatomic) ExtAudioFileRef extAudioFile;
@property (assign, nonatomic) Float64 audioFileDuration;
@property (assign, nonatomic) AudioStreamBasicDescription audioFileClientFormat;


// drawing details
@property (assign, nonatomic) CGFloat base; /* Base radius or base height depending on mode.
                                               The postion where samples with zero amplitude 
                                               are drawn.
                                             */
@property (assign, nonatomic) CGFloat distBetweenSamples; /* in radians on circle mode */
@property (assign, nonatomic) CGFloat maxAmplitudeInPoints; /* only used in rectangle mode */
@property (assign, nonatomic) CGFloat outerRadius; /* only used in circle mode */
@property (assign, nonatomic) CGPoint center; /* Center of the circle. Only used in circle mode */

@property (assign, nonatomic) AudioSampleType peakSample; /* absolute value */

@end


@implementation TOWaveformDrawer

- (void)dealloc
{
    if (self.extAudioFile) {
        TOThrowOnError(ExtAudioFileDispose(self.extAudioFile));
    }
}


#define MIN_SAMPLE_RATE 500
#define MAX_SAMPLE_RATE 44100

- (void)setupExtAudioFileAtURL:(NSURL *)url
{
    if (self.extAudioFile) {
        TOThrowOnError(ExtAudioFileDispose(self.extAudioFile));
    }
    
    
    // open the file
    ExtAudioFileRef extFile;
    TOThrowOnError(ExtAudioFileOpenURL((__bridge CFURLRef)(url), &extFile));
    self.extAudioFile = extFile;
    
    
    // obtain file duration
    AudioFileID file;
    UInt32 propSize = sizeof(file);
    TOThrowOnError(ExtAudioFileGetProperty(extFile,
                                           kExtAudioFileProperty_AudioFile,
                                           &propSize,
                                           &file));
    
    Float64 fileDuration;
    propSize = sizeof(fileDuration);
    TOThrowOnError(AudioFileGetProperty(file,
                                        kAudioFilePropertyEstimatedDuration,
                                        &propSize,
                                        &fileDuration));
    
    self.audioFileDuration = fileDuration;
    
    
    // set the client stream format
    AudioStreamBasicDescription clientFormat = TOCanonicalStreamFormat(1, true);
    
    if (fileDuration > 60) {
        clientFormat.mSampleRate = 551.25;
    }
    else if (fileDuration > 30) {
        clientFormat.mSampleRate = 1102.5;
    }
    else if (fileDuration > 10) {
        clientFormat.mSampleRate = 2205;
    }
    else {
        clientFormat.mSampleRate = 4410;
    }
    
    
    TOThrowOnError(ExtAudioFileSetProperty(extFile,
                                           kExtAudioFileProperty_ClientDataFormat,
                                           sizeof(clientFormat),
                                           &clientFormat));
    
    self.audioFileClientFormat = clientFormat;
    
    
}


- (CGPoint)pointInRectWithSample:(AudioSampleType)sample atPosition:(UInt64)samplePostion
{    
    CGFloat x = samplePostion * self.distBetweenSamples;
    CGFloat y = self.base + ((CGFloat)sample / (CGFloat)self.peakSample * (CGFloat)self.maxAmplitudeInPoints);
    
    return CGPointMake(x, y);
}


- (CGPoint)pointInCircletWithSample:(AudioSampleType)sample atPosition:(UInt64)samplePostion
{
    CGFloat angle = M_PI - (samplePostion * self.distBetweenSamples);
    CGFloat amplitude =  (CGFloat)sample / (CGFloat)self.peakSample;
    
    CGPoint basePoint = CGPointMake(sinf(angle) * self.base, cosf(angle) * self.base);
    CGPoint maxPosAmplitudePoint = CGPointMake(sinf(angle) * self.outerRadius, cosf(angle) * self.outerRadius);
    CGPoint vecBaseMax = CGPointMake(maxPosAmplitudePoint.x - basePoint.x, maxPosAmplitudePoint.y - basePoint.y);
    
    
    CGFloat x = self.center.x  + basePoint.x + (vecBaseMax.x * amplitude);
    CGFloat y = self.center.y + basePoint.y + (vecBaseMax.y * amplitude);

    
    return CGPointMake(x, y);
}


- (UIBezierPath *)waveFormPath
{
    // prepare audio file reading
    UInt32 outputBuferSize = 32 * 1024; // 32 KB
    UInt32 sizePerPacket = self.audioFileClientFormat.mBytesPerPacket;
    UInt32 packetsPerBuffer = outputBuferSize / sizePerPacket;
    
    void *outputBuffer = malloc(sizeof(UInt8) * outputBuferSize);
    UInt32 filePacketPosition = 0; // In bytes
    UInt64 samplePos = 0;
    
    
    NSMutableArray *samplesArray = [[NSMutableArray alloc] init];
    AudioSampleType peakSample = 0;
    
    // read from the audio file
    while (1) {
        AudioBufferList audioLPCMData;
        audioLPCMData.mNumberBuffers = 1;
        audioLPCMData.mBuffers[0].mNumberChannels = self.audioFileClientFormat.mChannelsPerFrame;
        audioLPCMData.mBuffers[0].mDataByteSize = outputBuferSize;
        audioLPCMData.mBuffers[0].mData = outputBuffer;
        
        UInt32 frameCount = packetsPerBuffer;
        TOThrowOnError(ExtAudioFileRead(self.extAudioFile,
                                        &frameCount,
                                        &audioLPCMData));
        
        if (frameCount == 0) {
            break; // finished reading file
        }
        
        
        AudioSampleType *samples = audioLPCMData.mBuffers[0].mData;
        UInt32 numSamples = audioLPCMData.mBuffers[0].mDataByteSize / sizeof(AudioSampleType);
        
        
        for (UInt32 i=0; i<numSamples; i++) {
            AudioSampleType sample = samples[i];
            
            [samplesArray addObject:@(sample)];
             
            if (fabs(sample) > peakSample) {
                peakSample = fabs(sample);
            }
            
            samplePos++;
        }
        
        filePacketPosition += (frameCount * self.audioFileClientFormat.mBytesPerPacket);
    }
    
    free(outputBuffer);
    self.peakSample = peakSample;
    
    
    // calculate/setup drawing variables
    UIBezierPath *waveformPath = [[UIBezierPath alloc] init];
    
    if (self.mode == TOWaveformDrawerModeRectangle) {
        self.base = self.imageSize.height/2.0;
        self.maxAmplitudeInPoints = self.base;
        self.distBetweenSamples = self.imageSize.width / (self.audioFileDuration * self.audioFileClientFormat.mSampleRate);
        
        [waveformPath moveToPoint:CGPointMake(0, self.base)];
    }
    else {
        self.outerRadius = MIN(self.imageSize.width, self.imageSize.height) / 2.0;
        self.base =  self.outerRadius - ((self.outerRadius - self.innerRadius) / 2.0);
        self.distBetweenSamples = (2 * M_PI) / (self.audioFileDuration * self.audioFileClientFormat.mSampleRate);
        self.center = CGPointMake(self.imageSize.width/2.0, self.imageSize.height/2.0);
        
        [waveformPath moveToPoint:CGPointMake(self.center.x, self.center.y - self.base)];
    }
    
    samplePos = 0;
    
    for (NSNumber *sample in samplesArray) {
        CGPoint p;
        
        if (self.mode == TOWaveformDrawerModeRectangle) {
            p = [self pointInRectWithSample:[sample doubleValue] atPosition:samplePos];
        }
        else {
            p = [self pointInCircletWithSample:[sample doubleValue] atPosition:samplePos];
        }
        
        [waveformPath addLineToPoint:p];
        samplePos++;
    }
    
    return waveformPath;
}


- (UIImage *)waveformFromImageAtURL:(NSURL *)url
{
    NSParameterAssert(url);
    
    [self setupExtAudioFileAtURL:url];
    
    
    // setup drawing context
    UIGraphicsBeginImageContextWithOptions(self.imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    
    UIBezierPath *path = [self waveFormPath];
    

    // draw the path
    CGContextSetLineWidth(context, .5);
    CGContextSetStrokeColorWithColor(context, self.waveformColor.CGColor);
    CGContextAddPath(context, path.CGPath);
    CGContextDrawPath(context, kCGPathStroke);
    
    
    // create the image
    UIImage *i = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return i;
}

@end
