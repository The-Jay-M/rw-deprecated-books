//
//  Robot.m
//  PompaDroid
//
//  Created by Ray Wenderlich on 2/12/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import "Robot.h"
#import "AnimateGroup.h"
#import "SimpleAudioEngine.h"

@implementation Robot

-(id)init
{
    if ((self = [super initWithSpriteFrameName:@"robot_base_idle_00.png"]))
    {
        self.belt = [CCSprite spriteWithSpriteFrameName:@"robot_belt_idle_00.png"];
        self.smoke = [CCSprite spriteWithSpriteFrameName:@"robot_smoke_idle_00.png"];
        
        self.shadow = [CCSprite spriteWithSpriteFrameName:@"shadow_character.png"];
        self.shadow.opacity = 190;
        
        AnimateGroup *idleAnimationGroup = [self animateGroupWithActionWord:@"idle" frameCount:5 delay:1.0/12.0];
        self.idleAction = [CCRepeatForever actionWithAction:idleAnimationGroup];

        AnimateGroup *attackAnimationGroup = [self animateGroupWithActionWord:@"attack" frameCount:5 delay:1.0/15.0];
        self.attackAction = [CCSequence actions:attackAnimationGroup, [CCCallFunc actionWithTarget:self selector:@selector(idle)], nil];

        AnimateGroup *walkAnimationGroup = [self animateGroupWithActionWord:@"walk" frameCount:6 delay:1.0/12.0];
        self.walkAction = [CCRepeatForever actionWithAction:walkAnimationGroup];
        
        //hurt animation
        AnimateGroup *hurtAnimationGroup = [self animateGroupWithActionWord:@"hurt" frameCount:3 delay:1.0/12.0];
        self.hurtAction = [CCSequence actions:hurtAnimationGroup, [CCCallFunc actionWithTarget:self selector:@selector(idle)], nil];

        //knocked out animation
        self.knockedOutAction = [self animateGroupWithActionWord:@"knockout" frameCount:5 delay:1.0/12.0];

        //die action
        self.dieAction = [CCBlink actionWithDuration:2.0 blinks:10.0];

        //recover animation
        self.recoverAction = [CCSequence actions:[self animateGroupWithActionWord:@"getup" frameCount:6 delay:1.0/12.0], [CCCallFunc actionWithTarget:self selector:@selector(idle)], nil];
        
        self.walkSpeed = 80 * kPointFactor;
        self.runSpeed = 160 * kPointFactor;
        self.directionX = 1.0;
        self.centerToBottom = 39.0 * kPointFactor;
        self.centerToSides = 29.0 * kPointFactor;
        
        self.detectionRadius = 50.0 * kPointFactor;
        self.contactPointCount = 4;
        self.contactPoints = malloc(sizeof(ContactPoint) * self.contactPointCount);
        self.attackPointCount = 1;
        self.attackPoints = malloc(sizeof(ContactPoint) * self.attackPointCount);

        self.maxHitPoints = 100.0;
        self.hitPoints = self.maxHitPoints;
        self.attackDamage = 4;
        self.attackForce = 2.0 * kPointFactor;
        
        [self modifyAttackPointAtIndex:0 offset:ccp(45.0, 6.5) radius:10.0];
        
    }
    return self;
}

-(void)setPosition:(CGPoint)position
{
    [super setPosition:position];
    _belt.position = position;
    _smoke.position = position;
}

-(void)setScaleX:(float)scaleX
{
    [super setScaleX:scaleX];
    _belt.scaleX = scaleX;
    _smoke.scaleX = scaleX;
}

-(void)setScaleY:(float)scaleY
{
    [super setScaleY:scaleY];
    _belt.scaleY = scaleY;
    _smoke.scaleY = scaleY;
}

-(void)setScale:(float)scale
{
    [super setScale:scale];
    _belt.scale = scale;
    _smoke.scale = scale;
}

-(void)setVisible:(BOOL)visible
{
    [super setVisible:visible];
    _belt.visible = visible;
    _smoke.visible = visible;
}

