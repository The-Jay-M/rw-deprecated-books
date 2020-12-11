//
//  Character.h
//  PocketCyclops
//
//  Created by Ray Wenderlich on 1/9/13.
//  Copyright 2013 Jake Gundersen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameObject.h"
#import "SimpleAudioEngine.h"

typedef enum {
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
} CharacterStates; 

@interface Character : GameObject {
    
}

@property (nonatomic, assign) CGPoint desiredPosition;
@property (nonatomic, assign) BOOL onGround;
@property (nonatomic, assign) CharacterStates characterState;
@property (nonatomic, assign) BOOL onWall;
@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, assign) int life;

-(void)changeState:(CharacterStates)newState;
-(void)update:(ccTime)dt;
-(CGRect)collisionBoundingBox;
-(void)tookHit:(Character *)character;

@end
