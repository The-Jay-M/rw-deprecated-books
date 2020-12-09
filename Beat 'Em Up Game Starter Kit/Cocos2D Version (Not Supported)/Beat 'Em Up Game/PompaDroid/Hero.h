//
//  Hero.h
//  PompaDroid
//
//  Created by Ray Wenderlich on 2/8/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ActionSprite.h"
#import "Weapon.h"
#import "AnimateGroup.h"

@interface Hero : ActionSprite <WeaponDelegate> {
    float _hurtTolerance;
    float _recoveryRate;
    float _hurtLimit;
    float _attackTwoDelayTime;
    float _attackThreeDelayTime;
    float _chainTimer;
    AnimateGroup *_attackGroup;
    AnimateGroup *_attackTwoGroup;
    AnimateGroup *_attackThreeGroup;
    AnimateGroup *_idleGroup;
    AnimateGroup *_walkGroup;
}

@property(nonatomic, strong)id attackTwoAction;
@property(nonatomic, strong)id attackThreeAction;
@property(nonatomic, assign)float attackTwoDamage;
@property(nonatomic, assign)float attackThreeDamage;
@property(nonatomic, weak)Weapon *weapon;

-(void)dropWeapon;
-(BOOL)pickUpWeapon:(Weapon *)weapon;

@end
