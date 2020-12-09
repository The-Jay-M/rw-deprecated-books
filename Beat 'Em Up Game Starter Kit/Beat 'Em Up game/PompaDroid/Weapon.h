//
//  Weapon.h
//  PompaDroid
//
//  Created by Allen Tan on 6/11/14.
//
//

#import <SpriteKit/SpriteKit.h>
#import "AnimationMember.h"

@class Weapon;

@protocol WeaponDelegate <NSObject>

- (void)weaponDidReachLimit:(Weapon *)weapon;

@end

@interface Weapon : SKSpriteNode

//delegate
@property(nonatomic, weak)id <WeaponDelegate> delegate;

@property (strong, nonatomic) SKSpriteNode *shadow;
@property (strong, nonatomic) AnimationMember *attack;
@property (strong, nonatomic) AnimationMember *attackTwo;
@property (strong, nonatomic) AnimationMember *attackThree;
@property (strong, nonatomic) AnimationMember *idle;
@property (strong, nonatomic) AnimationMember *walk;
@property (strong, nonatomic) SKAction *droppedAction;
@property (strong, nonatomic) SKAction *destroyedAction;
@property (assign, nonatomic) CGFloat damageBonus;
@property (assign, nonatomic) NSInteger limit;
@property (assign, nonatomic) CGFloat jumpVelocity;
@property (assign, nonatomic) CGPoint velocity;
@property (assign, nonatomic) CGFloat jumpHeight;
@property (assign, nonatomic) CGPoint groundPosition;
@property (assign, nonatomic) WeaponState weaponState;
@property (assign, nonatomic) CGFloat centerToBottom;
@property (assign, nonatomic) CGFloat detectionRadius;

- (AnimationMember *)animationMemberWithPrefix:(NSString *)prefix startFrameIdx:(NSUInteger)startFrameIdx frameCount:(NSUInteger)frameCount timePerFrame:(NSTimeInterval)timePerFrame target:(id)target;

- (void)used;

- (void)pickedUp;

- (void)droppedFrom:(CGFloat)height to:(CGPoint)destination;

- (void)reset;

- (void)update:(NSTimeInterval)delta;

- (void)cleanup;

@end
