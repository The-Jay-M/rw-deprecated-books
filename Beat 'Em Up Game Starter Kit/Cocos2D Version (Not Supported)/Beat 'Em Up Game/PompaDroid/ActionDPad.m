//
//  ActionDPad.m
//  PompaDroid
//
//  Created by Ray Wenderlich on 2/8/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import "ActionDPad.h"

@implementation ActionDPad

+(id)dPadWithPrefix:(NSString *)filePrefix radius:(float)radius
{
    return [[self alloc] initWithPrefix:filePrefix radius:radius];
}

-(id)initWithPrefix:(NSString *)filePrefix radius:(float)radius
{
    NSString *filename = [filePrefix stringByAppendingString:@"_center.png"];
    
    if ((self = [super initWithSpriteFrameName:filename]))
    {
        _radius = radius;
        _direction = kActionDPadDirectionCenter;
        _isHeld = NO;
        _prefix = filePrefix;
        [self scheduleUpdate];
    }
    return self;
}

-(void)onEnterTransitionDidFinish
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:1 swallowsTouches:YES];
}

-(void) onExit
{
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
}

-(void)update:(ccTime)delta
{
    if (_isHeld)
    {
        [_delegate actionDPad:self isHoldingDirection:_direction];
    }
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
    
    float distanceSQ = ccpDistanceSQ(location, _position);
    if (distanceSQ <= _radius * _radius)
    {
        //get angle 8 directions
        [self updateDirectionForTouchLocation:location];
        _isHeld = YES;
        return YES;
    }
    return NO;
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
    [self updateDirectionForTouchLocation:location];
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    _direction = kActionDPadDirectionCenter;
    _isHeld = NO;
    [self setDisplayFrame: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_center.png", _prefix]]];
    [_delegate actionDPadTouchEnded:self];
}

-(void)updateDirectionForTouchLocation:(CGPoint)location
{
    float radians = ccpToAngle(ccpSub(location, _position));
    float degrees = -1 * CC_RADIANS_TO_DEGREES(radians);
    NSString *suffix = @"_center";
    
    _previousDirection = _direction;
    
    if (degrees <= 22.5 && degrees >= -22.5)
    {
        _direction = kActionDPadDirectionRight;
        suffix = @"_right";
    }
    else if (degrees > 22.5 && degrees < 67.5)
    {
        _direction = kActionDPadDirectionDownRight;
        suffix = @"_downright";
    }
    else if (degrees >= 67.5 && degrees <= 112.5)
    {
        _direction = kActionDPadDirectionDown;
        suffix = @"_down";
    }
    else if (degrees > 112.5 && degrees < 157.5)
    {
        _direction = kActionDPadDirectionDownLeft;
        suffix = @"_downleft";
    }
    else if (degrees >= 157.5 || degrees <= -157.5)
    {
        _direction = kActionDPadDirectionLeft;
        suffix = @"_left";
    }
    else if (degrees < -22.5 && degrees > -67.5)
    {
        _direction = kActionDPadDirectionUpRight;
        suffix = @"_upright";
    }
    else if (degrees <= -67.5 && degrees >= -112.5)
    {
        _direction = kActionDPadDirectionUp;
        suffix = @"_up";
    }
    else if (degrees < -112.5 && degrees > -157.5)
    {
        _direction = kActionDPadDirectionUpLeft;
        suffix = @"_upleft";
    }
    [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@%@.png", _prefix, suffix]]];
    
    if (_isHeld)
    {
        if (_previousDirection != _direction)
        {
            [_delegate actionDPad:self didChangeDirectionTo:_direction];
        }
    }
    else
    {
        [_delegate actionDPad:self didChangeDirectionTo:_direction];
    }
}

-(void)dealloc
{
    [self unscheduleUpdate];
}

@end
