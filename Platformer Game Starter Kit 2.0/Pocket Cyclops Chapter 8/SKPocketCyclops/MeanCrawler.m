//
//  MeanCrawler.m
//  SKPocketCyclops
//
//  Created by Matthijs on 16-11-13.
//  Copyright (c) 2013 Razeware, LLC. All rights reserved.
//

#import "MeanCrawler.h"

#define kMovementSpeed 60
#define kJumpForce 250

@interface MeanCrawler ()
@property (nonatomic, strong) SKAction *walkingAnim;
@property (nonatomic, strong) SKAction *jumpUpAnim;
@end

@implementation MeanCrawler

- (void)loadAnimations {
  self.walkingAnim = [self loadAnimationFromPlist:@"walkingAnim" forClass:@"MeanCrawler"];
  self.jumpUpAnim = [self loadAnimationFromPlist:@"jumpUpAnim" forClass:@"MeanCrawler"];
}

- (void)update:(NSTimeInterval)dt {
  CGFloat distance = CGPointDistance(self.position, self.player.position);
  if (distance > 1000) {
    self.desiredPosition = self.position;
    return;
  }

  if (self.onGround) {
    [self changeState:kStateWalking];
  }

  TMXLayer *layer = [self.map layerNamed:@"walls"];
  CGPoint myTileCoord = [layer coordForPoint:self.position];

  CGPoint twoTilesAhead = CGPointZero;
  NSInteger playerDirection = (signbit(self.position.x - self.player.position.x)) ? 1 : -1;

  twoTilesAhead = CGPointMake(myTileCoord.x + (playerDirection * 2), myTileCoord.y);
  twoTilesAhead = CGPointMake(Clamp(twoTilesAhead.x, 0, self.map.mapSize.width), Clamp(twoTilesAhead.y, 0, self.map.mapSize.height));

  self.velocity = CGPointMake((playerDirection * kMovementSpeed), self.velocity.y);

  if ([self.map isWallAtTileCoord:twoTilesAhead] || (distance < 100 && (self.player.position.y - self.position.y) > 50)) {
    if (self.onGround) {
      self.velocity = CGPointMake(self.velocity.x, kJumpForce);
      [self changeState:kStateJumping];
    }
  }

  CGPoint gravity = CGPointMake(0.0, -450.0);
  CGPoint gravityStep = CGPointMultiplyScalar(gravity, dt);
  self.velocity = CGPointAdd(self.velocity, gravityStep);
  if (self.velocity.x > 0) {
    self.flipX = NO;
  } else {
    self.flipX = YES;
  }

  CGPoint velocityStep = CGPointMultiplyScalar(self.velocity, dt);
  self.desiredPosition = CGPointAdd(self.position, velocityStep);
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
    case kStateJumping: {
      action = self.jumpUpAnim;
      break;
    }
    case kStateFalling: {
      [self setTexture:[[PSKSharedTextureCache sharedCache] textureNamed:@"MeanCrawler1.png"]];
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
