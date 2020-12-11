//
//  PSKCharacter.h
//  SKPocketCyclops
//
//  Created by Matthijs on 15-11-13.
//  Copyright (c) 2013 Razeware, LLC. All rights reserved.
//

#import "PSKGameObject.h"
#import "SKTUtils.h"

typedef NS_ENUM(NSInteger, CharacterState) {
  kStateJumping,
  kStateDoubleJumping,
  kStateWalking,
  kStateStanding,
  kStateDying,
  kStateFalling,
  kStateDead,
  kStateWallSliding,
  kStateAttacking,
  kStateSeeking,
  kStateHiding
};

@interface PSKCharacter : PSKGameObject

@property (nonatomic, assign) CGPoint velocity;
@property (nonatomic, assign) CGPoint desiredPosition;
@property (nonatomic, assign) BOOL onGround;
@property (nonatomic, assign) BOOL onWall;
@property (nonatomic, assign) CharacterState characterState;

- (void)update:(NSTimeInterval)dt;
- (CGRect)collisionBoundingBox;
- (void)changeState:(CharacterState)newState;

@end
