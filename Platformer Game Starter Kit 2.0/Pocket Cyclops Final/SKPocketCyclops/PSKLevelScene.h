//
//  PSKMyScene.h
//  SKPocketCyclops
//
//  Created by Jake Gundersen on 10/26/13.
//  Copyright (c) 2013 Razeware, LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol SceneDelegate <NSObject>
- (void)dismissScene;
@end

@interface PSKLevelScene : SKScene

@property (nonatomic, weak) id <SceneDelegate> sceneDelegate;

- (id)initWithSize:(CGSize)size level:(NSUInteger)currentLevel;
- (void)loseGame;

@end
