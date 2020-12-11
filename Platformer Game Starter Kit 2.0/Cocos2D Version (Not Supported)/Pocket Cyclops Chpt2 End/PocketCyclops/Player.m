//
//  Player.m
//  PocketCyclops
//
//  Created by Ray Wenderlich on 1/9/13.
//  Copyright 2013 Jake Gundersen. All rights reserved.
//

#import "Player.h"


@implementation Player

// 1
-(id)initWithSpriteFrameName:(NSString *)spriteFrameName
{
    if (self = [super initWithSpriteFrameName:spriteFrameName]) {
        self.velocity = ccp(0.0, 0.0);
    }
    return self;
}

-(void)update:(ccTime)dt
{
    
    // 2
    CGPoint gravity = ccp(0.0, -450.0);
    
    // 3
    CGPoint gravityStep = ccpMult(gravity, dt);
    
    // 4
    self.velocity = ccpAdd(self.velocity, gravityStep);
    CGPoint stepVelocity = ccpMult(self.velocity, dt);
    
    // 5
    self.position = ccpAdd(self.position, stepVelocity);
}

@end
