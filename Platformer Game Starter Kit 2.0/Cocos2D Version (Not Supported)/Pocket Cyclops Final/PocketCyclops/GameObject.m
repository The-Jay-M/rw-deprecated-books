//
//  GameObject.m
//  PocketCyclops
//
//  Created by Ray Wenderlich on 1/9/13.
//  Copyright 2013 Jake Gundersen. All rights reserved.
//

#import "GameObject.h"


@implementation GameObject

-(id)initWithSpriteFrameName:(NSString *)spriteFrameName {
    if (self = [super initWithSpriteFrameName:spriteFrameName]) {
        [self loadAnimations];
    }
    return self;
}

-(CCAnimation*)loadAnimationFromPlist:(NSString *)animationName forClass:(NSString *)className {
    //1
    NSString *path = [[NSBundle mainBundle] pathForResource:className ofType:@"plist"];
    NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    
    //2
    NSDictionary *animationSettings = [plistDictionary objectForKey:animationName];
    
    //3
    CCAnimation *animation = [CCAnimation animation];
    
    //4
    animation.delayPerUnit = [[animationSettings objectForKey:@"delay"] floatValue];
    
    //5
    NSString *animationFrames = [animationSettings objectForKey:@"animationFrames"];
    NSArray *animationFrameNumbers = [animationFrames componentsSeparatedByString:@","];
    
    //6
    for (NSString *frameNumber in animationFrameNumbers) {
        NSString *frameName = [NSString stringWithFormat:@"%@%@.png",className,frameNumber];
        [animation addSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName]];
    }
    
    //7
    return animation;
}

-(void)loadAnimations {
    //override this method
}

@end
