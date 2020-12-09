//
//  Boss.m
//  PompaDroid
//
//  Created by Allen Tan on 6/11/14.
//
//

#import "Boss.h"
#import "SKAction+SKTExtras.h"
#import "SKTTextureCache.h"

@implementation Boss

- (instancetype)init
{
    if (self = [super initWithTexture:[[SKTTextureCache sharedInstance] textureNamed:@"boss_idle_00"]])
    {
        self.shadow = [SKSpriteNode spriteNodeWithTexture:[[SKTTextureCache sharedInstance] textureNamed:@"shadow_character"]];
        self.shadow.alpha = 0.75;
        
        //idle animation
        SKAction *idleAnimation = [self animateActionForTextures:[self texturesWithPrefix:@"boss_idle" startFrameIdx:0 frameCount:5] timePerFrame:1.0/10.0];
        self.idleAction = [SKAction repeatActionForever:idleAnimation];
        
        //attack animation
        SKAction *attackAnimation = [self animateActionForTextures:[self texturesWithPrefix:@"boss_attack" startFrameIdx:0 frameCount:5] timePerFrame:1.0/8.0];
        self.attackAction = [SKAction sequence:@[attackAnimation, [SKAction performSelector:@selector(idle) onTarget:self]]];
        
        //walk animation
        SKAction *walkAnimation = [self animateActionForTextures:[self texturesWithPrefix:@"boss_walk" startFrameIdx:0 frameCount:6] timePerFrame:1.0/8.0];
        self.walkAction = [SKAction repeatActionForever:walkAnimation];
        
        //hurt animation
        SKAction *hurtAnimation = [self animateActionForTextures:[self texturesWithPrefix:@"boss_hurt" startFrameIdx:0 frameCount:3] timePerFrame:1.0/12.0];
        self.hurtAction = [SKAction sequence:@[hurtAnimation, [SKAction performSelector:@selector(idle) onTarget:self]]];
        
        //knocked out animation
        self.knockedOutAction = [self animateActionForTextures:[self texturesWithPrefix:@"boss_knockout" startFrameIdx:0 frameCount:4] timePerFrame:1.0/12.0];
        
        //die action
        self.dieAction = [SKAction blinkWithDuration:2.0 blinks:10.0];
        
        //recover animation
        SKAction *recoverAnimation = [self animateActionForTextures:[self texturesWithPrefix:@"boss_getup" startFrameIdx:0 frameCount:6] timePerFrame:1.0/12.0];
        
        self.recoverAction = [SKAction sequence:@[recoverAnimation, [SKAction performSelector:@selector(idle) onTarget:self]]];
        
        self.walkSpeed = 60 * kPointFactor;
        self.runSpeed = 120 * kPointFactor;
        self.directionX = 1.0;
        self.centerToBottom = 39.0 * kPointFactor;
        self.centerToSides = 42.0 * kPointFactor;
        
        self.detectionRadius = 90.0 * kPointFactor;
        
        self.contactPoints = [self contactPointArray:4];
        self.attackPoints = [self contactPointArray:1];
        
        [self modifyAttackPointAtIndex:0
                                offset:CGPointMake(65.0, 42.0)
                                radius:23.7];
        
        self.maxHitPoints = 500.0;
        self.hitPoints = self.maxHitPoints;
        self.attackDamage = 15.0;
        self.attackForce = 2.0 * kPointFactor;
    }
    return self;
}

- (void)setContactPointsForAction:(ActionState)actionState
{
    if (actionState == kActionStateIdle) {
        
        [self modifyContactPointAtIndex:0
                                 offset:CGPointMake(7.0, 36.0)
                                 radius:23.0];
        
        [self modifyContactPointAtIndex:1
                                 offset:CGPointMake(-11.0, 17.0)
                                 radius:23.5];
        
        [self modifyContactPointAtIndex:2
                                 offset:CGPointMake(-2.0, -20.0)
                                 radius:23.0];
        
        [self modifyContactPointAtIndex:3
                                 offset:CGPointMake(24.0, 9.0)
                                 radius:18.0];
        
    } else if (actionState == kActionStateWalk) {
        
        [self modifyContactPointAtIndex:0
                                 offset:CGPointMake(6.0, 41.0)
                                 radius:22.0];
        
        [self modifyContactPointAtIndex:1
                                 offset:CGPointMake(-5.0, 16.0)
                                 radius:26.0];
        
        [self modifyContactPointAtIndex:2
                                 offset:CGPointMake(1.0, -11.0)
                                 radius:17.0];
        
        [self modifyContactPointAtIndex:3
                                 offset:CGPointMake(-13.0, -25.0)
                                 radius:10.0];
        
    } else if (actionState == kActionStateAttack) {
        
        [self modifyContactPointAtIndex:0
                                 offset:CGPointMake(20.0, 38.0)
                                 radius:22.0];
        
        [self modifyContactPointAtIndex:1
                                 offset:CGPointMake(-8.0, 7.0)
                                 radius:27.3];
        
        [self modifyContactPointAtIndex:2
                                 offset:CGPointMake(49.0, 18.0)
                                 radius:19.0];
        
        [self modifyContactPointAtIndex:3
                                 offset:CGPointMake(12.0, -8.0)
                                 radius:31.0];
        
        [self modifyAttackPointAtIndex:0
                                offset:CGPointMake(65.0, 42.0)
                                radius:23.7];
    }
}

- (void)setTexture:(SKTexture *)texture
{
    [super setTexture:texture];
    
    SKTexture *attackTexture =
    [[SKTTextureCache sharedInstance]
     textureNamed:@"boss_attack_01"];
    
    SKTexture *attackTexture2 =
    [[SKTTextureCache sharedInstance]
     textureNamed:@"boss_attack_02"];
    
    if (texture == attackTexture || texture == attackTexture2) {
        [self.delegate actionSpriteDidAttack:self];
    }
}

- (void)hurtWithDamage:(CGFloat)damage
                 force:(CGFloat)force
             direction:(CGPoint)direction
{
    if (self.actionState > kActionStateNone &&
        self.actionState < kActionStateKnockedOut) {
        
        CGFloat ratio = self.hitPoints / self.maxHitPoints;
        
        if (ratio <= 0.1) {
            [self removeAllActions];
            [self runAction:self.hurtAction];
            self.actionState = kActionStateHurt;
        }
        
        self.hitPoints -= damage;
        
        self.desiredPosition =
        CGPointMake(self.position.x + direction.x * force,
                    self.position.y);
        
        if (self.hitPoints <= 0) {
            [self knockoutWithDamage:0 direction:direction];
        }
    }
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
