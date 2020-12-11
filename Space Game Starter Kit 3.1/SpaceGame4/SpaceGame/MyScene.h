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
- (void)spawnExplosionAtPosition:(CGPoint)position scale:(float)scale large:(BOOL)large;
- (void)endScene:(BOOL)win;
- (void)spawnAlienLaserAtPosition:(CGPoint)position;
- (void)applyPowerup;
- (void)nextStage;
- (void)shootCannonBallAtPlayerFromPosition:(CGPoint)position;

@end
