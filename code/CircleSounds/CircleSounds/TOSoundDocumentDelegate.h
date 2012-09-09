//
//  TOSoundDocumentDelegate.h
//  CircleSounds
//
//  Created by Tobias Ottenweller on 09.09.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TOSoundDocument;
@class TOPlugableSound;


@protocol TOSoundDocumentDelegate <NSObject>

@optional

- (void)soundDocumentDidStartPlayback:(TOSoundDocument *)sender;
- (void)soundDocumentDidPausePlayback:(TOSoundDocument *)sender;
- (void)soundDocumentGotReset:(TOSoundDocument *)sender;


- (void)soundDocument:(TOSoundDocument *)sender didAddNewSound:(TOPlugableSound *)sound;
- (void)soundDocument:(TOSoundDocument *)sender didRemoveSound:(TOPlugableSound *)sound;

@end
