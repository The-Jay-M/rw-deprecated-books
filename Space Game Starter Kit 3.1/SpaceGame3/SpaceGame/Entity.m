//
//  Entity.m
//  SpaceGame
//
//  Created by Ray Wenderlich on 10/23/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

#import "Entity.h"

@implementation Entity

- (instancetype)initWithImageNamed:(NSString *)name maxHp:(NSInteger)maxHp {
  if ((self = [super initWithImageNamed:name])) {
    _maxHp = maxHp;
    _hp = maxHp;
  }
  return self;
}

- (void)moveToPoint:(CGPoint)point path:(CGMutablePathRef)path offset:(CGPoint)offset {
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    CGPathMoveToPoint(path, NULL, point.x*2 - offset.x, point.y*2 - offset.y);
  } else {
    CGPathMoveToPoint(path, NULL, point.x - offset.x, point.y - offset.y);
  }
}

- (void)addLineToPoint:(CGPoint)point path:(CGMutablePathRef)path offset:(CGPoint)offset {
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    CGPathAddLineToPoint(path, NULL, point.x*2 - offset.x, point.y*2 - offset.y);
  } else {
    CGPathAddLineToPoint(path, NULL, point.x - offset.x, point.y - offset.y);
  }
}

- (void)collidedWith:(SKPhysicsBody *)body contact:(SKPhysicsContact*)contact {
}

// 1
- (BOOL)isDead {
  return _hp <= 0;
}

// 2
- (void)takeHit {
  if (_hp > 0) {
    _hp--;
  }
  if ([self isDead]) {
    [self destroy];
  }
}

// 3
- (void)cleanup {
  [self removeFromParent];
}

// 4
- (void)destroy {
  _hp = 0;
  self.physicsBody = nil;
  [self removeAllActions];
  [self runAction:
    [SKAction sequence:@[
      [SKAction fadeAlphaTo:0 duration:0.2],
      [SKAction performSelector:@selector(cleanup) onTarget:self]
    ]]
  ];
}

- (void)update:(CFTimeInterval)dt {
}

@end
