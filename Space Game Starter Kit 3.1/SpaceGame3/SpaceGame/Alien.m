//
//  Alien.m
//  SpaceGame
//
//  Created by Main Account on 10/31/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

#import "Alien.h"
#import "MyScene.h"

@implementation Alien {
  NSTimeInterval _timeSinceLastLaserShot;
  NSTimeInterval _timeForNextLaserShot;
}

- (instancetype)init {
  if ((self = [super initWithImageNamed:@"enemy_spaceship" maxHp:1])) {
    [self setupCollisionBody];
    _timeForNextLaserShot = RandomFloatRange(0.1, 4);
    _timeSinceLastLaserShot = 0;
  }
  return self;
}

- (void)setupCollisionBody {
  CGPoint offset = CGPointMake(self.size.width * self.anchorPoint.x, self.size.height * self.anchorPoint.y);
  CGMutablePathRef path = CGPathCreateMutable();
  [self moveToPoint:CGPointMake(11, 25) path:path offset:offset];
  [self addLineToPoint:CGPointMake(42, 40) path:path offset:offset];
  [self addLineToPoint:CGPointMake(86, 40) path:path offset:offset];
  [self addLineToPoint:CGPointMake(114, 25) path:path offset:offset];
  [self addLineToPoint:CGPointMake(79, 11) path:path offset:offset];
  [self addLineToPoint:CGPointMake(44, 11) path:path offset:offset];
  CGPathCloseSubpath(path);

  self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
  [self attachDebugFrameFromPath:path color:[SKColor redColor]];

  self.physicsBody.categoryBitMask = EntityCategoryAlien;
  self.physicsBody.collisionBitMask = 0;
  self.physicsBody.contactTestBitMask = EntityCategoryPlayerLaser;
}

- (void)collidedWith:(SKPhysicsBody *)body contact:(SKPhysicsContact *)contact {

  Entity * other = (Entity *)body.node;
  if (body.categoryBitMask & EntityCategoryPlayerLaser) {
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

- (void)update:(CFTimeInterval)dt {

  [super update:dt];

  _timeSinceLastLaserShot += dt;
  if (_timeSinceLastLaserShot > _timeForNextLaserShot) {
    _timeSinceLastLaserShot = 0;
    _timeForNextLaserShot = RandomFloatRange(0.1, 4);
    MyScene *myScene = (MyScene *)self.scene;
    [myScene spawnAlienLaserAtPosition:self.position];
  }

}

@end
