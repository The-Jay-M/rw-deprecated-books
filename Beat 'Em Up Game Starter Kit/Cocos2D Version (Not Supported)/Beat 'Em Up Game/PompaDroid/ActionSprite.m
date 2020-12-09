//
//  ActionSprite.m
//  PompaDroid
//
//  Created by Ray Wenderlich on 2/8/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import "ActionSprite.h"

@implementation ActionSprite

-(void)idle
{
    if (_actionState != kActionStateIdle)
    {
        [self stopAllActions];
        [self runAction:_idleAction];
        _velocity = CGPointZero;
        self.actionState = kActionStateIdle;
        _actionDelay = 0.0;
    }
}

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

-(void)walkWithDirection:(CGPoint)direction
{
    if (_actionState == kActionStateIdle || _actionState == kActionStateRun)
    {
        [self stopAllActions];
        [self runAction:_walkAction];
        self.actionState = kActionStateWalk;
        [self moveWithDirection:direction];
    }
    else if (_actionState == kActionStateWalk)
    {
        [self moveWithDirection:direction];
    }
}

-(void)moveWithDirection:(CGPoint)direction
{
    if (_actionState == kActionStateWalk)
    {
        _velocity = ccp(direction.x * _walkSpeed, direction.y * _walkSpeed);
        [self flipSpriteForVelocity:_velocity];
    }
    else if (_actionState == kActionStateRun)
    {
        _velocity = ccp(direction.x * _runSpeed, direction.y * _walkSpeed);
        [self flipSpriteForVelocity:_velocity];
    }
    else if (_actionState == kActionStateIdle)
    {
        [self walkWithDirection:direction];
    }
}

// Add this new method
-(void)runWithDirection:(CGPoint)direction
{
    if (_actionState == kActionStateIdle || _actionState == kActionStateWalk)
    {
        [self stopAllActions];
        [self runAction:_runAction];
        self.actionState = kActionStateRun;
        [self moveWithDirection:direction];
    }
}

-(void)flipSpriteForVelocity:(CGPoint)velocity
{
    if (velocity.x > 0)
    {
        self.directionX = 1.0;
    }
    else if (velocity.x < 0)
    {
        self.directionX = -1.0;
    }
    
    self.scaleX = _directionX * kScaleFactor;
}

-(void)update:(ccTime)delta
{
    if (_actionState == kActionStateWalk || _actionState == kActionStateRun || _actionState == kActionStateRunAttack)
    {
        _desiredPosition = ccpAdd(_groundPosition, ccpMult(_velocity, delta));
    }
    else if (_actionState == kActionStateJumpRise)
    {
        _desiredPosition = ccpAdd(_groundPosition, ccpMult(_velocity, delta));
        _jumpVelocity -= kGravity * delta;
        _jumpHeight += _jumpVelocity * delta;
        
        if (_jumpVelocity <= kJumpForce/2)
        {
            [self jumpFall];
        }
    }
    else if (_actionState == kActionStateJumpFall)
    {
        _desiredPosition = ccpAdd(_groundPosition, ccpMult(_velocity, delta));
        _jumpVelocity -= kGravity * delta;
        _jumpHeight += _jumpVelocity * delta;
        
        if (_jumpHeight <= 0)
        {
            [self jumpLand];
        }
    }
    else if (_actionState == kActionStateKnockedOut)
    {
        _desiredPosition = ccpAdd(_groundPosition, ccpMult(_velocity, delta));
        _jumpVelocity -= kGravity * delta;
        _jumpHeight += _jumpVelocity * delta;

        if (_jumpHeight <= 0)
        {
            if (_hitPoints <= 0)
            {
                [self die];
            }
            else
            {
                [self recover];
            }
        }
    }
    else if (_actionState == kActionStateAutomated)
    {
        self.groundPosition = _position;
        _desiredPosition = _groundPosition;
    }
    
    if (_actionDelay > 0)
    {
        _actionDelay -= delta;
        
        if (_actionDelay <= 0)
        {
            _actionDelay = 0;
        }
    }

}

-(CGRect)feetCollisionRect
{
    CGRect feetRect = CGRectMake(_desiredPosition.x -_centerToSides, _desiredPosition.y - _centerToBottom, _centerToSides * 2, 5.0 * kPointFactor);
    return CGRectInset(feetRect, 15.0 * kPointFactor, 0);
}

