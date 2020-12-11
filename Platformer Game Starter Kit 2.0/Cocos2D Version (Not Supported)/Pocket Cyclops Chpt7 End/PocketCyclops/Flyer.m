//
//  Flyer.m
//  PocketCyclops
//
//  Created by Ray Wenderlich on 1/23/13.
//  Copyright 2013 Jake Gundersen. All rights reserved.
//

#import "Flyer.h"

@interface Flyer () {
    CCAnimation *seekingAnim;
    CCAnimation *attackingAnim;
}
@end

@implementation Flyer

-(void)loadAnimations {
    seekingAnim = [self loadAnimationFromPlist:@"seekingAnim" 
     forClass:@"Flyer"];
    attackingAnim = [self 
     loadAnimationFromPlist:@"attackingAnim" forClass:@"Flyer"];
}

-(void)update:(ccTime)dt {
    //1
    float distance = ccpDistance(self.position, self.player.position);
    if (distance > 1000) {
        self.desiredPosition = self.position;
        return;
    }
    
    //2
    float speed;
    
    //3
    if (distance < 100) {
        [self changeState:kStateAttacking];
        speed = 100;
    //4
    } else if ((!self.player.flipX && self.player.position.x < self.position.x) || (self.player.flipX && self.player.position.x > self.position.x)) {
        [self changeState:kStateHiding];
        speed = 0;
    //5
    } else {
        [self changeState:kStateSeeking];
        speed = 60;
    }
    
    //6
    CGPoint v = ccpNormalize(ccpSub(self.player.position, self.position));
    self.velocity = ccpMult(v, speed);
    
    //7
    if (self.position.x < self.player.position.x) {
        self.flipX = NO;
    } else {
        self.flipX = YES;
    }
    
    //8
    CGPoint stepVelocity = ccpMult(self.velocity, dt);
    self.desiredPosition = ccpAdd(self.position, stepVelocity);
}

-(void)changeState:(CharacterStates)newState {
    if (newState == self.characterState) {
        return;
    }
    
    [self stopAllActions];
    self.characterState = newState;
    
    id action = nil;
    
    switch (newState) {
        case kStateSeeking:
            action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:seekingAnim]];
            
            break;
        case kStateHiding:
            
            [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Flyer4.png"]];
            
            break;
        case kStateAttacking:
            action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:attackingAnim]];
            break;
        default:
            break;
            
    }
    if (action != nil) {
        [self runAction:action];
    }
}


@end
