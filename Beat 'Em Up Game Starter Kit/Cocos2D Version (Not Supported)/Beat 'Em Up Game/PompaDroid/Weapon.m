//
//  Weapon.m
//  PompaDroid
//
//  Created by Ray Wenderlich on 4/1/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import "Weapon.h"

@implementation Weapon

-(CCAnimation *)animationWithPrefix:(NSString *)prefix startFrameIdx:(NSUInteger)startFrameIdx frameCount:(NSUInteger)frameCount delay:(float)delay
{
    int idxCount = frameCount + startFrameIdx;
    CCArray *frames = [CCArray arrayWithCapacity:frameCount];
    int i;
    CCSpriteFrame *frame;
    for (i = startFrameIdx; i < idxCount; i++)
    {
        frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_%02d.png", prefix, i]];
        [frames addObject:frame];
    }
    
    return [CCAnimation animationWithSpriteFrames:[frames getNSArray] delay:delay];
}

-(AnimationMember *)animationMemberWithPrefix:(NSString *)prefix startFrameIdx:(NSUInteger)startFrameIdx frameCount:(NSUInteger)frameCount delay:(float)delay target:(id)target
{
    CCAnimation *animation = [self animationWithPrefix:prefix startFrameIdx:startFrameIdx frameCount:frameCount delay:delay];
    return [AnimationMember memberWithAnimation:animation target:target];
}

-(void)reset
{
    self.visible = NO;
    _shadow.visible = NO;
    _weaponState = kWeaponStateNone;
    self.velocity = CGPointZero;
    self.jumpVelocity = 0;
}

-(void)setVisible:(BOOL)visible
{
    [super setVisible:visible];
    self.shadow.visible = visible;
}

-(void)setGroundPosition:(CGPoint)groundPosition
{
    _groundPosition = groundPosition;
    _shadow.position = ccp(groundPosition.x, groundPosition.y - _centerToBottom);
}
-(void)used
{
    self.limit--;
    
    if (_limit <= 0)
    {
        [_delegate weaponDidReachLimit:self];
        self.weaponState = kWeaponStateDestroyed;
        [self runAction:_destroyedAction];
    }
}

-(void)pickedUp
{
    self.weaponState = kWeaponStateEquipped;
    self.shadow.visible = NO;
}

-(void)droppedFrom:(float)height to:(CGPoint)destination
{
    _jumpVelocity = kJumpCutoff;
    _jumpHeight = height;
    self.groundPosition = destination;
    self.weaponState = kWeaponStateUnequipped;
    self.shadow.visible = YES;
    [self runAction:_droppedAction];
}

-(void)update:(ccTime)delta
{
    if (_weaponState > kWeaponStateEquipped)
    {
        self.groundPosition = ccpAdd(self.groundPosition, ccpMult(_velocity, delta));
        _jumpVelocity -= kGravity * delta;
        _jumpHeight += _jumpVelocity * delta;
        
        if (_jumpHeight < 0)
        {
            _velocity = CGPointZero;
            _jumpVelocity = 0;
            _jumpHeight = 0;
        }
    }
}


@end
