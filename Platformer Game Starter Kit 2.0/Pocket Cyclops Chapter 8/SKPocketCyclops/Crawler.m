//
//  Crawler.m
//  SKPocketCyclops
//
//  Created by Matthijs on 16-11-13.
//  Copyright (c) 2013 Razeware, LLC. All rights reserved.
//

#import "Crawler.h"

#define kCrawlerWidth 32
#define kCrawlerHeight 32

#define kMovementSpeed 60

@interface Crawler ()
@property (nonatomic, strong) SKAction *walkingAnim;
@end

@implementation Crawler

- (void)loadAnimations {
  self.walkingAnim = [self loadAnimationFromPlist:@"walkingAnim" forClass:@"Crawler"];
}

- (void)update:(NSTimeInterval)dt {
  CGFloat distance = CGPointDistance(self.position, self.player.position);
  if (distance > 1000) {
    self.desiredPosition = self.position;
    return;
  }

  if (self.onGround) {
    [self changeState:kStateWalking];
    if (self.flipX) {
      self.velocity = CGPointMake(-kMovementSpeed, 0);
    } else {
      self.velocity = CGPointMake(kMovementSpeed, 0);
    }
  } else {
    [self changeState:kStateFalling];
    self.velocity = CGPointMake(self.velocity.x * 0.98, self.velocity.y);
  }
  if (self.onWall) {
    self.velocity = CGPointMake(-self.velocity.x, self.velocity.y);
    if (self.velocity.x > 0) {
      self.flipX = NO;
    } else {
      self.flipX = YES;
    }
  }

  CGPoint gravity = CGPointMake(0.0, -450.0);
  CGPoint gravityStep = CGPointMultiplyScalar(gravity, dt);
  
  self.velocity = CGPointAdd(self.velocity, gravityStep);
  self.desiredPosition = CGPointAdd(self.position, CGPointMultiplyScalar(self.velocity, dt));
}

- (CGRect)collisionBoundingBox {
  return CGRectMake(
    self.desiredPosition.x - (kCrawlerWidth / 2), 
    self.desiredPosition.y - (kCrawlerHeight / 2), 
    kCrawlerWidth, kCrawlerHeight);
}

- (void)changeState:(CharacterState)newState {
  if (newState == self.characterState) return;
  [self removeAllActions];
  self.characterState = newState;

  SKAction *action = nil;
  switch (newState) {
    case kStateWalking: {
      action = [SKAction repeatActionForever:self.walkingAnim];
      break;
    }
    case kStateFalling: {
      [self setTexture:[[PSKSharedTextureCache sharedCache] textureNamed:@"Crawler1.png"]];
      [self setSize:self.texture.size];
      break;
    }
    default:
      break;
  }
  if (action != nil) {
    [self runAction:action];
  }
}

@end
