//
//  Weapon.h
//  PompaDroid
//
//  Created by Ray Wenderlich on 4/1/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AnimationMember.h"

@class Weapon;

@protocol WeaponDelegate <NSObject>

-(void)weaponDidReachLimit:(Weapon *)weapon;

@end

@interface Weapon : CCSprite {
}

//delegate
@property(nonatomic, weak)id <WeaponDelegate> delegate;

@property(nonatomic, strong)CCSprite *shadow;
@property(nonatomic, strong)AnimationMember *attack;
@property(nonatomic, strong)AnimationMember *attackTwo;
@property(nonatomic, strong)AnimationMember *attackThree;
@property(nonatomic, strong)AnimationMember *idle;
@property(nonatomic, strong)AnimationMember *walk;
@property(nonatomic, strong)id droppedAction;
@property(nonatomic, strong)id destroyedAction;
@property(nonatomic, assign)float damageBonus;
@property(nonatomic, assign)int limit;
@property(nonatomic, assign)float jumpVelocity;
@property(nonatomic, assign)CGPoint velocity;
@property(nonatomic, assign)float jumpHeight;
@property(nonatomic, assign)CGPoint groundPosition;
@property(nonatomic, assign)WeaponState weaponState;
@property(nonatomic, assign)float centerToBottom;
@property(nonatomic, assign)float detectionRadius;

-(CCAnimation *)animationWithPrefix:(NSString *)prefix startFrameIdx:(NSUInteger)startFrameIdx frameCount:(NSUInteger)frameCount delay:(float)delay;
-(AnimationMember *)animationMemberWithPrefix:(NSString *)prefix startFrameIdx:(NSUInteger)startFrameIdx frameCount:(NSUInteger)frameCount delay:(float)delay target:(id)target;
-(void)used;
-(void)pickedUp;
-(void)droppedFrom:(float)height to:(CGPoint)destination;
-(void)reset;

@end
