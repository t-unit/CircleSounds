//
//  TOReplaceSegue.m
//  CircleSounds
//
//  Created by Tobias Ottenweller on 08.09.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOReplaceSegue.h"

@implementation TOReplaceSegue


- (void)perform
{
    UIViewController *sourceViewController = (UIViewController *)self.sourceViewController;
    UIViewController *destinationViewController = (UIViewController *)self.destinationViewController;
    
    UIViewController *parentViewController = sourceViewController.parentViewController;
    
    
    [sourceViewController removeFromParentViewController];
    [sourceViewController.view removeFromSuperview];
    
    [parentViewController addChildViewController:destinationViewController];
    [parentViewController.view addSubview:destinationViewController.view];

    destinationViewController.view.frame = parentViewController.view.frame;
}

@end
