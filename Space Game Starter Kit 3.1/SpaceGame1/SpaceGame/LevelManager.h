//
//  LevelManager.h
//  SpaceGame
//
//  Created by Ray Wenderlich on 10/23/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

typedef NS_ENUM(NSInteger, GameState)
{
  GameStateMainMenu = 0,
  GameStatePlay,
  GameStateDone,
  GameStateGameOver
};

@interface LevelManager : NSObject

@property (assign) GameState gameState;

@end
