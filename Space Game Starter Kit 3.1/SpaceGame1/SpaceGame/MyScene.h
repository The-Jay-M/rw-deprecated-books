//
//  MyScene.h
//  SpaceGame
//

//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class Player;

@interface MyScene : SKScene

@property (strong) Player * player;

- (void)playExplosionLargeSound;

@end
