//
//  HitEffect.h
//  PompaDroid
//
//  Created by Allen Tan on 6/11/14.
//
//

#import <SpriteKit/SpriteKit.h>

@interface HitEffect : SKSpriteNode

@property (strong, nonatomic) SKAction *effectAction;

- (void)showEffectAtPosition:(CGPoint)position;
- (void)cleanup;

@end
