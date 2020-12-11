//
//  MeanCrawler.m
//  PocketCyclops
//
//  Created by Ray Wenderlich on 1/23/13.
//  Copyright 2013 Jake Gundersen. All rights reserved.
//

#import "MeanCrawler.h"

#define kMovementSpeed 60
#define kJumpForce 250

@interface MeanCrawler () {
    CCAnimation *walkingAnim;
    CCAnimation *jumpUpAnim;
}
@end

@implementation MeanCrawler

-(void)loadAnimations {
    walkingAnim = [self loadAnimationFromPlist:@"walkingAnim" 
      forClass:@"MeanCrawler"];
    jumpUpAnim = [self loadAnimationFromPlist:@"jumpUpAnim" 
      forClass:@"MeanCrawler"];
}

-(void)update:(ccTime)dt {
    //1
    float distance = ccpDistance(self.position, self.player.position);
    if (distance > 1000) {
        self.desiredPosition = self.position;
        return;
    }
    
    //2
    if (self.onGround) {
        [self changeState:kStateWalking];
    }
    
    //3
    CGPoint myTileCoord = [self.map tileCoordForPosition:self.position];
    CGPoint twoTilesAhead;
    
    //4
    if (self.player.position.x > self.position.x) {
        twoTilesAhead = ccp(myTileCoord.x + 2, myTileCoord.y);
        self.velocity = ccp(kMovementSpeed, self.velocity.y);
    } else {
        twoTilesAhead = ccp(myTileCoord.x - 2, myTileCoord.y);
        self.velocity = ccp(-kMovementSpeed,  self.velocity.y);
    }
    
    //5
    twoTilesAhead = ccpClamp(twoTilesAhead, ccp(0,0), ccp(self.map.mapSize.width, self.map.mapSize.height));
    
    //6
    if ([self.map isWallAtTileCoord:twoTilesAhead]) {
        //7
        if (self.onGround) {
            self.velocity = ccp(self.velocity.x, kJumpForce);
            [self changeState:kStateJumping];
        }
    }
    
    //8
    if (distance < 100 && (self.player.position.y - self.position.y) > 50) {
        if (self.onGround) {
            self.velocity = ccp(self.velocity.x, kJumpForce);
            [self changeState:kStateJumping];
        }
    }
    
    //9
    CGPoint gravity = ccp(0.0, -450.0);
    CGPoint gravityStep = ccpMult(gravity, dt);
    
    //10
    self.velocity = ccpAdd(self.velocity, gravityStep);
    
    //11
    if (self.velocity.x > 0) {
        self.flipX = NO;
    } else {
        self.flipX = YES;
    }
    
    //12
    CGPoint velocityStep = ccpMult(self.velocity, dt);
    self.desiredPosition = ccpAdd(self.position, velocityStep);
}


-(void)changeState:(CharacterStates)newState {
    if (newState == self.characterState) {
        return;
    }
    
    [self stopAllActions];
    id action = nil;
    self.characterState = newState;
    
    switch (newState) {
        case kStateWalking:
            action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkingAnim]];
            break;
        case kStateJumping:
            action = [CCAnimate actionWithAnimation:jumpUpAnim];
            break;
        default:
            break;
    }
    
    if (action != nil) {
        [self runAction:action];
    }
    
}

@end
