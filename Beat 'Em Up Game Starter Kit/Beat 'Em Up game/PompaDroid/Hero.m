//
//  Hero.m
//  PompaDroid
//
//  Created by Allen Tan on 6/11/14.
//
//

#import "Hero.h"
#import "SKTTextureCache.h"
#import "SKAction+SKTExtras.h"

@interface Hero()

@property (assign, nonatomic) CGFloat hurtTolerance;
@property (assign, nonatomic) CGFloat recoveryRate;
@property (assign, nonatomic) CGFloat hurtLimit;
@property (assign, nonatomic) CGFloat attackTwoDelayTime;
@property (assign, nonatomic) CGFloat attackThreeDelayTime;
@property (assign, nonatomic) CGFloat chainTimer;
@property (strong, nonatomic) NSMutableArray *attackGroup;
@property (strong, nonatomic) NSMutableArray *attackTwoGroup;
@property (strong, nonatomic) NSMutableArray *attackThreeGroup;
@property (strong, nonatomic) NSMutableArray *idleGroup;
@property (strong, nonatomic) NSMutableArray *walkGroup;

@end

@implementation Hero

- (instancetype)init
{
    SKTTextureCache *cache = [SKTTextureCache sharedInstance];
    SKTexture *texture = [cache textureNamed:@"hero_idle_00"];
    
    self = [super initWithTexture:texture];
    
    if (self)
    {
        _idleGroup = [NSMutableArray arrayWithCapacity:2];
        AnimationMember *idleMember = [AnimationMember animationWithTextures:[self texturesWithPrefix:@"hero_idle" startFrameIdx:0 frameCount:6] target:self];
        
        [_idleGroup addObject:idleMember];
        
        SKAction *idleAnimation = [self animateActionForGroup:_idleGroup timePerFrame:1.0/12.0 frameCount:6];
        
        self.idleAction =
        [SKAction repeatActionForever:idleAnimation];
        
        _walkGroup = [NSMutableArray arrayWithCapacity:2];
        AnimationMember *walkMember = [AnimationMember animationWithTextures:[self texturesWithPrefix:@"hero_walk" startFrameIdx:0 frameCount:8] target:self];
        
        [_walkGroup addObject:walkMember];
        
        SKAction *walkAnimation = [self animateActionForGroup:_walkGroup timePerFrame:1.0/12.0 frameCount:8];
        
        self.walkAction =
        [SKAction repeatActionForever:walkAnimation];
        
        self.walkSpeed = 80 * kPointFactor;
        self.directionX = 1.0;
        
        self.centerToBottom = 39.0 * kPointFactor;
        self.centerToSides = 29.0 * kPointFactor;
        
        NSArray * textures = [self texturesWithPrefix:@"hero_run"
                                        startFrameIdx:0 frameCount:8];

        SKAction *runAnimation =
        [SKAction animateWithTextures:textures timePerFrame:1.0/12.0];
        
        self.runAction = [SKAction repeatActionForever:runAnimation];
        
        self.runSpeed = 160 * kPointFactor;
        
        _attackGroup = [NSMutableArray arrayWithCapacity:2];
        AnimationMember *attackMember = [AnimationMember animationWithTextures:[self texturesWithPrefix:@"hero_attack_00" startFrameIdx:0 frameCount:3] target:self];
        
        [_attackGroup addObject:attackMember];
        
        SKAction *attackAnimation = [self animateActionForGroup:_attackGroup timePerFrame:1.0/15.0 frameCount:3];
        
        self.attackAction =
        [SKAction sequence:@[attackAnimation, [SKAction performSelector:@selector(idle) onTarget:self]]];
        
        self.shadow = [SKSpriteNode spriteNodeWithTexture:[[SKTTextureCache sharedInstance] textureNamed:@"shadow_character"]];
        self.shadow.alpha = 0.75;
        
        //jump animation
        NSArray *jumpRiseFrames = @[[[SKTTextureCache sharedInstance] textureNamed:@"hero_jump_05"], [[SKTTextureCache sharedInstance]  textureNamed:@"hero_jump_00"]];
        self.jumpRiseAction = [SKAction animateWithTextures:jumpRiseFrames timePerFrame:1.0/12.0];
        
        //fall animation
        self.jumpFallAction = [SKAction animateWithTextures:[self texturesWithPrefix:@"hero_jump" startFrameIdx:1 frameCount:4] timePerFrame:1.0/12.0];
        
        //land animation
        self.jumpLandAction = [SKAction sequence:@[[SKAction setTexture:[[SKTTextureCache sharedInstance] textureNamed:@"hero_jump_05"]], [SKAction waitForDuration:1.0/12.0], [SKAction performSelector:@selector(idle) onTarget:self]]];
        
        //hurt animation
        self.hurtAction = [SKAction sequence:@[[SKAction animateWithTextures:[self texturesWithPrefix:@"hero_hurt" startFrameIdx:0 frameCount:3] timePerFrame:1.0/12.0], [SKAction performSelector:@selector(idle) onTarget:self]]];
        
        //knocked out animation
        self.knockedOutAction = [SKAction animateWithTextures:[self texturesWithPrefix:@"hero_knockout" startFrameIdx:0 frameCount:5] timePerFrame:1.0/12.0];
        self.detectionRadius = 100.0 * kPointFactor;
        
        //die action
        self.dieAction = [SKAction blinkWithDuration:2.0 blinks:10.0];
        
        //recover animation
        self.recoverAction = [SKAction sequence:@[[SKAction animateWithTextures:[self texturesWithPrefix:@"hero_getup" startFrameIdx:0 frameCount:6] timePerFrame:1.0/12.0], [SKAction performSelector:@selector(jumpLand) onTarget:self]]];
        
        //jump attack action
        SKAction *jumpAttackAnimation = [self animateActionForTextures:[self texturesWithPrefix:@"hero_jumpattack" startFrameIdx:0 frameCount:5] timePerFrame:1.0/10.0];
        self.jumpAttackAction = [SKAction sequence:@[jumpAttackAnimation, [SKAction performSelector:@selector(jumpFall) onTarget:self]]];
        
        //run attack action
        SKAction *runAttackAnimation = [self animateActionForTextures:[self texturesWithPrefix:@"hero_runattack" startFrameIdx:0 frameCount:6] timePerFrame:1.0/10.0];
        self.runAttackAction = [SKAction sequence:@[runAttackAnimation, [SKAction performSelector:@selector(idle) onTarget:self]]];
        
        //attack two action
        _attackTwoGroup = [NSMutableArray arrayWithCapacity:2];
        AnimationMember *attackTwoMember = [AnimationMember animationWithTextures:[self texturesWithPrefix:@"hero_attack_01" startFrameIdx:0 frameCount:3] target:self];
        
        [_attackTwoGroup addObject:attackTwoMember];
        
        SKAction *attackTwoAnimation = [self animateActionForGroup:_attackTwoGroup timePerFrame:1.0/12.0 frameCount:3];
        self.attackTwoAction = [SKAction sequence:@[attackTwoAnimation, [SKAction performSelector:@selector(idle) onTarget:self]]];
        
        //attack three action
        _attackThreeGroup = [NSMutableArray arrayWithCapacity:2];
        AnimationMember *attackThreeMember = [AnimationMember animationWithTextures:[self texturesWithPrefix:@"hero_attack_02" startFrameIdx:0 frameCount:5] target:self];
        
        [_attackThreeGroup addObject:attackThreeMember];
        
        SKAction *attackThreeAnimation = [self animateActionForGroup:_attackThreeGroup timePerFrame:1.0/10.0 frameCount:5];
        self.attackThreeAction = [SKAction sequence:@[attackThreeAnimation, [SKAction performSelector:@selector(idle) onTarget:self]]];
        
        //add these attributes to init along with the other attributes
        self.jumpAttackDamage = 15.0;
        self.runAttackDamage = 15.0;
        
        self.attackPoints = [self contactPointArray:3];
        self.contactPoints = [self contactPointArray:4];
        
        self.maxHitPoints = 200.0;
        self.hitPoints = self.maxHitPoints;
        self.attackDamage = 5.0;
        self.attackForce = 4.0 * kPointFactor;
        self.attackDelayTime = 0.14;
        
        _recoveryRate = 5.0;
        _hurtLimit = 20.0;
        _hurtTolerance = _hurtLimit;
        
        _attackTwoDelayTime = 0.14;
        _attackThreeDelayTime = 0.45;
        _chainTimer = 0;
        _attackTwoDamage = 10.0;
        _attackThreeDamage = 20.0;

    }
    
    return self;
}

