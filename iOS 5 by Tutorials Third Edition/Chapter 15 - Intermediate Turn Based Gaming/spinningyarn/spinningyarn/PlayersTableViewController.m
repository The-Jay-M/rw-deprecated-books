//
//  PlayersTableViewController.m
//  spinningyarn2
//
//  Created by Jake Gundersen on 12/13/13.
//  Copyright (c) 2013 jgundersen. All rights reserved.
//

#import "PlayersTableViewController.h"
;
@interface PlayersTableViewController () <UIAlertViewDelegate>
@property (nonatomic, strong) NSMutableArray *players;
@property (nonatomic, strong) GKLocalPlayer *selectedPlayer;
@end

@implementation PlayersTableViewController

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
    self.players = [NSMutableArray array];
    //2
    NSMutableArray *playerIDs = [NSMutableArray array];
    for (GKTurnBasedParticipant *participant in self.match.participants) {
        //3
        if (![[GKLocalPlayer localPlayer].playerID isEqualToString:participant.playerID]) {
            //4
            if (participant.playerID) {
                [playerIDs addObject:participant.playerID];
            }
        }
    }
    //5
    __weak typeof(self) weakself = self;
    [GKLocalPlayer loadPlayersForIdentifiers:playerIDs withCompletionHandler:^(NSArray *players, NSError *error) {
        //6
        [weakself.players removeAllObjects];
        [weakself.players addObjectsFromArray:players];
        //7
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.tableView reloadData];
        });
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.players count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    GKPlayer *player = [self.players objectAtIndex:indexPath.row];
    cell.textLabel.text = player.displayName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  self.selectedPlayer = [self.players objectAtIndex:indexPath.row];
  UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Send Taunt" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send Taunt", nil];
  [av setAlertViewStyle:UIAlertViewStylePlainTextInput];
  [av show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  //1
  if (buttonIndex == 1) {
    //2
    NSString *text = [[alertView textFieldAtIndex:0] text];
    NSData *textData = [text dataUsingEncoding:NSUTF8StringEncoding];
    //3
    for (GKTurnBasedParticipant *partipant in self.match.participants) {
      if ([partipant.playerID isEqualToString:self.selectedPlayer.playerID]) {
        //4
        [self.match sendExchangeToParticipants:@[partipant] data:textData localizableMessageKey:@"Would you accept an Exchange!" arguments:nil timeout:600 completionHandler:^(GKTurnBasedExchange *exchange, NSError *error) {
          //finished
          if (error) {
            NSLog(@"Error %@", error);
          }
        }];
      }
    }
  }
}

@end
