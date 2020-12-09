//
//  Boss.m
//  PompaDroid
//
//  Created by Ray Wenderlich on 3/15/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import "Boss.h"
#import "SimpleAudioEngine.h"

@implementation Boss

-(id)init
{
    if ((self = [super initWithSpriteFrameName:@"boss_idle_00.png"]))
    {
        self.shadow = [CCSprite spriteWithSpriteFrameName:@"shadow_character.png"];
        self.shadow.opacity = 190;
        
        //idle animation
        CCAnimation *idleAnimation = [self animationWithPrefix:@"boss_idle" startFrameIdx:0 frameCount:5 delay:1.0/10.0];
        self.idleAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:idleAnimation]];
        
        //attack animation
        CCAnimation *attackAnimation = [self animationWithPrefix:@"boss_attack" startFrameIdx:0 frameCount:5 delay:1.0/8.0];
        
        self.attackAction = [CCSequence actions:[CCAnimate actionWithAnimation:attackAnimation], [CCCallFunc actionWithTarget:self selector:@selector(idle)], nil];
        
        //walk animation
        CCAnimation *walkAnimation = [self animationWithPrefix:@"boss_walk" startFrameIdx:0 frameCount:6 delay:1.0/8.0];
        
        self.walkAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimation]];
        
        //hurt animation
        CCAnimation *hurtAnimation = [self animationWithPrefix:@"boss_hurt" startFrameIdx:0 frameCount:3 delay:1.0/12.0];
        
        self.hurtAction = [CCSequence actions:[CCAnimate actionWithAnimation:hurtAnimation], [CCCallFunc actionWithTarget:self selector:@selector(idle)], nil];
        
        //knocked out animation
        CCAnimation *knockedOutAnimation = [self animationWithPrefix:@"boss_knockout" startFrameIdx:0 frameCount:4 delay:1.0/12.0];
        
        self.knockedOutAction = [CCAnimate actionWithAnimation:knockedOutAnimation];
        
        //die action
        self.dieAction = [CCBlink actionWithDuration:2.0 blinks:10.0];
        
        //recover animation
        CCAnimation *recoverAnimation = [self animationWithPrefix:@"boss_getup" startFrameIdx:0 frameCount:6 delay:1.0/12.0];
        
        self.recoverAction = [CCSequence actions:[CCAnimate actionWithAnimation:recoverAnimation], [CCCallFunc actionWithTarget:self selector:@selector(idle)], nil];
        
        self.walkSpeed = 60 * kPointFactor;
        self.runSpeed = 120 * kPointFactor;
        self.directionX = 1.0;
        self.centerToBottom = 39.0 * kPointFactor;
        self.centerToSides = 42.0 * kPointFactor;
        
        self.detectionRadius = 90.0 * kPointFactor;
        
        self.contactPointCount = 4;
        self.contactPoints = malloc(sizeof(ContactPoint) * self.contactPointCount);
        self.attackPointCount = 1;
        self.attackPoints = malloc(sizeof(ContactPoint) * self.attackPointCount);
        [self modifyAttackPointAtIndex:0 offset:ccp(65.0, 42.0) radius:23.7];
        
        self.maxHitPoints = 500.0;
        self.hitPoints = self.maxHitPoints;
        self.attackDamage = 15.0;
        self.attackForce = 2.0 * kPointFactor;
    }
    return self;
}

-(void)setContactPointsForAction:(ActionState)actionState
{
    if (actionState == kActionStateIdle)
    {
        [self modifyContactPointAtIndex:0 offset:ccp(7.0, 36.0) radius:23.0];
        [self modifyContactPointAtIndex:1 offset:ccp(-11.0, 17.0) radius:23.5];
        [self modifyContactPointAtIndex:2 offset:ccp(-2.0, -20.0) radius:23.0];
        [self modifyContactPointAtIndex:3 offset:ccp(24.0, 9.0) radius:18.0];
    }
    else if (actionState == kActionStateWalk)
    {
        [self modifyContactPointAtIndex:0 offset:ccp(6.0, 41.0) radius:22.0];
        [self modifyContactPointAtIndex:1 offset:ccp(-5.0, 16.0) radius:26.0];
        [self modifyContactPointAtIndex:2 offset:ccp(1.0, -11.0) radius:17.0];
        [self modifyContactPointAtIndex:3 offset:ccp(-13.0, -25.0) radius:10.0];
    }
    else if (actionState == kActionStateAttack)
    {
        [self modifyContactPointAtIndex:0 offset:ccp(20.0, 38.0) radius:22.0];
        [self modifyContactPointAtIndex:1 offset:ccp(-8.0, 7.0) radius:27.3];
        [self modifyContactPointAtIndex:2 offset:ccp(49.0, 18.0) radius:19.0];
        [self modifyContactPointAtIndex:3 offset:ccp(12.0, -8.0) radius:31.0];
        [self modifyAttackPointAtIndex:0 offset:ccp(65.0, 42.0) radius:23.7];
    }
}

-(void)setDisplayFrame:(CCSpriteFrame *)newFrame
{
    [super setDisplayFrame:newFrame];
    
    CCSpriteFrame *attackFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"boss_attack_01.png"];
    CCSpriteFrame *attackFrame2 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"boss_attack_02.png"];
    
    if (newFrame == attackFrame || newFrame == attackFrame2)
    {
        [self.delegate actionSpriteDidAttack:self];
    }
}

-(void)hurtWithDamage:(float)damage force:(float)force direction:(CGPoint)direction
{
    if (self.actionState > kActionStateNone && self.actionState < kActionStateKnockedOut)
    {
        float ratio = self.hitPoints / self.maxHitPoints;
        
        if (ratio <= 0.1)
        {
            [self stopAllActions];
            [self runAction:self.hurtAction];
            self.actionState = kActionStateHurt;
        }
        
        self.hitPoints -= damage;
        self.desiredPosition = ccp(self.position.x + direction.x * force, self.position.y);
        
        if (self.hitPoints <= 0)
        {
            [self knockoutWithDamage:0 direction:direction];
        }
    }
}

-(void)knockoutWithDamage:(float)damage direction:(CGPoint)direction
{
    [super knockoutWithDamage:damage direction:direction];
    if (self.actionState == kActionStateKnockedOut && self.hitPoints <= 0)
    {
        [[SimpleAudioEngine sharedEngine] playEffect:@"enemydeath.caf"];
    }
}

@end
