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
    
    
    // get rid of the old view controller
    [sourceViewController removeFromParentViewController];
    [sourceViewController.view removeFromSuperview];
    [sourceViewController viewDidDisappear:YES];
    
    
    // add the new view controller
    [parentViewController addChildViewController:destinationViewController];
    [parentViewController.view addSubview:destinationViewController.view];

    destinationViewController.view.frame = parentViewController.view.frame;
    [destinationViewController viewDidAppear:YES];
}

@end
