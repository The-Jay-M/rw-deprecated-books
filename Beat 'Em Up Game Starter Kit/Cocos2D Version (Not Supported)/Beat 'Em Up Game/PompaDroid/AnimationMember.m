//
//  AnimationMember.m
//  PompaDroid
//
//  Created by Ray Wenderlich on 2/12/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import "AnimationMember.h"

@implementation AnimationMember

+(id)memberWithAnimation:(CCAnimation *)animation target:(CCSprite *)target
{
    return [[self alloc] initWithAnimation:animation target:target];
}

-(id)initWithAnimation:(CCAnimation *)animation target:(CCSprite *)target
{
    if ((self = [super init]))
    {
        self.animation = animation;
        self.target = target;
        _origFrame = nil;
    }
    return self;
}

-(void)start
{
    _origFrame = _target.displayFrame;
}

-(void)stop
{
    if (_animation.restoreOriginalFrame)
    {
        [_target setDisplayFrame:_origFrame];
    }
}

-(void)setFrame:(NSUInteger)frameIndex
{
    NSArray *frames = [_animation frames];
    CCAnimationFrame *frame = [frames objectAtIndex:frameIndex];
    CCSpriteFrame *spriteFrame = [frame spriteFrame];
    [_target setDisplayFrame:spriteFrame];
}

@end
