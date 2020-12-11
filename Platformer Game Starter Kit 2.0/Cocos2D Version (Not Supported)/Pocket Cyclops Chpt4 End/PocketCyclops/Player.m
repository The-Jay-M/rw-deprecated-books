//
//  Player.m
//  PocketCyclops
//
//  Created by Ray Wenderlich on 1/9/13.
//  Copyright 2013 Jake Gundersen. All rights reserved.
//

#import "Player.h"
#import "HUDLayer.h"

@interface Player () {
    BOOL jumpReset;
}

@end

@implementation Player

// 1
-(id)initWithSpriteFrameName:(NSString *)spriteFrameName
{
    if (self = [super initWithSpriteFrameName:spriteFrameName]) {
        self.velocity = ccp(0.0, 0.0);
        jumpReset = YES;
    }    
    return self;
}

-(void)update:(ccTime)dt
{

    //1
    HUDLayer *h = (HUDLayer *)[[[CCDirector sharedDirector] runningScene] getChildByTag:25];
    //2
    joystickDirection jd = [h getJoystickDirection];
    //3
    CGPoint joyForce = ccp(0,0);

    //4
    if (jd == kJoyDirectionLeft) {
        self.flipX = YES;
        joyForce = ccp(-kWalkingSpeed, 0);
    } else if (jd == kJoyDirectionRight) {
        self.flipX = NO;
        joyForce = ccp(kWalkingSpeed, 0);
    }
    //5
    CGPoint joyForceStep = ccpMult(joyForce, dt);
    //6
    self.velocity = ccpAdd(self.velocity, joyForceStep);
    
    jumpButtonState js = [h getJumpButtonState];

    if (js == kJumpButtonOn) {
        //1
        if (self.onGround && jumpReset) {
            self.velocity = ccp(self.velocity.x, kJumpForce);
            //2
            jumpReset = NO;
        }
    } else {
        if (self.velocity.y > kJumpCutoff) {
            self.velocity = ccp(self.velocity.x, kJumpCutoff);
        }
        //3
        jumpReset = YES;
    }
    
    // 2
    CGPoint gravity = ccp(0.0, -450.0);
    
    // 3
    CGPoint gravityStep = ccpMult(gravity, dt);
    
    // 4
    self.velocity = ccpAdd(self.velocity, gravityStep);
    CGPoint stepVelocity = ccpMult(self.velocity, dt);
    
    // 5
    self.velocity = ccp(self.velocity.x * kDamping, self.velocity.y);
    self.velocity = ccpClamp(self.velocity, ccp(-kMaxSpeed, -kMaxSpeed), ccp(kMaxSpeed, kMaxSpeed));
    self.desiredPosition = ccpAdd(self.position, stepVelocity);
}

-(CGRect)collisionBoundingBox {
    CGRect bounding = CGRectMake(self.desiredPosition.x - (kPlayerWidth / 2), self.desiredPosition.y - (kPlayerHeight / 2), kPlayerWidth, kPlayerHeight);
    return CGRectOffset(bounding, 0, -3);
}


@end
