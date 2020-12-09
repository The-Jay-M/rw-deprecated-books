//
//  HitEffect.m
//  PompaDroid
//
//  Created by Allen Tan on 6/11/14.
//
//

#import "HitEffect.h"
#import "SKTTextureCache.h"
#import "SKAction+SKTExtras.h"

@implementation HitEffect

- (void)cleanup
{
    self.effectAction = nil;
}

- (instancetype)init
{
    
    SKTexture *texture =
    [[SKTTextureCache sharedInstance]
     textureNamed:@"hiteffect_00"];
    
    if (self = [super initWithTexture:texture]) {
        
        NSMutableArray *textures =
        [NSMutableArray arrayWithCapacity:6];
        
        for (int i = 0; i < 6; i++) {
            
            [textures addObject:[[SKTTextureCache sharedInstance] textureNamed:[NSString stringWithFormat:@"hiteffect_%02d", i]]];
            
        }
        
        self.effectAction = [SKAction sequence:@[[SKAction showNode:self], [SKAction animateWithTextures:textures timePerFrame:1.0/12.0], [SKAction hideNode:self]]];
        
    }
    return self;
}

- (void)showEffectAtPosition:(CGPoint)position
{
    [self removeAllActions];
    self.position = position;
    [self runAction:self.effectAction];
}

@end
