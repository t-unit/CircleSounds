//
//  TOAudioFileManager.h
//  CircleSounds
//
//  Created by Tobias Ottenweller on 09.09.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TOAudioFileManager : NSObject

/**
 Returns the directory in which audio recordings
 will be saved. If the directory does not exist 
 this method will create it.
 */
+ (NSURL *)recordingsDirectory;


+ (NSArray *)allRecordingsURLs;
+ (NSArray *)allSuppliedSoundsURLs;

@end