- (void)hurtWithDamage:(CGFloat)damage
                 force:(CGFloat)force
             direction:(CGPoint)direction
{
    [super hurtWithDamage:damage force:force direction:direction];
    
    if (self.weapon) {
        [self dropWeapon];
    }
    
    if (self.actionState == kActionStateHurt) {
        
        self.hurtTolerance -= damage;
        
        if (self.hurtTolerance <= 0) {
            [self knockoutWithDamage:0 direction:direction];
        }
    }
}

- (void)knockoutWithDamage:(CGFloat)damage
                 direction:(CGPoint)direction
{
    [super knockoutWithDamage:damage direction:direction];
    
    if (self.weapon) {
        [self dropWeapon];
    }
    
    if (self.actionState == kActionStateKnockedOut) {
        self.hurtTolerance = self.hurtLimit;
        if (self.hitPoints <= 0) {
            [self runAction:[SKAction playSoundFileNamed:@"herodeath.caf"
                                       waitForCompletion:NO]];
        }
    }
}

- (void)update:(NSTimeInterval)delta
{
    [super update:delta];
    
    if (self.chainTimer > 0) {
        
        self.chainTimer -= delta;
        
        if (self.chainTimer <= 0) {
            self.chainTimer = 0;
        }
    }
    
    if (self.hurtTolerance < self.hurtLimit) {
        
        self.hurtTolerance +=
        self.hurtLimit * delta / self.recoveryRate;
        
        if (self.hurtTolerance >= self.hurtLimit) {
            self.hurtTolerance = self.hurtLimit;
        }
    }
}

