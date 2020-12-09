//
//  AnimationMember.m
//  PompaDroid
//
//  Created by Allen Tan on 6/11/14.
//
//

#import "AnimationMember.h"

@implementation AnimationMember

+ (instancetype)animationWithTextures:(NSMutableArray *)textures
                               target:(SKSpriteNode *)target
{
    return [[self alloc] initWithTextures:textures target:target];
}

- (instancetype)initWithTextures:(NSMutableArray *)textures
                          target:(SKSpriteNode *)target
{
    if (self = [super init]) {
        
        _textures = textures;
        _target = target;
        _currentIndex = 0;
    }
    return self;
}

- (void)animateToIndex:(NSInteger)index
{
    if (index < self.textures.count) {
        
        SKTexture *texture = self.textures[index];
        
        if (texture != self.target.texture) {
            [self.target setTexture:texture];
            self.currentIndex = index;
        }
    }
}

@end
