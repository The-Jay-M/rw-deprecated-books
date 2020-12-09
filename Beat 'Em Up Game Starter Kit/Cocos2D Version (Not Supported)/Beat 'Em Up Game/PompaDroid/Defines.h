//
//  Defines.h
//  PompaDroid
//
//  Created by Ray Wenderlich on 2/8/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#ifndef PompaDroid_Defines_h
#define PompaDroid_Defines_h

#define SCREEN [[CCDirector sharedDirector] winSize]
#define CENTER ccp(SCREEN.width/2, SCREEN.height/2)
#define OFFSCREEN ccp(-SCREEN.width, -SCREEN.height)
#define IS_RETINA() ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2)
#define IS_IPHONE5() ([[CCDirector sharedDirector] winSize].width == 568)
#define IS_IPAD() ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define CURTIME CACurrentMediaTime()
#define kPointFactor (IS_IPAD() ? 2.0 : 1.0)
#define kScaleFactor (kPointFactor * (IS_RETINA() ? 2.0 : 1.0))
#define kGravity 1000.0 * kPointFactor
#define kJumpForce 340.0 * kPointFactor
#define kJumpCutoff 130.0 * kPointFactor
#define kPlaneHeight 7.0 * kPointFactor

typedef enum _ActionState
{
    kActionStateNone = 0,
    kActionStateIdle,
    kActionStateAttack,
    kActionStateAttackTwo,
    kActionStateAttackThree,
    kActionStateWalk,
    kActionStateRun,
    kActionStateRunAttack,
    kActionStateJumpRise,
    kActionStateJumpFall,
    kActionStateJumpLand,
    kActionStateJumpAttack,
    kActionStateHurt,
    kActionStateKnockedOut,
    kActionStateRecover,
    kActionStateDead,
    kActionStateAutomated,
} ActionState;

typedef struct _ContactPoint
{
    CGPoint position;
    CGPoint offset;
    CGFloat radius;
} ContactPoint;

typedef enum _ColorSet
{
    kColorLess = 0,
    kColorCopper,
    kColorSilver,
    kColorGold,
    kColorRandom,
} ColorSet;

typedef enum _AIDecision
{
    kDecisionAttack = 0,
    kDecisionStayPut,
    kDecisionChase,
    kDecisionMove
} AIDecision;

typedef enum _EventState
{
    kEventStateScripted = 0,
    kEventStateFreeWalk,
    kEventStateBattle,
    kEventStateEnd
} EventState;

typedef enum _EnemyType
{
    kEnemyRobot = 0,
    kEnemyBoss
} EnemyType;

typedef enum _BossType
{
    kBossNone = 0,
    kBossMohawk
} BossType;

typedef enum _WeaponState
{
    kWeaponStateNone = 0,
    kWeaponStateEquipped,
    kWeaponStateUnequipped,
    kWeaponStateDestroyed
} WeaponState;

typedef enum _ObjectState
{
    kObjectStateActive,
    kObjectStateDestroyed
} ObjectState;

#define kTagButtonA 1
#define kTagButtonB 2

#define random_range(low,high) ((arc4random()%(high-low+1))+low)
#define frandom ((float)arc4random()/UINT64_C(0x100000000))
#define frandom_range(low,high) (((high-low)*frandom)+low)
#define random_sign (arc4random() % 2 ? 1 : -1)

#define DRAW_DEBUG_SHAPES 0

#define COLOR_FULLHP ccc3(95,  255, 106)
#define COLOR_MIDHP ccc3(255, 165, 0)
#define COLOR_LOWHP ccc3(255, 50, 23)

#endif