- (void)setContactPointsForAction:(ActionState)actionState
{
    if (actionState == kActionStateIdle) {
        
        [self modifyContactPointAtIndex:0
                                 offset:CGPointMake(3.0, 23.0)
                                 radius:19.0];
        
        [self modifyContactPointAtIndex:1
                                 offset:CGPointMake(17.0, 10.0)
                                 radius:10.0];
        
        [self modifyContactPointAtIndex:2
                                 offset:CGPointZero
                                 radius:19.0];
        
        [self modifyContactPointAtIndex:3
                                 offset:CGPointMake(0.0, -21.0)
                                 radius:20.0];
        
    } else if (actionState == kActionStateWalk) {
        
        [self modifyContactPointAtIndex:0
                                 offset:CGPointMake(8.0, 23.0)
                                 radius:19.0];
        
        [self modifyContactPointAtIndex:1
                                 offset:CGPointMake(12.0, 4.0)
                                 radius:4.0];
        
        [self modifyContactPointAtIndex:2
                                 offset:CGPointZero
                                 radius:10.0];
        
        [self modifyContactPointAtIndex:3
                                 offset:CGPointMake(0.0, -21.0)
                                 radius:20.0];
        
    } else if (actionState == kActionStateAttack) {
        
        [self modifyContactPointAtIndex:0
                                 offset:CGPointMake(15.0, 23.0)
                                 radius:19.0];
        
        [self modifyContactPointAtIndex:1
                                 offset:CGPointMake(24.5, 4.0)
                                 radius:6.0];
        
        [self modifyContactPointAtIndex:2
                                 offset:CGPointZero
                                 radius:16.0];
        
        [self modifyContactPointAtIndex:3
                                 offset:CGPointMake(0.0, -21.0)
                                 radius:20.0];
        
        [self modifyAttackPointAtIndex:0
                                offset:CGPointMake(41.0, 3.0)
                                radius:10.0];
        
        [self modifyAttackPointAtIndex:1
                                offset:CGPointMake(41.0, 3.0)
                                radius:10.0];
        
        [self modifyAttackPointAtIndex:2
                                offset:CGPointMake(41.0, 3.0)
                                radius:10.0];
        
    } else if (actionState == kActionStateAttackTwo) {
        
        [self modifyAttackPointAtIndex:0
                                offset:CGPointMake(51.6, 2.4)
                                radius:13.0];
        
        [self modifyAttackPointAtIndex:1
                                offset:CGPointMake(51.6, 2.4)
                                radius:13.0];
        
        [self modifyAttackPointAtIndex:2
                                offset:CGPointMake(51.6, 2.4)
                                radius:13.0];
        
    } else if (actionState == kActionStateAttackThree) {
        
        [self modifyAttackPointAtIndex:0
                                offset:CGPointMake(61.8, 6.2)
                                radius:22.0];
        
        [self modifyAttackPointAtIndex:1
                                offset:CGPointMake(61.8, 6.2)
                                radius:22.0];
        
        [self modifyAttackPointAtIndex:2
                                offset:CGPointMake(61.8, 6.2)
                                radius:22.0];
        
    } else if (actionState == kActionStateRunAttack) {
        
        [self modifyAttackPointAtIndex:0
                                offset:CGPointMake(31.2, -8.8)
                                radius:10.0];
        
        [self modifyAttackPointAtIndex:1
                                offset:CGPointMake(31.2, -8.8)
                                radius:10.0];
        
        [self modifyAttackPointAtIndex:2
                                offset:CGPointMake(31.2, -8.8)
                                radius:10.0];
        
    } else if (actionState == kActionStateJumpAttack) {
        
        [self modifyAttackPointAtIndex:2
                                offset:CGPointMake(70.0, -55.0)
                                radius:8.0];
        
        [self modifyAttackPointAtIndex:1
                                offset:CGPointMake(55.0, -42.0)
                                radius:12.0];
        
        [self modifyAttackPointAtIndex:0
                                offset:CGPointMake(34.0, -25.0)
                                radius:17.0];
    }
}

