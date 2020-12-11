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
    CCAnimation *walkingAnim;
    CCAnimation *jumpUpAnim;
    CCAnimation *wallSlideAnim;
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

-(void)loadAnimations {
    wallSlideAnim = [self loadAnimationFromPlist:@"wallSlideAnim" forClass:@"Player"];
    walkingAnim = [self loadAnimationFromPlist:@"walkingAnim" forClass:@"Player"];
    jumpUpAnim = [self loadAnimationFromPlist:@"jumpUpAnim" forClass:@"Player"];
}

-(void)update:(ccTime)dt
{

    CharacterStates newState = self.characterState;

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
        if ((self.characterState == kStateJumping || self.characterState == kStateFalling) && jumpReset) {
            self.velocity = ccp(self.velocity.x, kJumpForce);
            jumpReset = NO;
            newState = kStateDoubleJumping;
        } else if ((self.onGround || self.characterState == kStateWallSliding) && jumpReset) {
            self.velocity = ccp(self.velocity.x, kJumpForce);
            //2
            jumpReset = NO;
            
            if (self.characterState == kStateWallSliding) {
                 int direction = -1;
                 if (self.flipX) {
                      direction = 1;
                 }
                 self.velocity = ccp(direction * kJumpOut, self.velocity.y);
            }
            
            newState = kStateJumping;
            self.onGround = NO;
        }
    } else {
        if (self.velocity.y > kJumpCutoff) {
            self.velocity = ccp(self.velocity.x, kJumpCutoff);
        }
        //3
        jumpReset = YES;
    }
    
    if (self.onGround && jd == kJoyDirectionNone) {
        newState = kStateStanding;
    } else if (self.onGround && jd != kJoyDirectionNone) {
        newState = kStateWalking;
    } else if (self.onWall && self.velocity.y < 0) {
        newState = kStateWallSliding;
        ////Here
    } else if ( self.characterState == kStateDoubleJumping || newState == kStateDoubleJumping) {
        newState = kStateDoubleJumping;
    } else if ( self.characterState == kStateJumping || newState == kStateJumping){
        newState = kStateJumping;
    } else {
        newState = kStateFalling;
    }

    [self changeState:newState];
    
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

    if (self.characterState == kStateWallSliding) {
        float fallingSpeed = clampf(self.velocity.y, kWallSlideSpeed, 0);
        self.velocity = ccp(self.velocity.x, fallingSpeed);
    }

    self.desiredPosition = ccpAdd(self.position, stepVelocity);
    
    //if (self.onWall) {
    //    NSLog(@"On a Wall");
    //}
}

-(CGRect)collisionBoundingBox {
    CGRect bounding = CGRectMake(self.desiredPosition.x - (kPlayerWidth / 2), self.desiredPosition.y - (kPlayerHeight / 2), kPlayerWidth, kPlayerHeight);
    return CGRectOffset(bounding, 0, -3);
}

-(void)changeState:(CharacterStates)newState {
    if (newState == self.characterState) {
        return;
    }
    
    self.characterState = newState;
    
    //1
    [self stopAllActions];
    
    //2
    id action = nil;
    
    //3
    switch (newState) {
        case kStateStanding:
            //4
            [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Player1.png"]];
            break;
        case kStateFalling:
            [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Player10.png"]];
            break;
        case kStateWalking:
            //5  
            action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkingAnim]];
            break;
        case kStateWallSliding:
            action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:wallSlideAnim]];
            break;
        case kStateJumping:
            action = [CCAnimate actionWithAnimation:jumpUpAnim];
            break;
        case kStateDoubleJumping:
            [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Player10.png"]];
            break;
        default:
            //6
            [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Player1.png"]];
            break;
    }

    //7
    if (action) {
        [self runAction:action];
    }
}

@end
