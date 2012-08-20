//
//  TOViewController.m
//  SubGraphTest
//
//  Created by Tobias Ottenweller on 20.08.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "TOViewController.h"

@interface TOViewController ()

@end


@implementation TOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.subgraph = [[TOSubgraph alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
