//
//  Character.h
//  PocketCyclops
//
//  Created by Ray Wenderlich on 1/9/13.
//  Copyright 2013 Jake Gundersen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameObject.h"

typedef enum {
    kStateJumping,
    kStateDoubleJumping,
    kStateWalking,
    kStateStanding,
    kStateDying,
    kStateFalling,
    kStateDead,
    kStateWallSliding
} CharacterStates;

@interface Character : GameObject {
    
}

@property (nonatomic, assign) CGPoint desiredPosition;
@property (nonatomic, assign) BOOL onGround;
@property (nonatomic, assign) CharacterStates characterState;
@property (nonatomic, assign) BOOL onWall;

-(void)changeState:(CharacterStates)newState;
-(void)update:(ccTime)dt;
-(CGRect)collisionBoundingBox;

@end
