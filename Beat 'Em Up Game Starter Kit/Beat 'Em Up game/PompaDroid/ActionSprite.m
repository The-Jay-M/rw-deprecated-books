//
//  ActionSprite.m
//  PompaDroid
//
//  Created by Allen Tan on 6/11/14.
//
//

#import "ActionSprite.h"
#import "SKTTextureCache.h"
#import "AnimationMember.h"

@interface ActionSprite()

@property (assign, nonatomic) BOOL didJumpAttack;

@end

@implementation ActionSprite

- (void)idle
{
    if (self.actionState != kActionStateIdle) {
        self.actionDelay = 0.0;
        [self removeAllActions];
        [self runAction:self.idleAction];
        self.velocity = CGPointZero;
        self.actionState = kActionStateIdle;
    }
}

- (NSMutableArray *)texturesWithPrefix:(NSString *)prefix
                         startFrameIdx:(NSInteger)startFrameIdx
                            frameCount:(NSInteger)frameCount
{
    
    NSInteger idxCount = frameCount + startFrameIdx;
    NSMutableArray *textures =
    [NSMutableArray arrayWithCapacity:frameCount];
    
    SKTexture *texture;
    
    for (NSInteger i = startFrameIdx; i < idxCount; i++) {
        
        NSString *name =
        [NSString stringWithFormat:@"%@_%02ld", prefix, (long)i];
        
        texture = [[SKTTextureCache sharedInstance]
                   textureNamed:name];
        
        [textures addObject:texture];
    }
    
    return textures;
}

- (void)walkWithDirection:(CGPoint)direction
{
    if (self.actionState == kActionStateIdle ||
        self. actionState == kActionStateRun) {
        
        [self removeAllActions];
        [self runAction:self.walkAction];
        self.actionState = kActionStateWalk;
        [self moveWithDirection:direction];
        
    } else if (self.actionState == kActionStateWalk) {
        [self moveWithDirection:direction];
    }
}

- (void)moveWithDirection:(CGPoint)direction
{
    if (self.actionState == kActionStateWalk) {
        
        self.velocity = CGPointMake(direction.x * self.walkSpeed,
                                    direction.y * self.walkSpeed);
        [self flipSpriteForVelocity:self.velocity];
        
    } else if (self.actionState == kActionStateRun) {
        
        self.velocity = CGPointMake(direction.x * self.runSpeed,
                                    direction.y * self.runSpeed);
        [self flipSpriteForVelocity:self.velocity];
        
    } else if (self.actionState == kActionStateIdle) {
        
        [self walkWithDirection:direction];
    }
}

- (void)flipSpriteForVelocity:(CGPoint)velocity
{
    if (velocity.x > 0) {
        self.directionX = 1.0;
    } else if (velocity.x < 0) {
        self.directionX = -1.0;
    }
    
    self.xScale = self.directionX * kPointFactor;
}

- (void)update:(NSTimeInterval)delta
{
    
    if (self.actionState == kActionStateWalk ||
        self.actionState == kActionStateRun ||
        self.actionState == kActionStateRunAttack) {
        
        CGPoint point = CGPointMultiplyScalar(self.velocity, delta);
        self.desiredPosition = CGPointAdd(self.groundPosition, point);
        
    } else if (self.actionState == kActionStateJumpRise) {
        
        CGPoint point = CGPointMultiplyScalar(self.velocity, delta);
        self.desiredPosition =
        CGPointAdd(self.groundPosition, point);
        
        self.jumpVelocity -= kGravity * delta;
        self.jumpHeight += self.jumpVelocity * delta;
        
        if (self.jumpVelocity <= kJumpForce/2) {
            [self jumpFall];
        }
        
    } else if (self.actionState == kActionStateJumpFall) {
        
        CGPoint point = CGPointMultiplyScalar(self.velocity, delta);
        self.desiredPosition =
        CGPointAdd(self.groundPosition, point);
        
        self.jumpVelocity -= kGravity * delta;
        self.jumpHeight += self.jumpVelocity * delta;
        
        if (self.jumpHeight <= 0) {
            [self jumpLand];
        }
    } else if (_actionState == kActionStateKnockedOut) {
        
        self.desiredPosition =
        CGPointAdd(self.groundPosition,
                   CGPointMultiplyScalar(self.velocity, delta));
        
        self.jumpVelocity -= kGravity * delta;
        self.jumpHeight += self.jumpVelocity * delta;
        
        if (self.jumpHeight <= 0) {
            if (self.hitPoints <= 0) {
                [self die];
            } else {
                [self recover];
            }
        }
    } else if (self.actionState == kActionStateAutomated) {
        
        self.groundPosition = self.position;
        self.desiredPosition = self.groundPosition;
    }
    
    if (self.actionDelay > 0) {
        self.actionDelay -= delta;
        
        if (self.actionDelay <= 0) {
            self.actionDelay = 0;
        }
    }
}

