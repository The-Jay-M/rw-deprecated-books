//
//  Robot.m
//  PompaDroid
//
//  Created by Allen Tan on 6/11/14.
//
//

#import "Robot.h"
#import "SKTTextureCache.h"
#import "AnimationMember.h"
#import "SKAction+SKTExtras.h"

@implementation Robot

- (instancetype)init
{
    
    SKTTextureCache *cache = [SKTTextureCache sharedInstance];
    NSString *textureName = @"robot_base_idle_00";
    SKTexture *texture = [cache textureNamed:textureName];
    
    self = [super initWithTexture:texture];
    
    if (self) {
        
        SKTexture *beltTeture =
        [cache textureNamed:@"robot_belt_idle_00"];
        self.belt =
        [SKSpriteNode spriteNodeWithTexture:beltTeture];
        
        SKTexture *smokeTexture =
        [cache textureNamed:@"robot_smoke_idle_00"];
        self.smoke =
        [SKSpriteNode spriteNodeWithTexture:smokeTexture];
        
        SKTexture *shadowTexture =
        [cache textureNamed:@"shadow_character"];
        self.shadow =
        [SKSpriteNode spriteNodeWithTexture:shadowTexture];
        
        self.shadow.alpha = 0.75;
        
        //idle animation
        SKAction *idleAnimationGroup =
        [self animateActionForActionWord:@"idle"
                            timePerFrame:1.0/12.0
                              frameCount:5];
        self.idleAction =
        [SKAction repeatActionForever:idleAnimationGroup];
        
        //attack animation
        SKAction *attackAnimationGroup =
        [self animateActionForActionWord:@"attack"
                            timePerFrame:1.0/15.0
                              frameCount:5];
        
        self.attackAction =
        [SKAction sequence:@[attackAnimationGroup, [SKAction performSelector:@selector(idle) onTarget:self]]];
        
        //walk animation
        SKAction *walkAnimationGroup =
        [self animateActionForActionWord:@"walk"
                            timePerFrame:1.0/12.0
                              frameCount:6];
        
        self.walkAction =
        [SKAction repeatActionForever:walkAnimationGroup];
        
        //hurt animation
        SKAction *hurtAnimationGroup = [self animateActionForActionWord:@"hurt" timePerFrame:1.0/12.0 frameCount:3];
        self.hurtAction = [SKAction sequence:@[hurtAnimationGroup, [SKAction performSelector:@selector(idle) onTarget:self]]];
        
        //knocked out animation
        self.knockedOutAction = [self animateActionForActionWord:@"knockout" timePerFrame:1.0/12.0 frameCount:5];
        
        //die action
        self.dieAction = [SKAction blinkWithDuration:2.0 blinks:10];
        
        //recover animation
        SKAction *recoverAnimationGroup = [self animateActionForActionWord:@"getup" timePerFrame:1.0/12.0 frameCount:6];
        self.recoverAction = [SKAction sequence:@[recoverAnimationGroup, [SKAction performSelector:@selector(idle) onTarget:self]]];
        
        self.walkSpeed = 80 * kPointFactor;
        self.runSpeed = 160 * kPointFactor;
        self.directionX = 1.0;
        self.centerToBottom = 39.0 * kPointFactor;
        self.centerToSides = 29.0 * kPointFactor;
        self.colorBlendFactor = 1.0;
        self.belt.colorBlendFactor = 1.0;
        self.smoke.colorBlendFactor = 1.0;
        
        self.detectionRadius = 50.0 * kPointFactor;
        
        self.contactPoints = [self contactPointArray:4];
        self.attackPoints = [self contactPointArray:1];
        
        [self modifyAttackPointAtIndex:0
                                offset:CGPointMake(45.0, 6.5)
                                radius:10.0];
        
        self.maxHitPoints = 100.0;
        self.hitPoints = self.maxHitPoints;
        self.attackDamage = 4;
        self.attackForce = 2.0 * kPointFactor;
    }
    return self;
}

- (void)setPosition:(CGPoint)position
{
    [super setPosition:position];
    self.belt.position = position;
    self.smoke.position = position;
}

- (void)setXScale:(CGFloat)xScale
{
    [super setXScale:xScale];
    self.belt.xScale = xScale;
    self.smoke.xScale = xScale;
}

- (void)setYScale:(CGFloat)yScale
{
    [super setYScale:yScale];
    self.belt.yScale = yScale;
    self.smoke.yScale = yScale;
}

- (void)setScale:(CGFloat)scale
{
    [super setScale:scale];
    self.belt.scale = scale;
    self.smoke.scale = scale;
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    self.belt.hidden = hidden;
    self.smoke.hidden = hidden;
}