- (void)setTexture:(SKTexture *)texture
{
    [super setTexture:texture];
    
    SKTexture *attackTexture =
    [[SKTTextureCache sharedInstance]
     textureNamed:@"hero_attack_00_01"];
    
    SKTexture *runAttackTexture =
    [[SKTTextureCache sharedInstance]
     textureNamed:@"hero_runattack_02"];
    
    SKTexture *runAttackTexture2 =
    [[SKTTextureCache sharedInstance]
     textureNamed:@"hero_runattack_03"];
    
    SKTexture *jumpAttackTexture =
    [[SKTTextureCache sharedInstance]
     textureNamed:@"hero_jumpattack_02"];
    
    //add these new textures
    SKTexture *attackTexture2 =
    [[SKTTextureCache sharedInstance]
     textureNamed:@"hero_attack_01_01"];
    
    SKTexture *attackTexture3 =
    [[SKTTextureCache sharedInstance]
     textureNamed:@"hero_attack_02_02"];
    
    if (texture == attackTexture || texture == attackTexture2) {
        
        if ([self.delegate actionSpriteDidAttack:self]) {
            self.chainTimer = 0.3;
            
            //add this if statement
            if (self.weapon) {
                [self.weapon used];
            }
        }
        
    } else if (texture == attackTexture3) {
        
        //replace the contents of this else if statement
        if ([self.delegate actionSpriteDidAttack:self]) {
            if (self.weapon) {
                [self.weapon used];
            }
        }
        
    } else if (texture == runAttackTexture ||
               texture == runAttackTexture2 ||
               texture == jumpAttackTexture) {
        
        [self.delegate actionSpriteDidAttack:self];
        
    }
}

- (void)weaponDidReachLimit:(Weapon *)weapon
{
    [self dropWeapon];
}

