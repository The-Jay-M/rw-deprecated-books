//
//  HitEffect.m
//  PompaDroid
//
//  Created by Ray Wenderlich on 3/15/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import "HitEffect.h"

@implementation HitEffect

-(id)init
{
    if ((self = [super initWithSpriteFrameName:@"hiteffect_00.png"]))
    {
        CCArray *frames = [CCArray arrayWithCapacity:6];
        int i;
        CCSpriteFrame *frame;
        for (i = 0; i < 6; i++)
        {
            frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"hiteffect_%02d.png", i]];
            [frames addObject:frame];
        }
        
        self.effectAction = [CCSequence actions:[CCShow action], [CCAnimate actionWithAnimation:[CCAnimation animationWithSpriteFrames:[frames getNSArray] delay:1.0/12.0]], [CCHide action], nil];
    }
    return self;
}

-(void)showEffectAtPosition:(CGPoint)position
{
    [self stopAllActions];
    self.position = position;
    [self runAction:_effectAction];
}

@end
