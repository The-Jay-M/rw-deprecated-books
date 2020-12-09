//
//  GameScene.h
//  PompaDroid
//
//  Created by Allen Tan on 6/10/14.
//
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene

+ (instancetype)sceneWithSize:(CGSize)size
                        level:(NSUInteger)level;

- (instancetype)initWithSize:(CGSize)size
                       level:(NSUInteger)level;

@end