- (void)attack
{
    if (self.actionState == kActionStateAttack &&
        self.actionDelay <= 0 &&
        self.chainTimer > 0) {
        
        self.chainTimer = 0;
        [self removeAllActions];
        [self runAction:self.attackTwoAction];
        self.actionState = kActionStateAttackTwo;
        self.actionDelay = self.attackTwoDelayTime;
        
    } else if (self.actionState == kActionStateAttackTwo &&
               self.actionDelay <= 0 && self.chainTimer > 0) {
        
        self.chainTimer = 0;
        [self removeAllActions];
        [self runAction:self.attackThreeAction];
        self.actionState = kActionStateAttackThree;
        self.actionDelay = self.attackThreeDelayTime;
        
    } else {
        
        [super attack];
    }
}

- (void)cleanup
{
    self.attackTwoAction = nil;
    self.attackThreeAction = nil;
    
    [super cleanup];
}

- (BOOL)pickUpWeapon:(Weapon *)weapon
{
    if (self.actionState == kActionStateIdle) {
        
        [self removeAllActions];
        [weapon pickedUp];
        [self setTexture:[[SKTTextureCache sharedInstance]
                          textureNamed:@"hero_jump_05"]];
        
        [self performSelector:@selector(setWeapon:)
                   withObject:weapon
                   afterDelay:1.0/12.0];
        
        return YES;
    }
    return NO;
}

- (void)dropWeapon
{
    Weapon *weapon = _weapon;
    self.weapon = nil;
    [weapon droppedFrom:(self.groundPosition.y - self.shadow.position.y) to:self.shadow.position];
}

- (void)removeWeaponAnimationMembers
{
    [_attackGroup removeObject:_weapon.attack];
    [_attackTwoGroup removeObject:_weapon.attackTwo];
    [_attackThreeGroup removeObject:_weapon.attackThree];
    [_idleGroup removeObject:_weapon.idle];
    [_walkGroup removeObject:_weapon.walk];
}

-(void)setWeapon:(Weapon *)weapon
{
    if (_weapon)
    {
        [self removeWeaponAnimationMembers];
    }
    
    _weapon = weapon;
    
    if (_weapon)
    {
        _weapon.delegate = self;
        _weapon.xScale = self.xScale;
        [_attackGroup addObject:_weapon.attack];
        [_attackTwoGroup addObject:_weapon.attackTwo];
        [_attackThreeGroup addObject:_weapon.attackThree];
        [_idleGroup addObject:_weapon.idle];
        [_walkGroup addObject:_weapon.walk];
    }
    
    self.velocity = CGPointZero;
    self.actionDelay = 0.0;
    
    if (self.actionState == kActionStateIdle)
        [self runAction:self.idleAction];
}

- (void)setPosition:(CGPoint)position
{
    [super setPosition:position];
    
    if (self.weapon) {
        self.weapon.position = position;
    }
}

- (void)setXScale:(CGFloat)xScale
{
    [super setXScale:xScale];
    
    if (self.weapon) {
        self.weapon.xScale = xScale;
    }
}

- (void)setYScale:(CGFloat)yScale
{
    [super setYScale:yScale];
    
    if (self.weapon) {
        self.weapon.yScale = yScale;
    }
}

- (void)setScale:(CGFloat)scale
{
    [super setScale:scale];
    
    if (self.weapon) {
        self.weapon.scale = scale;
    }
}

- (void)setZPosition:(CGFloat)zPosition
{
    [super setZPosition:zPosition];
    
    if (self.weapon) {
        self.weapon.zPosition = zPosition;
    }
}
- (CGFloat)attackDamage
{
    if (self.weapon) {
        return [super attackDamage] + self.weapon.damageBonus;
    }
    
    return [super attackDamage];
}

- (CGFloat)attackTwoDamage
{
    if (self.weapon) {
        return _attackTwoDamage + self.weapon.damageBonus;
    }
    
    return _attackTwoDamage;
}

- (CGFloat)attackThreeDamage
{
    if (self.weapon) {
        return _attackThreeDamage + self.weapon.damageBonus;
    }
    
    return _attackThreeDamage;
}


@end
