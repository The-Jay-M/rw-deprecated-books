//
//  CannonBall.m
//  SpaceGame
//
//  Created by Main Account on 11/4/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

#import "CannonBall.h"

@implementation CannonBall

- (instancetype)init {
  if ((self = [super initWithImageNamed:@"Boss_cannon_ball" maxHp:1 healthBarType:HealthBarTypeNone])) {
    [self setupCollisionBody];
  }
  return self;
}

- (void)setupCollisionBody {
  CGPoint offset = CGPointMake(self.size.width * self.anchorPoint.x, self.size.height * self.anchorPoint.y);
  CGMutablePathRef path = CGPathCreateMutable();
  [self moveToPoint:CGPointMake(9, 18) path:path offset:offset];
  [self addLineToPoint:CGPointMake(12, 24) path:path offset:offset];
  [self addLineToPoint:CGPointMake(19, 25) path:path offset:offset];
  [self addLineToPoint:CGPointMake(26, 18) path:path offset:offset];
  [self addLineToPoint:CGPointMake(25, 12) path:path offset:offset];
  [self addLineToPoint:CGPointMake(19, 7) path:path offset:offset];
  [self addLineToPoint:CGPointMake(11, 8) path:path offset:offset];
  CGPathCloseSubpath(path);

  self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
  [self attachDebugFrameFromPath:path color:[SKColor redColor]];

  self.physicsBody.categoryBitMask = EntityCategoryAlienLaser;
  self.physicsBody.collisionBitMask = 0;
  self.physicsBody.contactTestBitMask = EntityCategoryPlayer;
}

@end