-(void)setColorSet:(ColorSet)colorSet
{
    _colorSet = colorSet;
    if (colorSet == kColorLess)
    {
        self.color = ccWHITE;
        _belt.color = ccWHITE;
        _smoke.color = ccWHITE;
        self.maxHitPoints = 50.0;
        self.attackDamage = 2;
    }
    if (colorSet == kColorCopper)
    {
        self.color = ccc3(255, 193, 158);
        _belt.color = ccc3(99, 162, 255);
        _smoke.color = ccc3(220, 219, 182);
        self.maxHitPoints = 100.0;
        self.attackDamage = 4;
    }
    else if (colorSet == kColorSilver)
    {
        self.color = ccWHITE;
        _belt.color = ccc3(99, 255, 128);
        _smoke.color = ccc3(128, 128, 128);
        self.maxHitPoints = 125.0;
        self.attackDamage = 5;
    }
    else if (colorSet == kColorGold)
    {
        self.color = ccc3(233, 177, 0);
        _belt.color = ccc3(109, 40, 25);
        _smoke.color = ccc3(222, 129, 82);
        self.maxHitPoints = 150.0;
        self.attackDamage = 6;
    }
    else if (colorSet == kColorRandom)
    {
        self.color = ccc3(random_range(0, 255), random_range(0, 255), random_range(0, 255));
        _belt.color = ccc3(random_range(0, 255), random_range(0, 255), random_range(0, 255));
        _smoke.color = ccc3(random_range(0, 255), random_range(0, 255), random_range(0, 255));
        self.maxHitPoints = random_range(100, 250);
        self.attackDamage = random_range(4, 10);
    }    
    self.hitPoints = self.maxHitPoints;
}

-(AnimateGroup *)animateGroupWithActionWord:(NSString *)actionKeyWord frameCount:(NSUInteger)frameCount delay:(float)delay
{
    CCAnimation *baseAnimation = [self animationWithPrefix:[NSString stringWithFormat:@"robot_base_%@", actionKeyWord] startFrameIdx:0 frameCount:frameCount delay:delay];
    
    AnimationMember *beltMember = [self animationMemberWithPrefix:[NSString stringWithFormat:@"robot_belt_%@", actionKeyWord] startFrameIdx:0 frameCount:frameCount delay:delay target:_belt];
    
    AnimationMember *smokeMember = [self animationMemberWithPrefix:[NSString stringWithFormat:@"robot_smoke_%@", actionKeyWord] startFrameIdx:0 frameCount:frameCount delay:delay target:_smoke];
    
    CCArray *animationMembers = [CCArray arrayWithNSArray:@[beltMember, smokeMember]];
    
    return [AnimateGroup actionWithAnimation:baseAnimation members:animationMembers];
}

-(void)setContactPointsForAction:(ActionState)actionState
{
    if (actionState == kActionStateIdle)
    {
        [self modifyContactPointAtIndex:0 offset:ccp(1.7, 19.5) radius:20.0];
        [self modifyContactPointAtIndex:1 offset:ccp(-15.5, 3.5) radius:16.0];
        [self modifyContactPointAtIndex:2 offset:ccp(17.0, 2.1) radius:14.0];
        [self modifyContactPointAtIndex:3 offset:ccp(-0.8, -18.5) radius:19.0];
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
        [self modifyAttackPointAtIndex:0 offset:ccp(45.0, 6.5) radius:10.0];
    }
}

-(void)setDisplayFrame:(CCSpriteFrame *)newFrame
{
    [super setDisplayFrame:newFrame];
    
    CCSpriteFrame *attackFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"robot_base_attack_03.png"];

    if (newFrame ==  attackFrame)
    {
        [self.delegate actionSpriteDidAttack:self];
    }
}

-(void)reset
{
    [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"robot_base_idle_00.png"]];
    [_belt setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"robot_belt_idle_00.png"]];
    [_smoke setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"robot_smoke_idle_00.png"]];
    [super reset];
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
