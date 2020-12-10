//
//  GCCustomGUI.m
//  spinningyarn2
//
//  Created by Jake Gundersen on 12/7/13.
//  Copyright (c) 2013 jgundersen. All rights reserved.
//

#import "GCCustomGUI.h"
@import GameKit;
#import "MatchCell.h"
#import "PlayersTableViewController.h"

@interface GCCustomGUI () <MatchCellDelegate> {
  NSArray *allMyMatches;
}

@end

@implementation GCCustomGUI

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

  //1
  self.tableView.rowHeight = 220;
  
  //2
  self.tableView.editing = NO;
  
  //3
  UIBarButtonItem *plus = [[UIBarButtonItem alloc]
                           initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                           target:self action:@selector(addNewMatch)];
  self.navigationItem.rightBarButtonItem = plus;
  
  //4
  UIBarButtonItem *cancel = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                             target:self action:@selector(cancel)];
  self.navigationItem.leftBarButtonItem = cancel;
  
  [self reloadTableView];
}

-(void)reloadTableView {
  // 1
  [GKTurnBasedMatch loadMatchesWithCompletionHandler:
   ^(NSArray *matches, NSError *error) {
     // 2
     if (error) {
       NSLog(@"%@", error.localizedDescription);
     } else {
       // 3
       NSMutableArray *myMatches = [NSMutableArray array];
       NSMutableArray *otherMatches = [NSMutableArray array];
       NSMutableArray *endedMatches = [NSMutableArray array];
       // 4
       for (GKTurnBasedMatch *m in matches) {
         GKTurnBasedMatchOutcome myOutcome;
         for (GKTurnBasedParticipant *par in
              m.participants) {
           if ([par.playerID isEqualToString:
                [GKLocalPlayer localPlayer].playerID]) {
             myOutcome = par.matchOutcome;
           }
         }
         // 5
         if (m.status != GKTurnBasedMatchStatusEnded &&
             myOutcome != GKTurnBasedMatchOutcomeQuit) {
           if ([m.currentParticipant.playerID
                isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
             [myMatches addObject:m];
           } else {
             [otherMatches addObject:m];
           }
         } else {
           [endedMatches addObject:m];
         }
       }
       // 6
       allMyMatches = [[NSArray alloc]
                       initWithObjects:myMatches,
                       otherMatches,endedMatches, nil];
       NSLog(@"Matches: %@", allMyMatches);
       [self.tableView reloadData];
     }
   }];
}

-(void)cancel {
  [self.parentViewController dismissViewControllerAnimated:YES
                                                completion:nil];
}

-(void)addNewMatch {
  GKMatchRequest *request = [[GKMatchRequest alloc] init];
  
  request.maxPlayers = 12;
  request.minPlayers = 2;
  
  [GKTurnBasedMatch findMatchForRequest:request
                  withCompletionHandler:^(GKTurnBasedMatch *match,
                                          NSError *error) {
                    if (error) {
                      NSLog(@"%@", error.localizedDescription );
                    } else {
                      NSLog(@"match found!");
                      [self.vc dismissViewControllerAnimated:YES completion:nil];
                      [[GCTurnBasedMatchHelper sharedInstance]
                          turnBasedMatchmakerViewController:nil didFindMatch:match];

                    }
                  }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:
(UITableView *)tableView
{
  return 3;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    return @"My Turn";
  } else if (section == 1) {
    return @"Their Turn";
  } else {
    return @"Game Ended";
  }
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
  return [[allMyMatches objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  //1
  MatchCell *cell = (MatchCell *)[tableView
                                  dequeueReusableCellWithIdentifier:@"MatchCell"];
  //2
  GKTurnBasedMatch *match = [[allMyMatches
                              objectAtIndex:indexPath.section]
                             objectAtIndex:indexPath.row];
  cell.match = match;
  cell.delegate = self;
  //3
  if ([match.matchData length] > 0) {
    //4
    NSString *storyString = [NSString
                             stringWithUTF8String:[match.matchData bytes]];
    cell.storyText.text = storyString;
    //5
    int days = -floor([match.creationDate
                       timeIntervalSinceNow] / (60 * 60 * 24));
    cell.statusLabel.text = [NSString
                             stringWithFormat:@"Story started %d days ago and is about %d words",days, [storyString length] / 5];
  }

  if (indexPath.section == 2) {
    [cell.quitButton setTitle:@"Remove"
                     forState:UIControlStateNormal];
  } else {
    [cell.quitButton setTitle:@"Quit Game"
                     forState:UIControlStateNormal];
  }

  return cell;
}

-(void)loadAMatch:(GKTurnBasedMatch *)match {
  [self.vc dismissViewControllerAnimated:YES completion:nil];
  [[GCTurnBasedMatchHelper sharedInstance]
   turnBasedMatchmakerViewController:nil didFindMatch:match];
}

- (BOOL)isVisible {
  return [self isViewLoaded] && self.view.window;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:@"toPlayerTable"]) {
    //1
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    //2
    PlayersTableViewController *playersTableViewController = (PlayersTableViewController *)segue.destinationViewController;
    playersTableViewController.match = [[allMyMatches objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
  }
}

@end
