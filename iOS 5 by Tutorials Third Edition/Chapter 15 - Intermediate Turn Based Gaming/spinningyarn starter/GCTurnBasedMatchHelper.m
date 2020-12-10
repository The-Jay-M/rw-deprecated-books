//
//  GCTurnBasedMatchHelper.m
//  spinningyarn2
//
//  Created by Jake Gundersen on 12/5/13.
//  Copyright (c) 2013 jgundersen. All rights reserved.
//

#import "GCTurnBasedMatchHelper.h"

@implementation GCTurnBasedMatchHelper

#pragma mark Initialization

+ (GCTurnBasedMatchHelper *) sharedInstance {
  static GCTurnBasedMatchHelper *sharedHelper;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedHelper = [[GCTurnBasedMatchHelper alloc] init];
  });
  
  return sharedHelper;
}

- (void)authenticateLocalUserFromViewController:(UIViewController *)authenticationPresentingViewController
{
  presentingViewController = authenticationPresentingViewController;
  NSLog(@"Authenticating local user . . .");
  GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
  
  __weak GKLocalPlayer *weakLocalPlayer = localPlayer;
  localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error)
  {
    if (viewController) {
      [presentingViewController presentViewController:viewController animated:YES completion:^{
        userAuthenticated = YES;
        [[GKLocalPlayer localPlayer] unregisterAllListeners];
        [[GKLocalPlayer localPlayer] registerListener:self];
      }];
    } else if (weakLocalPlayer.authenticated) {
      userAuthenticated = YES;
      [[GKLocalPlayer localPlayer] unregisterAllListeners];
      [[GKLocalPlayer localPlayer] registerListener:self];
    } else {
      userAuthenticated = NO;
      NSLog(@"Error with Game Center %@", error);
    }
  };
}

- (void)findMatchWithMinPlayers:(int)minPlayers
                     maxPlayers:(int)maxPlayers
                 viewController: (UIViewController *)viewController {
  
  presentingViewController = viewController;
  
  GKMatchRequest *request = [[GKMatchRequest alloc] init];
  request.minPlayers = minPlayers;
  request.maxPlayers = maxPlayers;
  GKTurnBasedMatchmakerViewController *mmvc =
  [[GKTurnBasedMatchmakerViewController alloc]
   initWithMatchRequest:request];
  mmvc.turnBasedMatchmakerDelegate = self;
  mmvc.showExistingMatches = YES;
  
  [presentingViewController presentViewController:mmvc
                                         animated:YES completion:nil];
}

