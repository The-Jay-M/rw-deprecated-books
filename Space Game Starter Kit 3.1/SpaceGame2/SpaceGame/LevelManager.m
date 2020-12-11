//
//  LevelManager.m
//  SpaceGame
//
//  Created by Ray Wenderlich on 10/23/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

#import "LevelManager.h"

@implementation LevelManager

- (id)init {
  if ((self = [super init])) {
    _gameState = GameStateMainMenu;
    
  }
  return self;
}

@end
