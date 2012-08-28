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


#define NORMALIZED_MAX 4000.0

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
@property (assign, nonatomic) CGFloat maxAmplitude; /* only used in rectangle mode */
@property (assign, nonatomic) CGFloat outerRadius; /* only used in circle mode */
@property (assign, nonatomic) CGPoint center; /* Center of the circle. Only used in circle mode */

@end


@implementation TOWaveformDrawer

- (void)dealloc
{
    if (self.extAudioFile) {
        TOThrowOnError(ExtAudioFileDispose(self.extAudioFile));
    }
}


- (void)setupExtAudioFile
{
    if (self.extAudioFile) {
        TOThrowOnError(ExtAudioFileDispose(self.extAudioFile));
    }
    
    
    // open the file
    ExtAudioFileRef extFile;
    TOThrowOnError(ExtAudioFileOpenURL((__bridge CFURLRef)(self.url), &extFile));
    self.extAudioFile = extFile;
    
    
    // set the client stream format
    AudioStreamBasicDescription clientFormat = TOCanonicalStreamFormat(1, true);
    clientFormat.mSampleRate = 500;
    TOThrowOnError(ExtAudioFileSetProperty(extFile,
                                           kExtAudioFileProperty_ClientDataFormat,
                                           sizeof(clientFormat),
                                           &clientFormat));
    
    self.audioFileClientFormat = clientFormat;
    
    
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
}


- (CGPoint)pointInRectWithSample:(AudioSampleType)sample atPosition:(UInt64)samplePostion
{    
    CGFloat x = samplePostion * self.distBetweenSamples;
    CGFloat y = self.base + (sample / NORMALIZED_MAX * self.maxAmplitude);
    
    return CGPointMake(x, y);
}


- (CGPoint)pointInCircletWithSample:(AudioSampleType)sample atPosition:(UInt64)samplePostion
{
    CGFloat angle = M_PI - (samplePostion * self.distBetweenSamples);
    CGFloat amplitude = 1/NORMALIZED_MAX * sample;
    
    CGPoint basePoint = CGPointMake(sinf(angle) * self.base, cosf(angle) * self.base);
    CGPoint maxPosAmplitudePoint = CGPointMake(sinf(angle) * self.outerRadius, cosf(angle) * self.outerRadius);
    CGPoint vecBaseMax = CGPointMake(maxPosAmplitudePoint.x - basePoint.x, maxPosAmplitudePoint.y - basePoint.y);
    
    
    CGFloat x = self.center.x  + basePoint.x + (vecBaseMax.x * amplitude);
    CGFloat y = self.center.y + basePoint.y + (vecBaseMax.y * amplitude);

    
    return CGPointMake(x, y);
}


- (void)setUrl:(NSURL *)url
{
     NSParameterAssert(url); // make sure 'url' is not nil.
    
    _url = url;
    [self setupExtAudioFile];
}


- (UIBezierPath *)waveFormPath
{
    // calculate/setup drawing variables
    UIBezierPath *waveformPath = [[UIBezierPath alloc] init];
    
    if (self.mode == TOWaveformDrawerModeRectangle) {
        self.base = self.imageSize.height/2.0;
        self.maxAmplitude = self.base;
        self.distBetweenSamples = self.imageSize.width / (self.audioFileDuration * self.audioFileClientFormat.mSampleRate);
        
        [waveformPath moveToPoint:CGPointMake(0, self.base)];
    }
    else {
        self.outerRadius = MIN(self.imageSize.width, self.imageSize.height) / 2.0;
        self.base =  self.outerRadius - (self.innerRadius / 2.0);
        self.distBetweenSamples = (2 * M_PI) / (self.audioFileDuration * self.audioFileClientFormat.mSampleRate);
        self.center = CGPointMake(self.imageSize.width/2.0, self.imageSize.height/2.0);
        
        [waveformPath moveToPoint:CGPointMake(self.center.x, self.center.y - self.base)];
    }
    
    
    // prepare audio file reading
    UInt32 outputBuferSize = 32 * 1024; // 32 KB
    UInt32 sizePerPacket = self.audioFileClientFormat.mBytesPerPacket;
    UInt32 packetsPerBuffer = outputBuferSize / sizePerPacket;
    
    void *outputBuffer = malloc(sizeof(UInt8) * outputBuferSize);
    UInt32 filePacketPosition = 0; // In bytes
    UInt64 samplePos = 0;
    
    
    // read from the audio file
    while (1) {
        AudioBufferList convertedData;
        convertedData.mNumberBuffers = 1;
        convertedData.mBuffers[0].mNumberChannels = self.audioFileClientFormat.mChannelsPerFrame;
        convertedData.mBuffers[0].mDataByteSize = outputBuferSize;
        convertedData.mBuffers[0].mData = outputBuffer;
        
        UInt32 frameCount = packetsPerBuffer;
        TOThrowOnError(ExtAudioFileRead(self.extAudioFile,
                                        &frameCount,
                                        &convertedData));
        
        if (frameCount == 0) {
            break; // finished reading file
        }
        
        
        AudioSampleType *samples = convertedData.mBuffers[0].mData;
        UInt32 numSamples = convertedData.mBuffers[0].mDataByteSize / sizeof(AudioSampleType);
        
        for (UInt32 i=0; i<numSamples; i++) {
            AudioSampleType sample = samples[i];
            CGPoint p;
            
            if (self.mode == TOWaveformDrawerModeRectangle) {
                p = [self pointInRectWithSample:sample atPosition:samplePos];
            }
            else {
                p = [self pointInCircletWithSample:sample atPosition:samplePos];
            }
            
            [waveformPath addLineToPoint:p];
            samplePos++;
        }
        
        filePacketPosition += (frameCount * self.audioFileClientFormat.mBytesPerPacket);
    }
    
    free(outputBuffer);
    
    return waveformPath;
}


- (UIImage *)waveformImage
{
    if (!self.url) {
        return nil;
    }
    
    [self setupExtAudioFile];
    
    
    // setup drawing context
    UIGraphicsBeginImageContextWithOptions(self.imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    
    UIBezierPath *path = [self waveFormPath];
    

    // draw the path
    CGContextSetLineWidth(context, 0.1);
    CGContextSetStrokeColorWithColor(context, self.waveformColor.CGColor);
    CGContextAddPath(context, path.CGPath);
    CGContextDrawPath(context, kCGPathStroke);
    
    
    // create the image
    UIImage *i = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return i;
}

@end
