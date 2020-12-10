//
//  GCTurnBasedMatchHelper.h
//  spinningyarn2
//
//  Created by Jake Gundersen on 12/5/13.
//  Copyright (c) 2013 jgundersen. All rights reserved.
//

#import <Foundation/Foundation.h>
@import GameKit;

@protocol GCTurnBasedMatchHelperDelegate
- (void)enterNewGame:(GKTurnBasedMatch *)match;
- (void)layoutMatch:(GKTurnBasedMatch *)match;
- (void)takeTurn:(GKTurnBasedMatch *)match;
- (void)recieveEndGame:(GKTurnBasedMatch *)match;
- (void)sendNotice:(NSString *)notice forMatch:(GKTurnBasedMatch *)match;
@end

@interface GCTurnBasedMatchHelper : NSObject <GKTurnBasedMatchmakerViewControllerDelegate, GKLocalPlayerListener> {
  BOOL userAuthenticated;
  UIViewController *presentingViewController;
}

@property (strong) GKTurnBasedMatch *currentMatch;

+ (GCTurnBasedMatchHelper *)sharedInstance;
- (void)authenticateLocalUserFromViewController:(UIViewController *)authenticationPresentingViewController;
- (void)findMatchWithMinPlayers:(int)minPlayers
                     maxPlayers:(int)maxPlayers
                 viewController:(UIViewController *)viewController;
@property (nonatomic, weak) id <GCTurnBasedMatchHelperDelegate> delegate;

@end