-(void)attack
{
    if (_actionState == kActionStateIdle || _actionState == kActionStateWalk || (_actionState == kActionStateAttack && _actionDelay <= 0))  //added actionDelay as a condition
    {
        [self stopAllActions];
        [self runAction:_attackAction];
        self.actionState = kActionStateAttack;
        _actionDelay = _attackDelayTime;    //set actionDelay to the value of attackDelayTime
    }
    else if (_actionState == kActionStateJumpRise || _actionState == kActionStateJumpFall)
    {
        [self jumpAttack];
    }
    else if (_actionState == kActionStateRun)
    {
        [self runAttack];
    }
}

-(void)setGroundPosition:(CGPoint)groundPosition
{
    _groundPosition = groundPosition;
    _shadow.position = ccp(groundPosition.x, groundPosition.y - _centerToBottom);
}

-(void)jumpRiseWithDirection:(CGPoint)direction
{
    if (_actionState == kActionStateIdle)
    {
        [self jumpRise];
    }
    else if (_actionState == kActionStateWalk || _actionState == kActionStateJumpLand)
    {
        _velocity = ccp(direction.x * _walkSpeed, direction.y * _walkSpeed);
        [self flipSpriteForVelocity:_velocity];
        [self jumpRise];
    }
    else if (_actionState == kActionStateRun)
    {
        _velocity = ccp(direction.x * _runSpeed, direction.y * _walkSpeed);
        [self flipSpriteForVelocity:_velocity];
        [self jumpRise];
    }
}

-(void)jumpRise
{
    if (_actionState == kActionStateIdle || _actionState == kActionStateWalk || _actionState == kActionStateRun || _actionState == kActionStateJumpLand)
    {
        [self stopAllActions];
        [self runAction:_jumpRiseAction];
        _jumpVelocity = kJumpForce;
        self.actionState = kActionStateJumpRise;
    }
}


-(void)jumpCutoff
{
    if (_actionState == kActionStateJumpRise)
    {
        if (_jumpVelocity > kJumpCutoff)
        {
            _jumpVelocity = kJumpCutoff;
        }
    }
}

-(void)jumpFall
{
    if (_actionState == kActionStateJumpRise || _actionState == kActionStateJumpAttack)
    {
        self.actionState = kActionStateJumpFall;
        [self runAction:_jumpFallAction];
    }
}

-(void)jumpLand
{
    if (_actionState == kActionStateJumpFall || _actionState == kActionStateRecover)
    {
        _jumpHeight = 0;
        _jumpVelocity = 0;
        _didJumpAttack = NO;
        self.actionState = kActionStateJumpLand;
        [self runAction:_jumpLandAction];
    }
}

-(AnimationMember *)animationMemberWithPrefix:(NSString *)prefix startFrameIdx:(NSUInteger)startFrameIdx frameCount:(NSUInteger)frameCount delay:(float)delay target:(id)target
{
    CCAnimation *animation = [self animationWithPrefix:prefix startFrameIdx:startFrameIdx frameCount:frameCount delay:delay];
    return [AnimationMember memberWithAnimation:animation target:target];
}

-(ContactPoint)contactPointWithOffset:(const CGPoint)offset radius:(const float)radius
{
    ContactPoint contactPoint;
    contactPoint.offset = ccpMult(offset, kPointFactor);;
    contactPoint.radius = radius * kPointFactor;
    contactPoint.position = ccpAdd(_position, contactPoint.offset);
    return contactPoint;
}

-(void)modifyPoint:(ContactPoint *)point offset:(const CGPoint)offset radius:(const float)radius
{
    point->offset = ccpMult(offset, kPointFactor);
    point->radius = radius * kPointFactor;
    point->position = ccpAdd(_position, point->offset);
}

-(void)modifyAttackPointAtIndex:(const NSUInteger)pointIndex offset:(const CGPoint)offset radius:(const float)radius
{
    ContactPoint *contactPoint = &_attackPoints[pointIndex];
    [self modifyPoint:contactPoint offset:offset radius:radius];
}

-(void)modifyContactPointAtIndex:(const NSUInteger)pointIndex offset:(const CGPoint)offset radius:(const float)radius
{
    ContactPoint *contactPoint = &_contactPoints[pointIndex];
    [self modifyPoint:contactPoint offset:offset radius:radius];
}

// 1
-(void)setActionState:(ActionState)actionState
{
    _actionState = actionState;
    [self setContactPointsForAction:actionState];
}

// 2
-(void)setContactPointsForAction:(ActionState)actionState
{
    //override this
}

// 3
-(void)transformPoints
{
    float pixelScaleX = _scaleX / CC_CONTENT_SCALE_FACTOR();
    float pixelScaleY = _scaleY / CC_CONTENT_SCALE_FACTOR();
    int i;
    for (i = 0; i < _contactPointCount; i++)
    {
        _contactPoints[i].position = ccpAdd(_position, ccp(_contactPoints[i].offset.x * pixelScaleX, _contactPoints[i].offset.y * pixelScaleY));
    }
    for (i = 0; i < _attackPointCount; i++)
    {
        _attackPoints[i].position = ccpAdd(_position, ccp(_attackPoints[i].offset.x * pixelScaleX, _attackPoints[i].offset.y * pixelScaleY));
    }
}

