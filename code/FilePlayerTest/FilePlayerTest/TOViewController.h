//
//  TOViewController.h
//  FilePlayerTest
//
//  Created by Tobias Ottenweller on 21.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TOAudioFilePlayer.h"


@interface TOViewController : UIViewController

@property (strong, nonatomic) TOAudioFilePlayer *audioFilePlayer;

@end