- (void)turnBasedMatchmakerViewController:
(GKTurnBasedMatchmakerViewController *)viewController
                             didFindMatch:(GKTurnBasedMatch *)match {
  
  [presentingViewController dismissViewControllerAnimated:YES
                                               completion:nil];
  //1
  NSMutableArray *stillPlaying = [NSMutableArray array];
  for (GKTurnBasedParticipant *p in match.participants) {
    if (p.matchOutcome == GKTurnBasedMatchOutcomeNone) {
      [stillPlaying addObject:p];
    }
  }
  //2
  if ([stillPlaying count] < 2 && [match.participants count] >= 2) {
    //There's only one player left
    //3
    for (GKTurnBasedParticipant *part in stillPlaying) {
      part.matchOutcome = GKTurnBasedMatchOutcomeTied;
    }
    //4
    [match endMatchInTurnWithMatchData:match.matchData completionHandler:^(NSError *error) {
      if (error) {
        NSLog(@"Error Ending Match %@", error);
      }
      //5
      [self.delegate layoutMatch:match];
    }];
    return;
  }
  
  self.currentMatch = match;
  
  GKTurnBasedParticipant *firstParticipant =
  [match.participants objectAtIndex:0];
  if (firstParticipant.lastTurnDate) {
    if ([match.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
      [self.delegate takeTurn:match];
    } else {
      [self.delegate layoutMatch:match];
    }
  } else {
    [self.delegate enterNewGame:match];
  }
}

- (void)turnBasedMatchmakerViewControllerWasCancelled:
(GKTurnBasedMatchmakerViewController *)viewController {
  [presentingViewController dismissViewControllerAnimated:YES
                                               completion:nil];
  NSLog(@"has cancelled");
}

- (void)turnBasedMatchmakerViewController:
(GKTurnBasedMatchmakerViewController *)viewController
                         didFailWithError:(NSError *)error {
  [presentingViewController dismissViewControllerAnimated:YES
                                               completion:nil];
  NSLog(@"Error finding match: %@",
        error.localizedDescription);
}

- (void)turnBasedMatchmakerViewController:
(GKTurnBasedMatchmakerViewController *)viewController
                       playerQuitForMatch:(GKTurnBasedMatch *)match {
  NSUInteger currentIndex = [match.participants
                             indexOfObject:match.currentParticipant];
  GKTurnBasedParticipant *part;
  
  NSMutableArray *nextParticipants = [NSMutableArray array];
  for (NSInteger i = 0; i < [match.participants count]; i++) {
    part = [match.participants objectAtIndex:
            (currentIndex + 1 + i) % match.participants.count];
    if (part.matchOutcome == GKTurnBasedMatchOutcomeNone) {
      [nextParticipants addObject:part];
    }
  }
  
  [match loadMatchDataWithCompletionHandler:^(NSData *matchData, NSError *error) {
    [match participantQuitInTurnWithOutcome:
     GKTurnBasedMatchOutcomeQuit
                           nextParticipants:nextParticipants turnTimeout:600
                                  matchData:matchData completionHandler:nil];
  }];
  
  NSLog(@"playerquitforMatch, %@, %@", match,
        match.currentParticipant);
}

#pragma mark GKTurnBasedEventListener methods

- (void)player:(GKPlayer *)player receivedTurnEventForMatch:(GKTurnBasedMatch *)match didBecomeActive:(BOOL)didBecomeActive
{
  NSLog(@"received turn event for match");
  if ([match.matchID
       isEqualToString:self.currentMatch.matchID]) {
    if ([match.currentParticipant.playerID
         isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
      // it's the current match and it's our turn now
      self.currentMatch = match;
      [self.delegate takeTurn:match];
    } else {
      // it's the current match, but it's someone else's turn
      self.currentMatch = match;
      [self.delegate layoutMatch:match];
    }
  } else {
    NSLog(@"PID %@", [GKLocalPlayer localPlayer].playerID);
    if ([match.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
      // it's not the current match and it's our turn now
      [self.delegate sendNotice:
       @"It's your turn for another match" forMatch:match];
    } else {
      // it's the not current match, and it's someone else's
      // turn
    }
  }
}

- (void)player:(GKPlayer *)player matchEnded:(GKTurnBasedMatch *)match
{
  NSLog(@"Game has ended");
  if ([match.matchID isEqualToString:self.currentMatch.matchID]) {
    [self.delegate recieveEndGame:match];
  } else {
    [self.delegate sendNotice:@"Another Game Ended!" forMatch:match];
  }
}

- (void)player:(GKPlayer *)player didRequestMatchWithPlayers:(NSArray *)playerIDsToInvite
{
  [presentingViewController dismissViewControllerAnimated:YES
                                               completion:nil];
  GKMatchRequest *request = [[GKMatchRequest alloc] init];
  
  request.playersToInvite = playerIDsToInvite;
  request.maxPlayers = 12;
  request.minPlayers = 2;
  
  GKTurnBasedMatchmakerViewController *viewController =
  [[GKTurnBasedMatchmakerViewController alloc]
   initWithMatchRequest:request];
  
  viewController.showExistingMatches = NO;
  viewController.turnBasedMatchmakerDelegate = self;
  [presentingViewController
   presentViewController:viewController animated:YES
   completion:nil];
}




@end
