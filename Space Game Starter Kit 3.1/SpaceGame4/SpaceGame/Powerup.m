//
//  Powerup.m
//  SpaceGame
//
//  Created by Main Account on 11/4/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

#import "Powerup.h"

@implementation Powerup

- (instancetype)init {
  if ((self = [super initWithImageNamed:@"powerup" maxHp:1 healthBarType:HealthBarTypeNone])) {
    [self setupCollisionBody];
  }
  return self;
}

- (void)setupCollisionBody {
  CGPoint offset = CGPointMake(self.size.width * self.anchorPoint.x, self.size.height * self.anchorPoint.y);
  CGMutablePathRef path = CGPathCreateMutable();
  [self moveToPoint:CGPointMake(9, 30) path:path offset:offset];
  [self addLineToPoint:CGPointMake(54, 29) path:path offset:offset];
  [self addLineToPoint:CGPointMake(54, 8) path:path offset:offset];
  [self addLineToPoint:CGPointMake(8, 9) path:path offset:offset];
  CGPathCloseSubpath(path);

  self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
  [self attachDebugFrameFromPath:path color:[SKColor redColor]];

  self.physicsBody.categoryBitMask = EntityCategoryPowerup;
  self.physicsBody.collisionBitMask = 0;
  self.physicsBody.contactTestBitMask = EntityCategoryPlayer;
}

@end