//
//  ActionSprite.h
//  PompaDroid
//
//  Created by Ray Wenderlich on 2/8/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AnimationMember.h"

@class ActionSprite;

@protocol ActionSpriteDelegate <NSObject>

-(BOOL)actionSpriteDidAttack:(ActionSprite *)actionSprite;
-(BOOL)actionSpriteDidDie:(ActionSprite *)actionSprite;

@end

@interface ActionSprite : CCSprite {
    BOOL _didJumpAttack;
    float _actionDelay;
    float _attackDelayTime;
}

//attachments
@property(nonatomic, strong)CCSprite *shadow;

//actions
@property(nonatomic, strong)id idleAction;
@property(nonatomic, strong)id attackAction;
@property(nonatomic, strong)id walkAction;
@property(nonatomic, strong)id hurtAction;
@property(nonatomic, strong)id knockedOutAction;
@property(nonatomic, strong)id recoverAction;
@property(nonatomic, strong)id runAction;
@property(nonatomic, strong)id jumpRiseAction;
@property(nonatomic, strong)id jumpFallAction;
@property(nonatomic, strong)id jumpLandAction;
@property(nonatomic, strong)id jumpAttackAction;
@property(nonatomic, strong)id runAttackAction;
@property(nonatomic, strong)id dieAction;

//states
@property(nonatomic, assign) ActionState actionState;
@property(nonatomic, assign)float directionX;

//attributes
@property(nonatomic, assign)float walkSpeed;
@property(nonatomic, assign)float runSpeed;
@property(nonatomic, assign)float hitPoints;
@property(nonatomic, assign)float attackDamage;
@property(nonatomic, assign)float jumpAttackDamage;
@property(nonatomic, assign)float runAttackDamage;
@property(nonatomic, assign)float maxHitPoints;
@property(nonatomic, assign)float attackForce;

//movement
@property(nonatomic, assign)CGPoint velocity;
@property(nonatomic, assign)float jumpVelocity;
@property(nonatomic, assign)float jumpHeight;
@property(nonatomic, assign)CGPoint desiredPosition;
@property(nonatomic, assign)CGPoint groundPosition;

//measurements
@property(nonatomic, assign)float centerToSides;
@property(nonatomic, assign)float centerToBottom;

//collision
@property(nonatomic, assign)ContactPoint *contactPoints;
@property(nonatomic, assign)ContactPoint *attackPoints;
@property(nonatomic, assign)int contactPointCount;
@property(nonatomic, assign)int attackPointCount;
@property(nonatomic, assign)float detectionRadius;

-(CGRect)feetCollisionRect;

//action methods
-(void)idle;
-(void)attack;
-(void)hurtWithDamage:(float)damage force:(float)force direction:(CGPoint)direction;
-(void)knockoutWithDamage:(float)damage direction:(CGPoint)direction;
-(void)die;
-(void)recover;
-(void)getUp;
-(void)moveWithDirection:(CGPoint)direction;
-(void)runWithDirection:(CGPoint)direction;
-(void)walkWithDirection:(CGPoint)direction;
-(void)enterFrom:(CGPoint)origin to:(CGPoint)destination;
-(void)jumpRiseWithDirection:(CGPoint)direction;
-(void)jumpCutoff;
-(void)jumpFall;
-(void)jumpLand;
-(void)jumpAttack;
-(void)runAttack;
-(void)reset;

//contact point methods
-(void)modifyContactPointAtIndex:(const NSUInteger)pointIndex offset:(const CGPoint)offset radius:(const float)radius;
-(void)modifyAttackPointAtIndex:(const NSUInteger)pointIndex offset:(const CGPoint)offset radius:(const float)radius;
-(void)modifyPoint:(ContactPoint *)point offset:(const CGPoint)offset radius:(const float)radius;
-(ContactPoint)contactPointWithOffset:(const CGPoint)offset radius:(const float)radius;
-(void)setContactPointsForAction:(ActionState)actionState;

//factory methods
-(CCAnimation *)animationWithPrefix:(NSString *)prefix startFrameIdx:(NSUInteger)startFrameIdx frameCount:(NSUInteger)frameCount delay:(float)delay;

-(AnimationMember *)animationMemberWithPrefix:(NSString *)prefix startFrameIdx:(NSUInteger)startFrameIdx frameCount:(NSUInteger)frameCount delay:(float)delay target:(id)target;

//add this property to ActionSprite
@property(nonatomic, weak)id <ActionSpriteDelegate> delegate;

@end