- (void)setZPosition:(CGFloat)zPosition
{
    [super setZPosition:zPosition];
    self.smoke.zPosition = zPosition;
    self.belt.zPosition = zPosition;
}
- (SKAction *)animateActionForActionWord:(NSString *)actionKeyWord timePerFrame:(NSTimeInterval)timeInterval frameCount:(NSUInteger)frameCount
{
    AnimationMember *baseAnimation = [AnimationMember animationWithTextures:[self texturesWithPrefix:[NSString stringWithFormat:@"robot_base_%@", actionKeyWord] startFrameIdx:0 frameCount:frameCount] target:self];
    
    AnimationMember *beltAnimation = [AnimationMember animationWithTextures:[self texturesWithPrefix:[NSString stringWithFormat:@"robot_belt_%@", actionKeyWord] startFrameIdx:0 frameCount:frameCount] target:_belt];
    
    AnimationMember *smokeAnimation = [AnimationMember animationWithTextures:[self texturesWithPrefix:[NSString stringWithFormat:@"robot_smoke_%@", actionKeyWord] startFrameIdx:0 frameCount:frameCount] target:_smoke];
    
    NSMutableArray *actionGroup = [@[baseAnimation, beltAnimation, smokeAnimation] mutableCopy];
    
    return [self animateActionForGroup:actionGroup
                          timePerFrame:timeInterval
                            frameCount:frameCount];
}
- (void)setColorSet:(ColorSet)colorSet
{
    _colorSet = colorSet;
    
    if (colorSet == kColorLess) {
        
        self.color = [UIColor whiteColor];
        self.belt.color = [UIColor whiteColor];
        self.smoke.color = [UIColor whiteColor];
        self.maxHitPoints = 50.0;
        self.attackDamage = 2;
        
    } else if (colorSet == kColorCopper) {
        
        self.color = [UIColor colorWithRed:255/255.0
                                     green:193/255.0
                                      blue:158/255.0
                                     alpha:1.0];
        
        self.belt.color = [UIColor colorWithRed:99/255.0
                                          green:162/255.0
                                           blue:1.0
                                          alpha:1.0];
        
        self.smoke.color = [UIColor colorWithRed:220/255.0
                                           green:219/255.0
                                            blue:182/255.0
                                           alpha:1.0];
        self.maxHitPoints = 100.0;
        self.attackDamage = 4;
        
    } else if (colorSet == kColorSilver) {
        
        self.color = [UIColor whiteColor];
        
        self.belt.color = [UIColor colorWithRed:99/255.0
                                          green:1.0
                                           blue:128/255.0
                                          alpha:1.0];
        
        self.smoke.color = [UIColor colorWithRed:128/255.0
                                           green:128/255.0
                                            blue:128/255.0
                                           alpha:1.0];
        self.maxHitPoints = 125.0;
        self.attackDamage = 5;
        
    } else if (colorSet == kColorGold) {
        
        self.color = [UIColor colorWithRed:233/255.0
                                     green:177/255.0
                                      blue:0
                                     alpha:1.0];
        
        self.belt.color = [UIColor colorWithRed:109/255.0
                                          green:40/255.0
                                           blue:25/255.0
                                          alpha:1.0];
        
        self.smoke.color = [UIColor colorWithRed:222/255.0
                                           green:129/255.0
                                            blue:82/255.0
                                           alpha:1.0];
        self.maxHitPoints = 150.0;
        self.attackDamage = 6;
        
    } else if (colorSet == kColorRandom) {
        
        self.color =
        [UIColor colorWithRed:RandomFloatRange(0, 1)
                        green:RandomFloatRange(0, 1)
                         blue:RandomFloatRange(0, 1)
                        alpha:1.0];
        
        self.belt.color =
        [UIColor colorWithRed:RandomFloatRange(0, 1)
                        green:RandomFloatRange(0, 1)
                         blue:RandomFloatRange(0, 1)
                        alpha:1.0];
        
        self.smoke.color =
        [UIColor colorWithRed:RandomFloatRange(0, 1)
                        green:RandomFloatRange(0, 1)
                         blue:RandomFloatRange(0, 1)
                        alpha:1.0];
        self.maxHitPoints = RandomIntRange(100, 250);
        self.attackDamage = RandomIntRange(4, 10);
    }
    
    self.hitPoints = self.maxHitPoints;
}

- (void)setContactPointsForAction:(ActionState)actionState
{
    if (actionState == kActionStateIdle) {
        
        [self modifyContactPointAtIndex:0
                                 offset:CGPointMake(1.7, 19.5)
                                 radius:20.0];
        
        [self modifyContactPointAtIndex:1
                                 offset:CGPointMake(-15.5, 3.5)
                                 radius:16.0];
        
        [self modifyContactPointAtIndex:2
                                 offset:CGPointMake(17.0, 2.1)
                                 radius:14.0];
        
        [self modifyContactPointAtIndex:3
                                 offset:CGPointMake(-0.8, -18.5)
                                 radius:19.0];
        
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
                                offset:CGPointMake(45.0, 6.5)
                                radius:10.0];
    }
}

- (void)setTexture:(SKTexture *)texture
{
    [super setTexture:texture];
    
    SKTexture *attackTexture =
    [[SKTTextureCache sharedInstance]
     textureNamed:@"robot_base_attack_03"];
    
    if (texture == attackTexture) {
        [self.delegate actionSpriteDidAttack:self];
    }
}

- (void)reset
{
    [self setTexture:[[SKTTextureCache sharedInstance] textureNamed:@"robot_base_idle_00"]];
    
    [self.belt setTexture:[[SKTTextureCache sharedInstance] textureNamed:@"robot_belt_idle_00"]];
    
    [self.smoke setTexture:[[SKTTextureCache sharedInstance] textureNamed:@"robot_smoke_idle_00"]];
    
    [super reset];
}

- (void)knockoutWithDamage:(CGFloat)damage
                 direction:(CGPoint)direction
{
    [super knockoutWithDamage:damage direction:direction];
    
    if (self.actionState == kActionStateKnockedOut &&
        self.hitPoints <= 0) {
        
        [self runAction:[SKAction playSoundFileNamed:@"enemydeath.caf" waitForCompletion:NO]];
        
    }
}

@end
