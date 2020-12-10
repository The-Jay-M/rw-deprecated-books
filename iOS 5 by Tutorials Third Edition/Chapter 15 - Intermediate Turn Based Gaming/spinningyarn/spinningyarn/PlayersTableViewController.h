//
//  PlayersTableViewController.h
//  spinningyarn2
//
//  Created by Jake Gundersen on 12/13/13.
//  Copyright (c) 2013 jgundersen. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GameKit;

@interface PlayersTableViewController : UITableViewController
@property (nonatomic, strong) GKTurnBasedMatch *match;
@end
