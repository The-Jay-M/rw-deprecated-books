//
//  Hero.m
//  PompaDroid
//
//  Created by Ray Wenderlich on 2/8/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import "Hero.h"
#import "SimpleAudioEngine.h"

@implementation Hero

-(id)init {
    if ((self = [super initWithSpriteFrameName:@"hero_idle_00.png"])) {
        //idle animation
        CCAnimation *idleAnimation = [self animationWithPrefix:@"hero_idle" startFrameIdx:0 frameCount:6 delay:1.0/12.0];
        _idleGroup = [AnimateGroup actionWithAnimation:idleAnimation memberCount:1];
        self.idleAction = [CCRepeatForever actionWithAction:_idleGroup];
        
        //walk animation
        CCAnimation *walkAnimation = [self animationWithPrefix:@"hero_walk" startFrameIdx:0 frameCount:8 delay:1.0/12.0];
        _walkGroup = [AnimateGroup actionWithAnimation:walkAnimation memberCount:1];
        self.walkAction = [CCRepeatForever actionWithAction:_walkGroup];
        
        // run animation
        CCAnimation *runAnimation = [self animationWithPrefix:@"hero_run" startFrameIdx:0 frameCount:8 delay:1.0/12.0];
        self.runAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:runAnimation]];

        // attack animation
        CCAnimation *attackAnimation = [self animationWithPrefix:@"hero_attack_00" startFrameIdx:0 frameCount:3 delay:1.0/15.0];
        _attackGroup = [AnimateGroup actionWithAnimation:attackAnimation memberCount:1];
        self.attackAction = [CCSequence actions:_attackGroup, [CCCallFunc actionWithTarget:self selector:@selector(idle)], nil];

        // hurt animation
        CCAnimation *hurtAnimation = [self animationWithPrefix:@"hero_hurt" startFrameIdx:0 frameCount:3 delay:1.0/12.0];
        self.hurtAction = [CCSequence actions:[CCAnimate actionWithAnimation:hurtAnimation], [CCCallFunc actionWithTarget:self selector:@selector(idle)], nil];

        //knocked out animation
        CCAnimation *knockedOutAnimation = [self animationWithPrefix:@"hero_knockout" startFrameIdx:0 frameCount:5 delay:1.0/12.0];
        self.knockedOutAction = [CCAnimate actionWithAnimation:knockedOutAnimation];

        //die action
        self.dieAction = [CCBlink actionWithDuration:2.0 blinks:10.0];

        //recover animation
        CCAnimation *recoverAnimation = [self animationWithPrefix:@"hero_getup" startFrameIdx:0 frameCount:6 delay:1.0/12.0];
        self.recoverAction = [CCSequence actions:[CCAnimate actionWithAnimation:recoverAnimation], [CCCallFunc actionWithTarget:self selector:@selector(jumpLand)], nil];

        CCAnimation *jumpAttackAnimation = [self animationWithPrefix:@"hero_jumpattack" startFrameIdx:0 frameCount:5 delay:1.0/10.0];
        self.jumpAttackAction = [CCSequence actions:[CCAnimate actionWithAnimation:jumpAttackAnimation], [CCCallFunc actionWithTarget:self selector:@selector(jumpFall)], nil];

        CCAnimation *runAttackAnimation = [self animationWithPrefix:@"hero_runattack" startFrameIdx:0 frameCount:6 delay:1.0/10.0];
        self.runAttackAction = [CCSequence actions:[CCAnimate actionWithAnimation:runAttackAnimation], [CCCallFunc actionWithTarget:self selector:@selector(idle)], nil];
        
        CCAnimation *attackTwoAnimation = [self animationWithPrefix:@"hero_attack_01" startFrameIdx:0 frameCount:3 delay:1.0/12.0];
        _attackTwoGroup = [AnimateGroup actionWithAnimation:attackTwoAnimation memberCount:1];
        self.attackTwoAction = [CCSequence actions:_attackTwoGroup, [CCCallFunc actionWithTarget:self selector:@selector(idle)], nil];

        CCAnimation *attackThreeAnimation = [self animationWithPrefix:@"hero_attack_02" startFrameIdx:0 frameCount:5 delay:1.0/10.0];
        _attackThreeGroup = [AnimateGroup actionWithAnimation:attackThreeAnimation memberCount:1];
        self.attackThreeAction = [CCSequence actions:_attackThreeGroup, [CCCallFunc actionWithTarget:self selector:@selector(idle)], nil];
        
        self.runSpeed = 160 * kPointFactor;
        self.walkSpeed = 80 * kPointFactor;
        self.directionX = 1.0;
        
        self.centerToBottom = 39.0 * kPointFactor;
        self.centerToSides = 29.0 * kPointFactor;
        
        self.shadow = [CCSprite spriteWithSpriteFrameName:@"shadow_character.png"];
        self.shadow.opacity = 190;

        CCArray *jumpRiseFrames = [CCArray arrayWithCapacity:2];
        [jumpRiseFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"hero_jump_05.png"]];
        [jumpRiseFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"hero_jump_00.png"]];
        self.jumpRiseAction = [CCAnimate actionWithAnimation:[CCAnimation animationWithSpriteFrames:[jumpRiseFrames getNSArray] delay:1.0/12.0]];

        self.jumpFallAction = [CCAnimate actionWithAnimation:[self animationWithPrefix:@"hero_jump" startFrameIdx:1 frameCount:4 delay:1.0/12.0]];

        self.jumpLandAction = [CCSequence actions:[CCCallFunc actionWithTarget:self selector:@selector(setLandingDisplayFrame)], [CCDelayTime actionWithDuration:1.0/12.0], [CCCallFunc actionWithTarget:self selector:@selector(idle)], nil];

        self.detectionRadius = 100.0 * kPointFactor;
        self.attackPointCount = 3;
        self.attackPoints = malloc(sizeof(ContactPoint) * self.attackPointCount);
        self.contactPointCount = 4;
        self.contactPoints = malloc(sizeof(ContactPoint) * self.contactPointCount);

        self.maxHitPoints = 200.0;
        self.hitPoints = self.maxHitPoints;
        self.attackDamage = 5.0;
        self.attackForce = 4.0 * kPointFactor;
        self.jumpAttackDamage = 15.0;
        self.runAttackDamage = 15.0;
        _recoveryRate = 5.0;
        _hurtLimit = 20.0;
        _hurtTolerance = _hurtLimit;
        _attackDelayTime = 0.14;
        _attackTwoDelayTime = 0.14;
        _attackThreeDelayTime = 0.45;
        _chainTimer = 0;
        self.attackTwoDamage = 10.0;
        self.attackThreeDamage = 20.0;

    }
    return self;
}