- (CGRect)feetCollisionRect
{
    CGRect feetRect =
    CGRectMake(self.desiredPosition.x - self.centerToSides,
               self.desiredPosition.y - self.centerToBottom,
               self.centerToSides * 2,
               5.0 * kPointFactor);
    
    return CGRectInset(feetRect, 15.0 * kPointFactor, 0);
}

- (void)runWithDirection:(CGPoint)direction
{
    if (self.actionState == kActionStateIdle ||
        self.actionState == kActionStateWalk) {
        
        [self removeAllActions];
        [self runAction:self.runAction];
        self.actionState = kActionStateRun;
        [self moveWithDirection:direction];
    }
}

- (void)attack
{
    //add actionDelay as condition
    if (self.actionState == kActionStateIdle ||
        self.actionState == kActionStateWalk ||
        (self.actionState == kActionStateAttack &&
         self.actionDelay <= 0)) {
            
            [self removeAllActions];
            [self runAction:self.attackAction];
            self.actionState = kActionStateAttack;
            //set actionDelay to the value of attackDelayTime
            self.actionDelay = self.attackDelayTime;
            
        } else if (self.actionState == kActionStateJumpRise ||
                   self.actionState == kActionStateJumpFall) {
            
            [self jumpAttack];
            
        } else if (self.actionState == kActionStateRun) {
            
            [self runAttack];
            
        }
}

- (void)setGroundPosition:(CGPoint)groundPosition
{
    _groundPosition = groundPosition;
    self.shadow.position =
    CGPointMake(groundPosition.x,
                groundPosition.y - self.centerToBottom);
}

- (void)jumpRiseWithDirection:(CGPoint)direction
{
    if (self.actionState == kActionStateIdle) {
        [self jumpRise];
    }
    else if (self.actionState == kActionStateWalk ||
             self.actionState == kActionStateJumpLand) {
        
        self.velocity = CGPointMake(direction.x * self.walkSpeed,
                                    direction.y * self.walkSpeed);
        [self flipSpriteForVelocity:self.velocity];
        [self jumpRise];
    }
    else if (self.actionState == kActionStateRun) {
        
        self.velocity = CGPointMake(direction.x * self.runSpeed,
                                    direction.y * self.walkSpeed);
        [self flipSpriteForVelocity:self.velocity];
        [self jumpRise];
    }
}

- (void)jumpRise
{
    if (self.actionState == kActionStateIdle ||
        self.actionState == kActionStateWalk ||
        self.actionState == kActionStateRun ||
        self.actionState == kActionStateJumpLand) {
        
        [self removeAllActions];
        [self runAction:self.jumpRiseAction];
        self.jumpVelocity = kJumpForce;
        self.actionState = kActionStateJumpRise;
    }
}

- (void)jumpCutoff
{
    if (self.actionState == kActionStateJumpRise) {
        
        if (self.jumpVelocity > kJumpCutoff) {
            self.jumpVelocity = kJumpCutoff;
        }
    }
}

- (void)jumpFall
{
    if (self.actionState == kActionStateJumpRise ||
        self.actionState == kActionStateJumpAttack) {
        
        self.actionState = kActionStateJumpFall;
        [self runAction:self.jumpFallAction];
    }
}

- (void)jumpLand
{
    if (self.actionState == kActionStateJumpFall ||
        self.actionState == kActionStateRecover) {
        
        self.jumpHeight = 0;
        self.jumpVelocity = 0;
        self.didJumpAttack = NO;
        
        self.actionState = kActionStateJumpLand;
        [self runAction:self.jumpLandAction];
    }
}

- (SKAction *)animateActionForGroup:(NSMutableArray *)group
                       timePerFrame:(NSTimeInterval)timeInterval
                         frameCount:(NSInteger)frameCount
{
    NSTimeInterval duration = timeInterval * frameCount;
    
    SKAction *action = [SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime){
        
        int index = elapsedTime / timeInterval;
        for (int i = 0; i < group.count; ++i)
        {
            AnimationMember *animationMember = group[i];
            if (animationMember)
                [animationMember animateToIndex:index];
        }
    }];
    
    return action;
}

- (void)setZPosition:(CGFloat)zPosition
{
    [super setZPosition:zPosition];
    
    if (self.shadow) {
        self.shadow.zPosition = zPosition;
    }
}

