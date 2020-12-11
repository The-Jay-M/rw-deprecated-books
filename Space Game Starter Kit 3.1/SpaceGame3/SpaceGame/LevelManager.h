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

@property (nonatomic, assign) GameState gameState;

- (NSInteger)curLevelIdx;
- (void)nextStage;
- (void)nextLevel;
- (BOOL)update;
- (float)floatForProp:(NSString *)prop;
- (NSString *)stringForProp:(NSString *)prop;
- (BOOL)boolForProp:(NSString *)prop;
- (BOOL)hasProp:(NSString *)prop;

@end