-(void)enterFrom:(CGPoint)origin to:(CGPoint)destination
{
    float diffX = fabsf(destination.x - origin.x);
    float diffY = fabsf(destination.y - origin.y);
    
    if (diffX > 0)
    {
        self.directionX = 1.0;
    }
    else
    {
        self.directionX = -1.0;
    }
    
    self.scaleX = _directionX * kScaleFactor;
    
    ccTime duration = MAX(diffX, diffY) / _walkSpeed;
    
    _actionState = kActionStateAutomated;
    [self stopAllActions];
    [self runAction:_walkAction];
    [self runAction:[CCSequence actions:[CCMoveTo actionWithDuration:duration position:destination], [CCCallFunc actionWithTarget:self selector:@selector(idle)], nil]];
}

-(void)setPosition:(CGPoint)position
{
    [super setPosition:position];
    [self transformPoints];
}

-(void)hurtWithDamage:(float)damage force:(float)force direction:(CGPoint)direction
{
    if (_actionState > kActionStateNone && _actionState < kActionStateKnockedOut)
    {
        if (_jumpHeight > 0)
        {
            [self knockoutWithDamage:damage direction:direction];
        }
        else
        {
            [self stopAllActions];
            [self runAction:_hurtAction];
            self.actionState = kActionStateHurt;
            _hitPoints -= damage;
            self.desiredPosition = ccp(self.position.x + direction.x * force, self.position.y);
            if (_hitPoints <= 0)
            {
                [self knockoutWithDamage:0 direction:direction];
            }
        }
    }
}
-(void)knockoutWithDamage:(float)damage direction:(CGPoint)direction
{
    if (_actionState != kActionStateKnockedOut && _actionState != kActionStateDead && _actionState != kActionStateRecover && _actionState != kActionStateNone)
    {
        _hitPoints -= damage;
        [self stopAllActions];
        [self runAction:_knockedOutAction];
        _jumpVelocity = kJumpForce / 2.0;
        _velocity = ccp(direction.x * _runSpeed, direction.y * _runSpeed);
        [self flipSpriteForVelocity:ccp(-_velocity.x, _velocity.y)];
        self.actionState = kActionStateKnockedOut;
    }
}

-(void)die
{
    self.actionState = kActionStateDead;
    _velocity = CGPointZero;
    _jumpHeight = 0;
    _jumpVelocity = 0;
    _hitPoints = 0.0;
    [_delegate actionSpriteDidDie:self];
    [self runAction:_dieAction];
}

-(void)recover
{
    if (_actionState == kActionStateKnockedOut)
    {
        self.actionState = kActionStateNone;
        _velocity = CGPointZero;
        _jumpVelocity = 0;
        _jumpHeight = 0;    //add this
        [self performSelector:@selector(getUp) withObject:nil afterDelay:0.5];
    }
}

-(void)getUp
{
    self.actionState = kActionStateRecover;
    [self runAction:_recoverAction];
}

-(void)reset
{
    self.actionState = kActionStateNone;
    self.position = OFFSCREEN;
    self.desiredPosition = OFFSCREEN;
    self.groundPosition = OFFSCREEN;
    self.hitPoints = _maxHitPoints;
}

-(void)jumpAttack
{
    if (!_didJumpAttack && (_actionState == kActionStateJumpRise || _actionState == kActionStateJumpFall))
    {
        _velocity = CGPointZero;
        [self stopAllActions];
        self.actionState = kActionStateJumpAttack;
        _didJumpAttack = YES;
        [self runAction:_jumpAttackAction];
    }
}

-(void)runAttack
{
    if (_actionState == kActionStateRun)
    {
        [self stopAllActions];
        self.actionState = kActionStateRunAttack;
        [self runAction:_runAttackAction];
    }
}

-(void)cleanup
{
    self.idleAction = nil;
    self.attackAction = nil;
    self.walkAction = nil;
    self.hurtAction = nil;
    self.knockedOutAction = nil;
    self.recoverAction = nil;
    self.runAction = nil;
    self.jumpRiseAction = nil;
    self.jumpFallAction = nil;
    self.jumpLandAction = nil;
    self.jumpAttackAction = nil;
    self.runAttackAction = nil;
    self.dieAction = nil;
    
    [super cleanup];
}

-(void)dealloc
{
    free(_attackPoints);
    free(_contactPoints);
}

@end
