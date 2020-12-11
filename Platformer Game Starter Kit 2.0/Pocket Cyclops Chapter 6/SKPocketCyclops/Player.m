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

#define kWalkingAcceleration 1600
#define kDamping 0.85
#define kMaxSpeed 250
#define kJumpForce 400
#define kJumpCutoff 150
#define kJumpOut 360
#define kWallSlideSpeed -30

@interface Player ()
@property (nonatomic, assign) BOOL jumpReset;
@end

@implementation Player

- (id)initWithImageNamed:(NSString *)name {
  if (self = [super initWithImageNamed:name]) {
    self.velocity = CGPointMake(0.0, 0.0);
    self.jumpReset = YES;
  }
  return self;
}

- (void)update:(NSTimeInterval)dt {
  CharacterState newState = self.characterState;

  CGPoint joyForce = CGPointZero;
  if (self.hud.joyDirection == kJoyDirectionLeft) {
    self.flipX = YES;
    joyForce = CGPointMake(-kWalkingAcceleration, 0);
  } else if (self.hud.joyDirection == kJoyDirectionRight) {
    self.flipX = NO;
    joyForce = CGPointMake(kWalkingAcceleration, 0);
  }

  CGPoint joyForceStep = CGPointMultiplyScalar(joyForce, dt);
  self.velocity = CGPointAdd(self.velocity, joyForceStep);

  if (self.hud.jumpState == kJumpButtonOn) {
    if ((self.characterState == kStateJumping || self.characterState == kStateFalling) && self.jumpReset) {
      self.velocity = CGPointMake(self.velocity.x, kJumpForce);
      self.jumpReset = NO;
      newState = kStateDoubleJumping;
    } else if ((self.onGround || self.characterState == kStateWallSliding) && self.jumpReset) {
      self.velocity = CGPointMake(self.velocity.x, kJumpForce);
      self.jumpReset = NO;

      if (self.characterState == kStateWallSliding) {
         NSInteger direction = -1;
         if (self.flipX) {
            direction = 1;
         }
         self.velocity = CGPointMake(direction * kJumpOut, self.velocity.y);
      }

      newState = kStateJumping;
      self.onGround = NO;
    }
  } else {
    if (self.velocity.y > kJumpCutoff) {
      self.velocity = CGPointMake(self.velocity.x, kJumpCutoff);
    }
    self.jumpReset = YES;
  }

  if (self.onGround && self.hud.joyDirection == kJoyDirectionNone) {
    newState = kStateStanding;
  } else if (self.onGround && self.hud.joyDirection != kJoyDirectionNone) {
    newState = kStateWalking;
  } else if (self.onWall && self.velocity.y < 0) {
    newState = kStateWallSliding;
  } else if (self.characterState == kStateDoubleJumping || newState == kStateDoubleJumping) {
    newState = kStateDoubleJumping;
  } else if (self.characterState == kStateJumping || newState == kStateJumping) {
    newState = kStateJumping;
  } else {
    newState = kStateFalling;
  }
  [self changeState:newState];

  CGPoint gravity = CGPointMake(0.0, -450.0);
  CGPoint gravityStep = CGPointMultiplyScalar(gravity, dt);
  self.velocity = CGPointAdd(self.velocity, gravityStep);

  self.velocity = CGPointMake(self.velocity.x * kDamping, self.velocity.y);

  self.velocity = CGPointMake(Clamp(self.velocity.x, -kMaxSpeed, kMaxSpeed), Clamp(self.velocity.y, -kMaxSpeed, kMaxSpeed));

  if (self.characterState == kStateWallSliding) {
    CGFloat fallingSpeed = Clamp(self.velocity.y, kWallSlideSpeed, 0);
    self.velocity = CGPointMake(self.velocity.x, fallingSpeed);
  }

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

- (void)changeState:(CharacterState)newState {
  if (newState == self.characterState) return;
  NSLog(@"Change State %ld", (long)newState);
  self.characterState = newState;
}

@end
