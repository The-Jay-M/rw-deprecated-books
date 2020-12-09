//
//  Defines.h
//  PompaDroid
//
//  Created by Allen Tan on 6/10/14.
//
//

#ifndef PompaDroid_Defines_h
#define PompaDroid_Defines_h

#define BOUNDS [[UIScreen mainScreen] bounds].size
#define SCREEN (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? CGSizeMake(BOUNDS.width, BOUNDS.height) : CGSizeMake(BOUNDS.height, BOUNDS.width))
#define CENTER CGPointMake(SCREEN.width * 0.5, SCREEN.height * 0.5)
#define OFFSCREEN CGPointMake(-SCREEN.width, -SCREEN.height)
#define IS_RETINA() ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2)
#define IS_IPHONE5() ([UIScreen mainScreen].bounds.size.height == 568)
#define IS_IPAD() ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define CURTIME CACurrentMediaTime()
#define kPointFactor (IS_IPAD() ? 2.0 : 1.0)
#define kGravity 1000.0 * kPointFactor
#define kJumpForce 340.0 * kPointFactor
#define kJumpCutoff 130.0 * kPointFactor
#define kPlaneHeight 7.0 * kPointFactor
#define DRAW_DEBUG_SHAPES 0

typedef NS_ENUM(NSInteger, ActionState) {
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
};

typedef NS_ENUM(NSInteger, ColorSet) {
    kColorLess = 0,
    kColorCopper,
    kColorSilver,
    kColorGold,
    kColorRandom,
};


typedef struct _ContactPoint
{
    CGPoint position;
    CGPoint offset;
    CGFloat radius;
} ContactPoint;

typedef NS_ENUM(NSInteger, AIDecision)
{
    kDecisionAttack = 0,
    kDecisionStayPut,
    kDecisionChase,
    kDecisionMove
};

typedef NS_ENUM(NSInteger, EventState)
{
    kEventStateScripted = 0,
    kEventStateFreeWalk,
    kEventStateBattle,
    kEventStateEnd
};

typedef NS_ENUM(NSInteger, EnemyType)
{
    kEnemyRobot = 0,
    kEnemyBoss
};
typedef NS_ENUM(NSInteger, BossType)
{
    kBossNone = 0,
    kBossMohawk
};

typedef NS_ENUM(NSInteger, WeaponState)
{
    kWeaponStateNone = 0,
    kWeaponStateEquipped,
    kWeaponStateUnequipped,
    kWeaponStateDestroyed
};

typedef NS_ENUM(NSInteger, ObjectState)
{
    kObjectStateActive,
    kObjectStateDestroyed
};


#endif
