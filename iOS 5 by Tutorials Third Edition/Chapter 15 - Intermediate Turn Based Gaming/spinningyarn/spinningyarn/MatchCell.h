//
//  MatchCell.h
//  spinningyarn
//
//  Created by Jake Gundersen on 10/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GameKit;
#import "GCTurnBasedMatchHelper.h"

@protocol MatchCellDelegate
-(void)loadAMatch:(GKTurnBasedMatch *)match;
-(void)reloadTableView;
@end

@interface MatchCell : UITableViewCell 

@property (nonatomic, strong) GKTurnBasedMatch *match;

@property (strong, nonatomic) IBOutlet UIButton *quitButton;
@property (strong, nonatomic) IBOutlet UITextView *storyText;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) id <MatchCellDelegate> delegate;

- (IBAction)loadGame:(id)sender;
- (IBAction)quitGame:(id)sender;


@end
