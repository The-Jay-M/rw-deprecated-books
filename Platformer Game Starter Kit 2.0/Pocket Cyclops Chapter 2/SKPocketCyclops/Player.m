//
//  Player.m
//  SKPocketCyclops
//
//  Created by Matthijs on 15-11-13.
//  Copyright (c) 2013 Razeware, LLC. All rights reserved.
//

#import "Player.h"

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
  self.position = CGPointAdd(self.position, stepVelocity);
}

@end
