//
//  MatchCell.m
//  spinningyarn
//
//  Created by Jake Gundersen on 10/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MatchCell.h"


@implementation MatchCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)loadGame:(id)sender {
    [self.delegate loadAMatch:self.match];
}

- (IBAction)quitGame:(id)sender {
  UIButton *send = (UIButton *)sender;
  if ([send.titleLabel.text isEqualToString:@"Remove"]) {
    NSLog(@"remove, %@", send.titleLabel.text);
    [self.match removeWithCompletionHandler:^(NSError *error) {
      [self.delegate reloadTableView];
    }];
  } else {
    
    if ([self.match.currentParticipant.playerID
         isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
      //1
      [[GCTurnBasedMatchHelper sharedInstance]
       turnBasedMatchmakerViewController:nil
       playerQuitForMatch:self.match];
    } else {
      //2
      [self.match
       participantQuitOutOfTurnWithOutcome:
       GKTurnBasedMatchOutcomeQuit
       withCompletionHandler:^(NSError *error) {
         if (error) {
           NSLog(@"%@", error.localizedDescription);
         }
       }];
    }
  }
  //3
  [self.delegate reloadTableView];
}

- (IBAction)remind:(id)sender {
  if ([[GKLocalPlayer localPlayer].playerID isEqualToString:self.match.currentParticipant.playerID]) return;
  [self.match sendReminderToParticipants:@[self.match.currentParticipant] localizableMessageKey:@"Wake Up!" arguments:nil completionHandler:^(NSError *error) {
    if (error) {
      NSLog(@"Error with reminder %@", error);
    }
  }];
}



@end
