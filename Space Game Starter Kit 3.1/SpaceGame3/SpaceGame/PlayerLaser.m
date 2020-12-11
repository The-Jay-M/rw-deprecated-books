//
//  PlayerLaser.m
//  SpaceGame
//
//  Created by Ray Wenderlich on 10/23/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

#import "PlayerLaser.h"

@implementation PlayerLaser

- (instancetype)init {
  if ((self = [super initWithImageNamed:@"laserbeam_blue" maxHp:1])) {
    [self setupCollisionBody];
  }
  return self;
}

- (void)setupCollisionBody {
  CGPoint offset = CGPointMake(self.size.width * self.anchorPoint.x, self.size.height * self.anchorPoint.y);
  CGMutablePathRef path = CGPathCreateMutable();
  [self moveToPoint:CGPointMake(7, 12) path:path offset:offset];
  [self addLineToPoint:CGPointMake(53, 11) path:path offset:offset];
  [self addLineToPoint:CGPointMake(53, 5) path:path offset:offset];
  [self addLineToPoint:CGPointMake(7, 6) path:path offset:offset];
  CGPathCloseSubpath(path);

  self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
  [self attachDebugFrameFromPath:path color:[SKColor redColor]];

  self.physicsBody.categoryBitMask = EntityCategoryPlayerLaser;
  self.physicsBody.collisionBitMask = 0;
  self.physicsBody.contactTestBitMask = EntityCategoryAsteroid | EntityCategoryAlien;
}

@end
