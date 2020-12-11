//
//  Asteroid.m
//  SpaceGame
//
//  Created by Ray Wenderlich on 10/23/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

#import "Asteroid.h"
#import "MyScene.h"

@implementation Asteroid

- (instancetype)initWithAsteroidType:(AsteroidType)asteroidType {
  int maxHp;
  float scale;
  switch (asteroidType) {
  case AsteroidTypeSmall:
    maxHp = 1;
    scale = 0.25;
    break;
  case AsteroidTypeMedium:
    maxHp = 2;
    scale = 0.5;
    break;
  case AsteroidTypeLarge:
    maxHp = 4;
    scale = 1.0;
    break;
  default:
    return nil;
  }
  if ((self = [super initWithImageNamed:@"asteroid" maxHp:maxHp])) {
    self.asteroidType = asteroidType;
    [self setupCollisionBody];
    [self setScale:scale];
  }
  return self;
  
}

- (void)setupCollisionBody {
  CGPoint offset = CGPointMake(self.size.width * self.anchorPoint.x, self.size.height * self.anchorPoint.y);
  CGMutablePathRef path = CGPathCreateMutable();
  [self moveToPoint:CGPointMake(30, 105) path:path offset:offset];
  [self addLineToPoint:CGPointMake(47, 119) path:path offset:offset];
  [self addLineToPoint:CGPointMake(78, 123) path:path offset:offset];
  [self addLineToPoint:CGPointMake(105, 112) path:path offset:offset];
  [self addLineToPoint:CGPointMake(123, 83) path:path offset:offset];
  [self addLineToPoint:CGPointMake(119, 47) path:path offset:offset];
  [self addLineToPoint:CGPointMake(99, 24) path:path offset:offset];
  [self addLineToPoint:CGPointMake(46, 22) path:path offset:offset];
  [self addLineToPoint:CGPointMake(25, 45) path:path offset:offset];
  [self addLineToPoint:CGPointMake(16, 79) path:path offset:offset];
  CGPathCloseSubpath(path);

  self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
  [self attachDebugFrameFromPath:path color:[SKColor redColor]];

  self.physicsBody.categoryBitMask = EntityCategoryAsteroid;
  self.physicsBody.collisionBitMask = 0;
  self.physicsBody.contactTestBitMask = EntityCategoryPlayerLaser | EntityCategoryPlayer;
}

//- (void)collidedWith:(SKPhysicsBody *)body contact:(SKPhysicsContact *)contact {
//  if (body.categoryBitMask & EntityCategoryPlayerLaser) {
//    Entity * other = (Entity *)body.node;
//    MyScene *scene = (MyScene *)self.scene;
//    [scene playExplosionLargeSound];
//    [other removeFromParent];
//    [self removeFromParent];
//  }
//}

- (void)collidedWith:(SKPhysicsBody *)body contact:(SKPhysicsContact *)contact {
  
  if (body.categoryBitMask & EntityCategoryPlayerLaser) {
    Entity * other = (Entity *)body.node;
    [other destroy];
    [self takeHit];
    MyScene *scene = (MyScene *)self.scene;
    if ([self isDead]) {
      [scene spawnExplosionAtPosition:contact.contactPoint scale:self.xScale large:YES];
    } else {
      [scene spawnExplosionAtPosition:contact.contactPoint scale:self.xScale large:NO];
    }
  }
}

@end
