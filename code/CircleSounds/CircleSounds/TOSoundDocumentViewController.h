//
//  TOSoundDocumentViewController.h
//  CircleSounds
//
//  Created by Tobias Ottenweller on 29.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TOSoundDocument;


@interface TOSoundDocumentViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *canvas;

@property (strong, nonatomic) TOSoundDocument *soundDocument;
@property (strong, nonatomic) NSArray *soundControllers;

@end
