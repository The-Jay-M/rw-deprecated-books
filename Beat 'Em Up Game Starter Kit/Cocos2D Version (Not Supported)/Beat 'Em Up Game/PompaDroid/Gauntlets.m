//
//  Gauntlets.m
//  PompaDroid
//
//  Created by Ray Wenderlich on 4/1/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import "Gauntlets.h"

@implementation Gauntlets

-(id)init
{
    if ((self = [super initWithSpriteFrameName:@"weapon_unequipped.png"]))
    {
        self.attack = [self animationMemberWithPrefix:@"weapon_attack_00" startFrameIdx:0 frameCount:3 delay:1.0/15.0 target:self];
        self.attackTwo = [self animationMemberWithPrefix:@"weapon_attack_01" startFrameIdx:0 frameCount:3 delay:1.0/12.0 target:self];
        self.attackThree = [self animationMemberWithPrefix:@"weapon_attack_02" startFrameIdx:0 frameCount:5 delay:1.0/10.0 target:self];
        self.idle = [self animationMemberWithPrefix:@"weapon_idle" startFrameIdx:0 frameCount:6 delay:1.0/12.0 target:self];
        self.walk = [self animationMemberWithPrefix:@"weapon_walk" startFrameIdx:0 frameCount:8 delay:1.0/12.0 target:self];
        
        CCSpriteFrame *dropFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"weapon_unequipped.png"];
        CCAnimation *dropAnimation = [CCAnimation animationWithSpriteFrames:@[dropFrame] delay:1/12.0];
        self.droppedAction = [CCAnimate actionWithAnimation:dropAnimation];
        self.destroyedAction = [CCSequence actions:[CCBlink actionWithDuration:2.0 blinks:5], [CCCallFunc actionWithTarget:self selector:@selector(reset)],nil];
        self.damageBonus = 20.0;
        self.centerToBottom = 5.0 * kPointFactor;
        
        self.shadow = [CCSprite spriteWithSpriteFrameName:@"shadow_weapon.png"];
        self.shadow.opacity = 190;
        self.detectionRadius = 10.0 * kPointFactor;
        
        [self reset];
    }
    return self;
}

-(void)reset
{
    [super reset];
    self.limit = 20;
}

-(void)cleanup
{
    self.attack = nil;
    self.attackTwo = nil;
    self.attackThree = nil;
    self.idle = nil;
    self.walk = nil;
    self.droppedAction = nil;
    self.destroyedAction = nil;
    [super cleanup];
}

@end
