//
//  ParallaxNode.h
//  SpaceGame
//
//  Created by Main Account on 10/29/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface ParallaxNode : SKNode

@property (nonatomic, assign) CGPoint velocity;

- (id)initWithVelocity:(CGPoint)velocity;
- (void)addChild:(SKSpriteNode *)node parallaxRatio:(float)parallaxRatio;
- (void)update:(float)dt;

@end