- (NSMutableArray *)contactPointArray:(NSUInteger)size
{
    
    NSMutableArray *array =
    [[NSMutableArray alloc] initWithCapacity:size];
    
    for (NSInteger i  = 0; i < size; i++) {
        
        ContactPoint contactPoint;
        contactPoint.offset = CGPointZero;
        contactPoint.position = CGPointZero;
        contactPoint.radius = 0;
        
        NSValue *value =
        [NSValue valueWithBytes:&contactPoint
                       objCType:@encode(ContactPoint)];
        
        [array addObject:value];
    }
    
    return array;
}

- (ContactPoint)contactPointWithOffset:(const CGPoint)offset
                                radius:(const CGFloat)radius
{
    ContactPoint contactPoint;
    
    contactPoint.offset =
    CGPointMultiplyScalar(offset, kPointFactor);
    
    contactPoint.radius = radius * kPointFactor;
    
    contactPoint.position =
    CGPointAdd(self.position, contactPoint.offset);
    
    return contactPoint;
}

// 2
- (void)modifyPoint:(ContactPoint *)point
             offset:(const CGPoint)offset
             radius:(const CGFloat)radius
{
    point->offset = CGPointMultiplyScalar(offset, kPointFactor);
    point->radius = radius * kPointFactor;
    point->position = CGPointAdd(self.position, point->offset);
}

//3
- (void)modifyAttackPointAtIndex:(const NSUInteger)pointIndex
                          offset:(const CGPoint)offset
                          radius:(const CGFloat)radius
{
    NSValue *value = self.attackPoints[pointIndex];
    ContactPoint contactPoint;
    [value getValue:&contactPoint];
    
    [self modifyPoint:&contactPoint offset:offset radius:radius];
    
    self.attackPoints[pointIndex] =
    [NSValue valueWithBytes:&contactPoint
                   objCType:@encode(ContactPoint)];
}

//3
- (void)modifyContactPointAtIndex:(const NSUInteger)pointIndex
                           offset:(const CGPoint)offset
                           radius:(const CGFloat)radius
{
    NSValue *value = self.contactPoints[pointIndex];
    ContactPoint contactPoint;
    [value getValue:&contactPoint];
    
    [self modifyPoint:&contactPoint offset:offset radius:radius];
    
    self.contactPoints[pointIndex] =
    [NSValue valueWithBytes:&contactPoint
                   objCType:@encode(ContactPoint)];
}

// 1
- (void)setActionState:(ActionState)actionState
{
    _actionState = actionState;
    [self setContactPointsForAction:actionState];
}

// 2
- (void)setContactPointsForAction:(ActionState)actionState
{
    //override this
}

// 3
- (void)transformPoints
{
    
    for (NSInteger i = 0; i < self.contactPoints.count; i++) {
        
        NSValue *value = self.contactPoints[i];
        ContactPoint contactPoint;
        [value getValue:&contactPoint];
        
        CGPoint offset = CGPointMake(contactPoint.offset.x *
                                     self.directionX,
                                     contactPoint.offset.y);
        
        contactPoint.position = CGPointAdd(self.position, offset);
        
        self.contactPoints[i] =
        [NSValue valueWithBytes:&contactPoint
                       objCType:@encode(ContactPoint)];
    }
    
    for (NSInteger i = 0; i < self.attackPoints.count; i++) {
        
        NSValue *value = self.attackPoints[i];
        ContactPoint contactPoint;
        [value getValue:&contactPoint];
        
        CGPoint offset = CGPointMake(contactPoint.offset.x *
                                     self.directionX,
                                     contactPoint.offset.y);
        
        contactPoint.position = CGPointAdd(self.position, offset);
        
        self.attackPoints[i] =
        [NSValue valueWithBytes:&contactPoint
                       objCType:@encode(ContactPoint)];
    }
}
// 4
- (void)setPosition:(CGPoint)position
{
    [super setPosition:position];
    [self transformPoints];
}

- (void)hurtWithDamage:(CGFloat)damage
                 force:(CGFloat)force
             direction:(CGPoint)direction
{
    if (self.actionState > kActionStateNone &&
        self.actionState < kActionStateKnockedOut) {
        
        if (self.jumpHeight > 0) {
            
            [self knockoutWithDamage:damage direction:direction];
            
        } else {
            
            [self removeAllActions];
            [self runAction:self.hurtAction];
            self.actionState = kActionStateHurt;
            self.hitPoints -= damage;
            self.desiredPosition =
            CGPointMake(self.position.x + direction.x * force,
                        self.position.y);
            
            if (self.hitPoints <= 0) {
                [self knockoutWithDamage:0 direction:direction];
            }
        }
    }
}