-(void)setLandingDisplayFrame
{
    [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"hero_jump_05.png"]];
}

-(void)setContactPointsForAction:(ActionState)actionState
{
    if (actionState == kActionStateIdle)
    {
        [self modifyContactPointAtIndex:0 offset:ccp(3.0, 23.0) radius:19.0];
        [self modifyContactPointAtIndex:1 offset:ccp(17.0, 10.0) radius:10.0];
        [self modifyContactPointAtIndex:2 offset:CGPointZero radius:19.0];
        [self modifyContactPointAtIndex:3 offset:ccp(0.0, -21.0) radius:20.0];
    }
    else if (actionState == kActionStateWalk)
    {
        [self modifyContactPointAtIndex:0 offset:ccp(8.0, 23.0) radius:19.0];
        [self modifyContactPointAtIndex:1 offset:ccp(12.0, 4.0) radius:4.0];
        [self modifyContactPointAtIndex:2 offset:CGPointZero radius:10.0];
        [self modifyContactPointAtIndex:3 offset:ccp(0.0, -21.0) radius:20.0];
    }
    else if (actionState == kActionStateAttack)
    {
        [self modifyContactPointAtIndex:0 offset:ccp(15.0, 23.0) radius:19.0];
        [self modifyContactPointAtIndex:1 offset:ccp(24.5, 4.0) radius:6.0];
        [self modifyContactPointAtIndex:2 offset:CGPointZero radius:16.0];
        [self modifyContactPointAtIndex:3 offset:ccp(0.0, -21.0) radius:20.0];
        
        [self modifyAttackPointAtIndex:0 offset:ccp(41.0, 3.0) radius:10.0];
        [self modifyAttackPointAtIndex:1 offset:ccp(41.0, 3.0) radius:10.0];
        [self modifyAttackPointAtIndex:2 offset:ccp(41.0, 3.0) radius:10.0];
    }
    else if (actionState == kActionStateAttackTwo)
    {
        [self modifyAttackPointAtIndex:0 offset:ccp(51.6, 2.4) radius:13.0];
        [self modifyAttackPointAtIndex:1 offset:ccp(51.6, 2.4) radius:13.0];
        [self modifyAttackPointAtIndex:2 offset:ccp(51.6, 2.4) radius:13.0];
    }
    else if (actionState == kActionStateAttackThree)
    {
        [self modifyAttackPointAtIndex:0 offset:ccp(61.8, 6.2) radius:22.0];
        [self modifyAttackPointAtIndex:1 offset:ccp(61.8, 6.2) radius:22.0];
        [self modifyAttackPointAtIndex:2 offset:ccp(61.8, 6.2) radius:22.0];
    }
    else if (actionState == kActionStateRunAttack)
    {
        [self modifyAttackPointAtIndex:0 offset:ccp(31.2, -8.8) radius:10.0];
        [self modifyAttackPointAtIndex:1 offset:ccp(31.2, -8.8) radius:10.0];
        [self modifyAttackPointAtIndex:2 offset:ccp(31.2, -8.8) radius:10.0];
    }
    else if (actionState == kActionStateJumpAttack)
    {
        [self modifyAttackPointAtIndex:2 offset:ccp(70.0, -55.0) radius:8.0];
        [self modifyAttackPointAtIndex:1 offset:ccp(55.0, -42.0) radius:12.0];
        [self modifyAttackPointAtIndex:0 offset:ccp(34.0, -25.0) radius:17.0];
    }
}

