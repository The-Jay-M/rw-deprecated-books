//
//  ActionSprite.h
//  PompaDroid
//
//  Created by Allen Tan on 6/11/14.
//
//

#import <SpriteKit/SpriteKit.h>

@class ActionSprite;

@protocol ActionSpriteDelegate <NSObject>

- (BOOL)actionSpriteDidAttack:(ActionSprite *)actionSprite;
- (BOOL)actionSpriteDidDie:(ActionSprite *)actionSprite;
- (void)actionSpriteDidFinishAutomatedWalking:(ActionSprite *)actionSprite;

@end

@interface ActionSprite : SKSpriteNode

//attachments
@property (strong, nonatomic) SKSpriteNode *shadow;

//actions
@property (strong, nonatomic) SKAction *idleAction;
@property (strong, nonatomic) SKAction *attackAction;
@property (strong, nonatomic) SKAction *walkAction;
@property (strong, nonatomic) SKAction *hurtAction;
@property (strong, nonatomic) SKAction *knockedOutAction;
@property (strong, nonatomic) SKAction *recoverAction;
@property (strong, nonatomic) SKAction *runAction;
@property (strong, nonatomic) SKAction *jumpRiseAction;
@property (strong, nonatomic) SKAction *jumpFallAction;
@property (strong, nonatomic) SKAction *jumpLandAction;
@property (strong, nonatomic) SKAction *jumpAttackAction;
@property (strong, nonatomic) SKAction *runAttackAction;
@property (strong, nonatomic) SKAction *dieAction;

//states
@property (assign, nonatomic) ActionState actionState;
@property (assign, nonatomic) CGFloat directionX;

//attributes
@property (assign, nonatomic) CGFloat walkSpeed;
@property (assign, nonatomic) CGFloat runSpeed;
@property (assign, nonatomic) CGFloat hitPoints;
@property (assign, nonatomic) CGFloat attackDamage;
@property (assign, nonatomic) CGFloat jumpAttackDamage;
@property (assign, nonatomic) CGFloat runAttackDamage;
@property (assign, nonatomic) CGFloat maxHitPoints;
@property (assign, nonatomic) CGFloat attackForce;

//movement
@property (assign, nonatomic) CGPoint velocity;
@property (assign, nonatomic) CGFloat jumpVelocity;
@property (assign, nonatomic) CGFloat jumpHeight;
@property (assign, nonatomic) CGPoint desiredPosition;
@property (assign, nonatomic) CGPoint groundPosition;

//measurements
@property (assign, nonatomic) CGFloat centerToSides;
@property (assign, nonatomic) CGFloat centerToBottom;

//collision
@property (strong, nonatomic) NSMutableArray *contactPoints;
@property (strong, nonatomic) NSMutableArray *attackPoints;
@property (assign, nonatomic) CGFloat detectionRadius;

@property (weak, nonatomic) id <ActionSpriteDelegate> delegate;

@property (assign, nonatomic) CGFloat actionDelay;
@property (assign, nonatomic) CGFloat attackDelayTime;

- (CGRect)feetCollisionRect;
// updates
- (void)update:(NSTimeInterval)delta;

// action methods
- (void)idle;

- (void)attack;

- (void)hurtWithDamage:(CGFloat)damage
                 force:(CGFloat)force
             direction:(CGPoint)direction;

- (void)knockoutWithDamage:(CGFloat)damage
                 direction:(CGPoint)direction;
- (void)die;

- (void)recover;

- (void)getUp;

- (void)moveWithDirection:(CGPoint)direction;

- (void)runWithDirection:(CGPoint)direction;

- (void)walkWithDirection:(CGPoint)direction;

- (void)enterFrom:(CGPoint)origin
               to:(CGPoint)destination;

- (void)exitFrom:(CGPoint)origin
              to:(CGPoint)destination;

- (void)jumpRiseWithDirection:(CGPoint)direction;

- (void)jumpCutoff;

- (void)jumpFall;

- (void)jumpLand;

- (void)jumpAttack;

- (void)runAttack;

- (void)reset;

//contact point methods
- (NSMutableArray *)contactPointArray:(NSUInteger)size;

- (void)modifyContactPointAtIndex:(const NSUInteger)pointIndex
                           offset:(const CGPoint)offset
                           radius:(const CGFloat)radius;

- (void)modifyAttackPointAtIndex:(const NSUInteger)pointIndex
                          offset:(const CGPoint)offset
                          radius:(const CGFloat)radius;

- (void)modifyPoint:(ContactPoint *)point
             offset:(const CGPoint)offset
             radius:(const CGFloat)radius;

- (ContactPoint)contactPointWithOffset:(const CGPoint)offset
                                radius:(const CGFloat)radius;

- (void)setContactPointsForAction:(ActionState)actionState;

// factory methods
- (NSMutableArray *)texturesWithPrefix:(NSString *)prefix
                         startFrameIdx:(NSInteger)startFrameIdx
                            frameCount:(NSInteger)frameCount;

- (SKAction *)animateActionForGroup:(NSMutableArray *)group
                       timePerFrame:(NSTimeInterval)timeInterval
                         frameCount:(NSInteger)frameCount;

- (SKAction *)animateActionForTextures:(NSMutableArray *)textures
                          timePerFrame:(NSTimeInterval)timeInterval;
- (void)cleanup;

@end