- (void)knockoutWithDamage:(CGFloat)damage
                 direction:(CGPoint)direction
{
    if (self.actionState != kActionStateKnockedOut &&
        self.actionState != kActionStateDead &&
        self.actionState != kActionStateRecover &&
        self.actionState != kActionStateNone) {
        
        self.hitPoints -= damage;
        [self removeAllActions];
        [self runAction:_knockedOutAction];
        self.jumpVelocity = kJumpForce / 2.0;
        self.velocity = CGPointMake(direction.x * self.runSpeed,
                                    direction.y * self.runSpeed);
        [self flipSpriteForVelocity:CGPointMake(-self.velocity.x, self.velocity.y)];
        self.actionState = kActionStateKnockedOut;
    }
}
- (void)die
{
    self.actionState = kActionStateDead;
    self.velocity = CGPointZero;
    self.jumpHeight = 0;
    self.jumpVelocity = 0;
    self.hitPoints = 0.0;
    [self.delegate actionSpriteDidDie:self];
    [self runAction:self.dieAction];
}

- (void)recover
{
    if (self.actionState == kActionStateKnockedOut) {
        
        self.actionState = kActionStateNone;
        self.velocity = CGPointZero;
        self.jumpVelocity = 0;
        self.jumpHeight = 0;
        
        [self performSelector:@selector(getUp)
                   withObject:nil
                   afterDelay:0.5];
    }
}

- (void)getUp
{
    self.actionState = kActionStateRecover;
    [self runAction:self.recoverAction];
}

- (SKAction *)animateActionForTextures:(NSMutableArray *)textures timePerFrame:(NSTimeInterval)timeInterval
{
    
    AnimationMember *animationMember =
    [AnimationMember animationWithTextures:textures
                                    target:self];
    
    NSMutableArray *actionGroup =
    [NSMutableArray arrayWithObject:animationMember];
    
    SKAction *action =
    [self animateActionForGroup:actionGroup
                   timePerFrame:timeInterval
                     frameCount:textures.count];
    
    return action;
}

- (void)reset
{
    self.actionState = kActionStateNone;
    self.position = OFFSCREEN;
    self.desiredPosition = OFFSCREEN;
    self.groundPosition = OFFSCREEN;
    self.hitPoints = self.maxHitPoints;
}

- (void)enterFrom:(CGPoint)origin to:(CGPoint)destination
{
    CGFloat diffX = fabsf(destination.x - origin.x);
    CGFloat diffY = fabsf(destination.y - origin.y);
    
    if (diffX > 0) {
        self.directionX = 1.0;
    } else {
        self.directionX = -1.0;
    }
    
    self.xScale = self.directionX * kPointFactor;
    
    NSTimeInterval duration = MAX(diffX, diffY) / self.walkSpeed;
    
    self.actionState = kActionStateAutomated;
    [self removeAllActions];
    [self runAction:self.walkAction];
    
    SKAction *moveAction =
    [SKAction moveTo:destination duration:duration];
    
    SKAction *blockAction = [SKAction runBlock:^{
        [self.delegate actionSpriteDidFinishAutomatedWalking:self];
        [self idle];
    }];
    
    [self runAction:[SKAction sequence:@[moveAction,
                                         blockAction]]];
}

- (void)jumpAttack
{
    if (!self.didJumpAttack &&
        (self.actionState == kActionStateJumpRise ||
         self.actionState == kActionStateJumpFall)) {
        
        self.velocity = CGPointZero;
        [self removeAllActions];
        self.actionState = kActionStateJumpAttack;
        self.didJumpAttack = YES;
        [self runAction:self.jumpAttackAction];
    }
}

- (void)runAttack
{
    if (self.actionState == kActionStateRun) {
        
        [self removeAllActions];
        self.actionState = kActionStateRunAttack;
        [self runAction:self.runAttackAction];
    }
}

- (void)exitFrom:(CGPoint)origin to:(CGPoint)destination
{
    CGFloat diffX = fabsf(destination.x - origin.x);
    CGFloat diffY = fabsf(destination.y - origin.y);
    
    if (diffX > 0) {
        self.directionX = 1.0;
    } else {
        self.directionX = -1.0;
    }
    
    self.xScale = self.directionX * kPointFactor;
    
    NSTimeInterval duration = MAX(diffX, diffY) / self.walkSpeed;
    
    self.actionState = kActionStateAutomated;
    [self removeAllActions];
    [self runAction:self.walkAction];
    [self runAction:[SKAction moveTo:destination
                            duration:duration]];
}
- (void)cleanup
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
}

- (void)setTexture:(SKTexture *)texture
{
    // 1
    CGFloat xScale = self.xScale;
    CGFloat yScale = self.yScale;
    
    // 2
    self.xScale = 1.0;
    self.yScale = 1.0;
    
    [super setTexture:texture];
    
    // 3
    self.size = texture.size;
    
    //restore the previous xScale
    self.xScale = xScale;
    self.yScale = yScale;
}

@end