-(void)setDisplayFrame:(CCSpriteFrame *)newFrame
{
    [super setDisplayFrame:newFrame];
    
    CCSpriteFrame *attackFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"hero_attack_00_01.png"];
    CCSpriteFrame *runAttackFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"hero_runattack_02.png"];
    CCSpriteFrame *runAttackFrame2 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"hero_runattack_03.png"];
    CCSpriteFrame *jumpAttackFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"hero_jumpattack_02.png"];
    CCSpriteFrame *attackFrame2 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"hero_attack_01_01.png"];
    CCSpriteFrame *attackFrame3 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"hero_attack_02_02.png"];
    
    if (newFrame == attackFrame || newFrame == attackFrame2)
    {
        if ([self.delegate actionSpriteDidAttack:self])
        {
            _chainTimer = 0.3;
            
            //add this if statement
            if (_weapon)
            {
                [_weapon used];
            }
        }
    }
    else if (newFrame == attackFrame3)
    {
        //replace the contents of this else if statement
        if ([self.delegate actionSpriteDidAttack:self])
        {
            if (_weapon)
            {
                [_weapon used];
            }
        }
    }
    else if (newFrame == runAttackFrame || newFrame == runAttackFrame2 || newFrame == jumpAttackFrame)
    {
        [self.delegate actionSpriteDidAttack:self];
    }
}

//add this method
-(void)weaponDidReachLimit:(Weapon *)weapon
{
    [self dropWeapon];
}

-(void)hurtWithDamage:(float)damage force:(float)force direction:(CGPoint)direction
{    
    [super hurtWithDamage:damage force:force direction:direction];
    
    if (_weapon)
    {
        [self dropWeapon];
    }
    
    if (self.actionState == kActionStateHurt)
    {
        _hurtTolerance -= damage;
        if (_hurtTolerance <= 0)
        {
            [self knockoutWithDamage:0 direction:direction];
        }
    }
}

-(void)knockoutWithDamage:(float)damage direction:(CGPoint)direction
{
    [super knockoutWithDamage:damage direction:direction];
    
    if (_weapon)
    {
        [self dropWeapon];
    }
    
    if (self.actionState == kActionStateKnockedOut)
    {
        _hurtTolerance = _hurtLimit;
        if (self.hitPoints <= 0)
        {
            [[SimpleAudioEngine sharedEngine] playEffect:@"herodeath.caf"];
        }
    }
}

