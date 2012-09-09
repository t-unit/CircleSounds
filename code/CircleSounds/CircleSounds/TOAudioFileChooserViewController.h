//
//  TOAudioFileChooserViewController.h
//  CircleSounds
//
//  Created by Tobias Ottenweller on 08.09.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 Displays all availible sounds to the user to select a new
 one for the given equalized sound object.
 */
@interface TOAudioFileChooserViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
