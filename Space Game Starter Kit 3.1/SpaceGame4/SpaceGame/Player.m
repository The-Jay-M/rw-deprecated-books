//
//  Player.m
//  SpaceGame
//
//  Created by Ray Wenderlich on 10/23/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

#import "Player.h"
#import "MyScene.h"

@implementation Player

- (instancetype)init {
  if ((self = [super initWithImageNamed:@"SpaceFlier_sm_1" maxHp:10 healthBarType:HealthBarTypeGreen])) {
    [self setupAnimation];
    [self setupCollisionBody];
  }
  return self;
}

- (void)setupAnimation {
  NSArray * textures = @[
      [SKTexture textureWithImageNamed:@"SpaceFlier_sm_1"],
      [SKTexture textureWithImageNamed:@"SpaceFlier_sm_2"],
    ];
  SKAction *animation = [SKAction animateWithTextures:textures timePerFrame:0.2];
  [self runAction:[SKAction repeatActionForever:animation]];
}

- (void)setupCollisionBody {
  // 1
  CGPoint offset = CGPointMake(self.size.width * self.anchorPoint.x, self.size.height * self.anchorPoint.y);
  CGMutablePathRef path = CGPathCreateMutable();
  [self moveToPoint:CGPointMake(70, 51) path:path offset:offset];
  [self addLineToPoint:CGPointMake(83, 50) path:path offset:offset];
  [self addLineToPoint:CGPointMake(102, 32) path:path offset:offset];
  [self addLineToPoint:CGPointMake(95, 16) path:path offset:offset];
  [self addLineToPoint:CGPointMake(73, 9) path:path offset:offset];
  [self addLineToPoint:CGPointMake(45, 16) path:path offset:offset];
  [self addLineToPoint:CGPointMake(46, 36) path:path offset:offset];
  CGPathCloseSubpath(path);

  // 2
  self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
  [self attachDebugFrameFromPath:path color:[SKColor redColor]];

  // 3
  self.physicsBody.categoryBitMask = EntityCategoryPlayer;
  self.physicsBody.collisionBitMask = 0;
  self.physicsBody.contactTestBitMask = EntityCategoryAsteroid | EntityCategoryAlienLaser | EntityCategoryPowerup | EntityCategoryAlien;
}

- (void)collidedWith:(SKPhysicsBody *)body contact:(SKPhysicsContact *)contact {

  // 1
  Entity * other = (Entity *)body.node;
  [other destroy];

  // 2
  if (body.categoryBitMask & EntityCategoryAsteroid || body.categoryBitMask & EntityCategoryAlienLaser || body.categoryBitMask & EntityCategoryAlien) {
    [self contactWithObstacle:contact];
  } else if (body.categoryBitMask & EntityCategoryPowerup) {
    MyScene *scene = (MyScene *)self.scene;
    [scene applyPowerup];
  }
  
}

- (void)contactWithObstacle:(SKPhysicsContact *)contact {

  MyScene *scene = (MyScene *)self.scene;
  
  // 3
  if (!self.invincible) {
    [self takeHit];
  }
  
  if ([self isDead]) {
    [scene spawnExplosionAtPosition:contact.contactPoint scale:1.0 large:YES];
    [scene endScene:NO];
  } else {
    [scene spawnExplosionAtPosition:contact.contactPoint scale:0.5 large:YES];
  }
}

@end
