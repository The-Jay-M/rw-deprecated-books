//
//  ActionButton.m
//  PompaDroid
//
//  Created by Ray Wenderlich on 2/12/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import "ActionButton.h"

@implementation ActionButton

+(id)buttonWithPrefix:(NSString *)filePrefix radius:(float)radius
{
    return [[self alloc] initWithPrefix:filePrefix radius:radius];
}

-(id)initWithPrefix:(NSString *)filePrefix radius:(float)radius
{
    NSString *filename = [filePrefix stringByAppendingString:@"_normal.png"];
    
    if ((self = [super initWithSpriteFrameName:filename]))
    {
        _radius = radius;
        _prefix = filePrefix;
        _isHeld = NO;
        [self scheduleUpdate];
    }
    return self;
}

-(void)update:(ccTime)delta
{
    if (_isHeld)
    {
        [_delegate actionButtonIsHeld:self];
    }
}

-(void)onEnterTransitionDidFinish
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:1 swallowsTouches:YES];
}

-(void) onExit
{
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
    
    float distanceSQ = ccpDistanceSQ(location, _position);
    if (distanceSQ <= _radius * _radius)
    {
        _isHeld = YES;
        [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_selected.png", _prefix]]];
        [_delegate actionButtonWasPressed:self];
        return YES;
    }
    return NO;
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    _isHeld = NO;
    [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_normal.png", _prefix]]];
    [_delegate actionButtonWasReleased:self];
}

-(void)dealloc
{
    [self unscheduleUpdate];
}

@end
