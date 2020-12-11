//
//  Crawler.m
//  PocketCyclops
//
//  Created by Ray Wenderlich on 1/23/13.
//  Copyright 2013 Jake Gundersen. All rights reserved.
//

#import "Crawler.h"

@interface Crawler () {
    CCAnimation *walkingAnim;
}
@end

@implementation Crawler

-(void)loadAnimations {
    walkingAnim = [self loadAnimationFromPlist:@"walkingAnim" forClass:@"Crawler"];
}

-(void)update:(ccTime)dt {
    
    float distance = ccpDistance(self.position, self.player.position);
    if (distance > 1000) {
        self.desiredPosition = self.position;
        return;
    }

    //1
    if (self.onGround) {
        [self changeState:kStateWalking];
        //2
        if (self.flipX) {
            self.velocity = ccp(-kMovementSpeed, 0);
        } else {
            self.velocity = ccp(kMovementSpeed, 0);
        }
        //3
    } else {
        [self changeState:kStateFalling];
        self.velocity = ccp(self.velocity.x * 0.98, self.velocity.y);
    }

    //4
    if (self.onWall) {
        
        self.velocity = ccp(-self.velocity.x, self.velocity.y);
        //5
        if (self.velocity.x > 0) {
            self.flipX = NO;
        } else {
            self.flipX = YES;
        }
    }
    
    CGPoint gravity = ccp(0.0, -450.0);
    CGPoint gravityStep = ccpMult(gravity, dt);
    
    self.velocity = ccpAdd(self.velocity, gravityStep);
    self.desiredPosition = ccpAdd(self.position, ccpMult(self.velocity, dt));
}

-(void)changeState:(CharacterStates)newState {
    if (newState == self.characterState) {
        return;
    }
    
    [self stopAllActions];
    self.characterState = newState;
    
    id action = nil;
    
    switch (newState) {
        case kStateWalking:
            action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkingAnim]];
            break;
        case kStateFalling:
            [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Crawler1.png"]];
            break;
        default:
            break;
    }
    
    if (action != nil) {
        [self runAction:action];
    }
}

@end
