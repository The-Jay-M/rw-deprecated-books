//
//  Player.m
//  SKPocketCyclops
//
//  Created by Matthijs on 15-11-13.
//  Copyright (c) 2013 Razeware, LLC. All rights reserved.
//

#import "Player.h"

#define kPlayerWidth 30
#define kPlayerHeight 38

@implementation Player

- (id)initWithImageNamed:(NSString *)name {
  if (self = [super initWithImageNamed:name]) {
    self.velocity = CGPointMake(0.0, 0.0);
  }
  return self;
}

- (void)update:(NSTimeInterval)dt {
  CGPoint gravity = CGPointMake(0.0, -450.0);
  CGPoint gravityStep = CGPointMultiplyScalar(gravity, dt);
  self.velocity = CGPointAdd(self.velocity, gravityStep);

  CGPoint stepVelocity = CGPointMultiplyScalar(self.velocity, dt);
  self.desiredPosition = CGPointAdd(self.position, stepVelocity);
}

- (CGRect)collisionBoundingBox {
  CGRect bounding = CGRectMake(
      self.desiredPosition.x - (kPlayerWidth / 2),
      self.desiredPosition.y - (kPlayerHeight / 2),
      kPlayerWidth, kPlayerHeight);

  return CGRectOffset(bounding, 0, -3);
}

@end
