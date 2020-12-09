//
//  Gauntlets.m
//  PompaDroid
//
//  Created by Allen Tan on 6/11/14.
//
//

#import "Gauntlets.h"
#import "SKTTextureCache.h"
#import "SKAction+SKTExtras.h"

@implementation Gauntlets

- (instancetype)init
{
    if (self = [super initWithTexture:[[SKTTextureCache sharedInstance] textureNamed:@"weapon_unequipped"]])
    {
        self.attack = [self animationMemberWithPrefix:@"weapon_attack_00" startFrameIdx:0 frameCount:3 timePerFrame:1.0/15.0 target:self];
        
        self.attackTwo = [self animationMemberWithPrefix:@"weapon_attack_01" startFrameIdx:0 frameCount:3 timePerFrame:1.0/12.0 target:self];
        
        self.attackThree = [self animationMemberWithPrefix:@"weapon_attack_02" startFrameIdx:0 frameCount:5 timePerFrame:1.0/10.0 target:self];
        
        self.idle = [self animationMemberWithPrefix:@"weapon_idle" startFrameIdx:0 frameCount:6 timePerFrame:1.0/12.0 target:self];
        
        self.walk = [self animationMemberWithPrefix:@"weapon_walk" startFrameIdx:0 frameCount:8 timePerFrame:1.0/12.0 target:self];
        
        SKTexture *dropTexture = [[SKTTextureCache sharedInstance] textureNamed:@"weapon_unequipped"];
        self.droppedAction = [SKAction setTexture:dropTexture];
        
        self.destroyedAction = [SKAction sequence:@[[SKAction blinkWithDuration:2.0 blinks:5], [SKAction performSelector:@selector(reset) onTarget:self]]];
        
        self.damageBonus = 20.0;
        self.centerToBottom = 5.0 * kPointFactor;
        
        self.shadow = [SKSpriteNode spriteNodeWithTexture:[[SKTTextureCache sharedInstance] textureNamed:@"shadow_weapon"]];
        
        self.shadow.alpha = 0.75;
        self.detectionRadius = 10.0 * kPointFactor;
        
        [self reset];
    }
    
    return self;
}

- (void)reset
{
    [super reset];
    self.limit = 20;
}

@end
