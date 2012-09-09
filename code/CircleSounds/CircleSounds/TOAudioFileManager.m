//
//  TOAudioFileManager.m
//  CircleSounds
//
//  Created by Tobias Ottenweller on 09.09.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOAudioFileManager.h"

@implementation TOAudioFileManager

+ (NSURL *)recordingsDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *documentDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *recodingDirectory = [documentDirectory URLByAppendingPathComponent:@"Recordings" isDirectory:YES];
    
    if (![fileManager fileExistsAtPath:recodingDirectory.path]) {
        
        NSError *error;
        BOOL success = [fileManager createDirectoryAtURL:recodingDirectory
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:&error];
        
#if DEBUG
        if (error || !success) {
            NSLog(@"creating recording directory failed! (%@)", error);
        }
#endif
    }
    
    return recodingDirectory;
}


+ (NSArray *)allRecordingsURLs
{
    NSError *error;
    
    NSArray *recordings = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:self.recordingsDirectory
                                                        includingPropertiesForKeys:@[]
                                                                           options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                             error:&error];
    
    if (!recordings || error) {
#if DEBUG
        NSLog(@"looking for recodings failed! (%@)", error);
#endif
        
        return @[]; // no recordings are availible
    }
    else {
        return recordings;
    }
}


+ (NSArray *)allSuppliedSoundsURLs
{
    NSArray *suppliedSounds = @[[[NSBundle mainBundle] URLForResource:@"clong-1" withExtension:@"wav"],
                                [[NSBundle mainBundle] URLForResource:@"clong-2" withExtension:@"wav"],
                                [[NSBundle mainBundle] URLForResource:@"electric-drill-2" withExtension:@"wav"],
                                [[NSBundle mainBundle] URLForResource:@"freezer-hum-1" withExtension:@"wav"],
                                [[NSBundle mainBundle] URLForResource:@"grass-trimmer-1" withExtension:@"wav"],
                                [[NSBundle mainBundle] URLForResource:@"hammering-1" withExtension:@"wav"],
                                [[NSBundle mainBundle] URLForResource:@"08 Hope You're Feeling Better" withExtension:@"m4a"]];
    
    
    return suppliedSounds;
}

@end