-(void)update:(ccTime)delta
{
    [super update:delta];
    
    if (_chainTimer > 0)
    {
        _chainTimer -= delta;
        
        if (_chainTimer <= 0)
        {
            _chainTimer = 0;
        }
    }

    if (_hurtTolerance < _hurtLimit)
    {
        _hurtTolerance += _hurtLimit * delta / _recoveryRate;
        
        if (_hurtTolerance >= _hurtLimit)
        {
            _hurtTolerance = _hurtLimit;
        }
    }
}

-(void)attack
{
    if (self.actionState == kActionStateAttack && _chainTimer > 0)
    {
        NSLog(@"Attack 2");
        _chainTimer = 0;
        [self stopAllActions];
        [self runAction:_attackTwoAction];
        self.actionState = kActionStateAttackTwo;
        [self setContactPointsForAction:self.actionState];
        _actionDelay = _attackTwoDelayTime;
    }
    else if (self.actionState == kActionStateAttackTwo && _chainTimer > 0)
    {
        NSLog(@"Attack 3");
        _chainTimer = 0;
        [self stopAllActions];
        [self runAction:_attackThreeAction];
        self.actionState = kActionStateAttackThree;
        [self setContactPointsForAction:self.actionState];
        _actionDelay = _attackThreeDelayTime;
    }
    else
    {
        NSLog(@"Attack: %0.2f", _chainTimer);
        [super attack];
    }
}

-(void)cleanup
{
    self.attackTwoAction = nil;
    self.attackThreeAction = nil;
    
    [super cleanup];
}

-(BOOL)pickUpWeapon:(Weapon *)weapon
{
    if (self.actionState == kActionStateIdle)
    {
        [self stopAllActions];
        [weapon pickedUp];
        [self setLandingDisplayFrame];
        [self performSelector:@selector(setWeapon:) withObject:weapon afterDelay:1.0/12.0];
        return YES;
    }
    return NO;
}

-(void)dropWeapon
{
    Weapon *weapon = _weapon;
    self.weapon = nil;
    [weapon droppedFrom:(self.groundPosition.y - self.shadow.position.y) to:self.shadow.position];

}

-(void)removeAllAnimationMembers
{
    [_attackGroup.members removeAllObjects];
    [_attackTwoGroup.members removeAllObjects];
    [_attackThreeGroup.members removeAllObjects];
    [_idleGroup.members removeAllObjects];
    [_walkGroup.members removeAllObjects];
}

-(void)setWeapon:(Weapon *)weapon
{
    [self stopAllActions];

    // 1
    if (_weapon)
    {
        [self removeAllAnimationMembers];
    }
    
    _weapon = weapon;
    
    if (_weapon)
    {
        _weapon.delegate = self;
        _weapon.scaleX = self.scaleX;
        [_attackGroup.members addObject:_weapon.attack];
        [_attackTwoGroup.members addObject:_weapon.attackTwo];
        [_attackThreeGroup.members addObject:_weapon.attackThree];
        [_idleGroup.members addObject:_weapon.idle];
        [_walkGroup.members addObject:_weapon.walk];
    }
    
    
    [self runAction:self.idleAction];
    self.velocity = CGPointZero;
    self.actionState = kActionStateIdle;
    _actionDelay = 0.0;
}

-(void)setPosition:(CGPoint)position
{
    [super setPosition:position];
    
    if (_weapon)
    {
        _weapon.position = position;
    }
}

-(void)setScaleX:(float)scaleX
{
    [super setScaleX:scaleX];
    
    if (_weapon)
    {
        _weapon.scaleX = scaleX;
    }
}

-(void)setScaleY:(float)scaleY
{
    [super setScaleY:scaleY];
    
    if (_weapon)
    {
        _weapon.scaleY = scaleY;
    }
}

-(void)setScale:(float)scale
{
    [super setScale:scale];
    
    if (_weapon)
    {
        _weapon.scale = scale;
    }
}

-(float)attackDamage
{
    if (_weapon)
    {
        return [super attackDamage] + _weapon.damageBonus;
    }
    
    return [super attackDamage];
}

-(float)attackTwoDamage
{
    if (_weapon)
    {
        return _attackTwoDamage + _weapon.damageBonus;
    }
    
    return _attackTwoDamage;
}

-(float)attackThreeDamage
{
    if (_weapon)
    {
        return _attackThreeDamage + _weapon.damageBonus;
    }
    
    return _attackThreeDamage;
}

@end
