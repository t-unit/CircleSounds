//
//  TOMocFilePlayerSound.h
//  CircleSounds
//
//  Created by Tobias Ottenweller on 26.10.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOFilePlayerSound.h"

@interface TOMocFilePlayerSound : TOFilePlayerSound

@property (strong, nonatomic) TOAudioUnit *filePlayerUnit;
@property (assign, nonatomic) AudioFileID audioFile;

@end
