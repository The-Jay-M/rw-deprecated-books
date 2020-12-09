//
//  ArtificialIntelligence.m
//  PompaDroid
//
//  Created by Allen Tan on 6/11/14.
//
//

#import "ArtificialIntelligence.h"

@interface ArtificialIntelligence()

@property (strong, nonatomic) WeightedDecision *attackDecision;
@property (strong, nonatomic) WeightedDecision *idleDecision;
@property (strong, nonatomic) WeightedDecision *chaseDecision;
@property (strong, nonatomic) WeightedDecision *moveDecision;

@end

@implementation ArtificialIntelligence

+ (instancetype)aiWithControlledSprite:(ActionSprite *)controlledSprite targetSprite:(ActionSprite *)targetSprite
{
    return [[self alloc] initWithControlledSprite:controlledSprite targetSprite:targetSprite];
}

- (instancetype)initWithControlledSprite:(ActionSprite *)controlledSprite targetSprite:(ActionSprite *)targetSprite
{
    if (self = [super init]) {
        
        _controlledSprite = controlledSprite;
        _targetSprite = targetSprite;
        _availableDecisions = [NSMutableArray arrayWithCapacity:4];
        
        _attackDecision =
        [WeightedDecision decisionWithDecision:kDecisionAttack
                                     andWeight:0];
        
        _idleDecision =
        [WeightedDecision decisionWithDecision:kDecisionStayPut
                                     andWeight:0];
        
        _chaseDecision =
        [WeightedDecision decisionWithDecision:kDecisionChase
                                     andWeight:0];
        
        _moveDecision =
        [WeightedDecision decisionWithDecision:kDecisionMove
                                     andWeight:0];
        
        [_availableDecisions addObject:_attackDecision];
        [_availableDecisions addObject:_idleDecision];
        [_availableDecisions addObject:_chaseDecision];
        [_availableDecisions addObject:_moveDecision];
        
        _decisionDuration = 0;
        
    }
    return self;
}

- (AIDecision)decideWithAttackWeight:(int)attackWeight
                          idleWeight:(int)idleWeight
                         chaseWeight:(int)chaseWeight
                          moveWeight:(int)moveWeight
{
    int totalWeight =
    attackWeight + idleWeight + chaseWeight + moveWeight;
    
    self.attackDecision.weight = attackWeight;
    self.idleDecision.weight = idleWeight;
    self.chaseDecision.weight = chaseWeight;
    self.moveDecision.weight = moveWeight;
    
    int choice = RandomIntRange(1, totalWeight);
    NSInteger minInclusive = 1;
    NSInteger maxExclusive = minInclusive;
    NSInteger decisionWeight;
    
    WeightedDecision *weightedDecision;
    
    for (weightedDecision in self.availableDecisions) {
        decisionWeight = weightedDecision.weight;
        
        if (decisionWeight > 0) {
            maxExclusive = minInclusive + decisionWeight;
            
            if (choice >= minInclusive && choice < maxExclusive) {
                
                self.decision = weightedDecision.decision;
                return weightedDecision.decision;
            }
        }
        minInclusive = maxExclusive;
    }
    return -1;
}

- (void)setDecision:(AIDecision)decision
{
    _decision = decision;
    
    if (_decision == kDecisionAttack) {
        
        [self.controlledSprite attack];
        self.decisionDuration = RandomFloatRange(0.25, 1.0);
        
    } else if (_decision == kDecisionStayPut) {
        
        [self.controlledSprite idle];
        self.decisionDuration = RandomFloatRange(0.25, 1.5);
    }
    else if (_decision == kDecisionChase) {
        
        NSValue *value = self.controlledSprite.attackPoints[0];
        
        ContactPoint contactPoint;
        [value getValue:&contactPoint];
        
        CGFloat reachDistance = self.targetSprite.centerToSides +    contactPoint.offset.x + contactPoint.radius;
        CGPoint reachPosition = CGPointMake(self.targetSprite.groundPosition.x + (RandomSign() * reachDistance), self.targetSprite.groundPosition.y);
        CGPoint moveDirection = CGPointNormalize(CGPointSubtract(reachPosition, self.controlledSprite.groundPosition));
        [self.controlledSprite walkWithDirection:moveDirection];
        self.decisionDuration = RandomFloatRange(0.5, 1.0);
        
    } else if (_decision == kDecisionMove) {
        
        CGFloat randomX = RandomSign() * RandomFloatRange(20.0 * kPointFactor, 100.0 * kPointFactor);
        CGFloat randomY = RandomSign() * RandomFloatRange(10.0 * kPointFactor, 40.0 * kPointFactor);
        CGPoint randomPoint = CGPointMake(self.targetSprite.groundPosition.x + randomX, self.targetSprite.groundPosition.y + randomY);
        CGPoint moveDirection = CGPointNormalize(CGPointSubtract(randomPoint, self.controlledSprite.groundPosition));
        [self.controlledSprite walkWithDirection:moveDirection];
        self.decisionDuration = RandomFloatRange(0.25, 0.5);
    }
}
- (void)update:(NSTimeInterval)delta
{
    if (self.targetSprite && self.controlledSprite &&
        self.controlledSprite.actionState > kActionStateNone) {
        
        //1
        CGFloat distanceSQ = CGPointDistanceSQ(self.controlledSprite.groundPosition, self.targetSprite.groundPosition);
        
        CGFloat planeDist = fabsf(self.controlledSprite.shadow.position.y - self.targetSprite.shadow.position.y);
        
        CGFloat combinedRadius = self.controlledSprite.detectionRadius + self.targetSprite.detectionRadius;
        
        BOOL samePlane = NO;
        BOOL canReach = NO;
        BOOL tooFar = YES;
        BOOL canMove = NO;
        
        //2
        if (self.controlledSprite.actionState == kActionStateWalk ||
            self.controlledSprite.actionState == kActionStateIdle)
        {
            canMove = YES;
        }
        
        if (canMove) {
            //measure distances
            if (distanceSQ <= combinedRadius * combinedRadius) {
                
                tooFar = NO;
                
                //3
                if (fabsf(planeDist) <= kPlaneHeight) {
                    
                    samePlane = YES;
                    
                    //check if any attack points can reach the target's contact points
                    
                    NSInteger attackPointCount =
                    self.controlledSprite.attackPoints.count;
                    
                    NSInteger contactPointCount =
                    self.targetSprite.contactPoints.count;
                    
                    NSInteger i, j;
                    ContactPoint attackPoint, contactPoint;
                    for (i = 0; i < attackPointCount; i++) {
                        
                        NSValue *value =
                        self.controlledSprite.attackPoints[i];
                        
                        [value getValue:&attackPoint];
                        
                        for (j = 0; j < contactPointCount; j++) {
                            
                            NSValue *value =
                            self.targetSprite.contactPoints[j];
                            
                            [value getValue:&contactPoint];
                            
                            combinedRadius =
                            attackPoint.radius + contactPoint.radius;
                            
                            if (CGPointDistanceSQ(attackPoint.position, contactPoint.position) <= combinedRadius * combinedRadius) {
                                canReach = YES;
                                break;
                            }
                        }
                        
                        if (canReach) {
                            break;
                        }
                    }
                }
            }
            
            //4
            if (canReach && _decision == kDecisionChase) {
                self.decision = kDecisionStayPut;
            }
            
            //5
            if (self.decisionDuration > 0) {
                self.decisionDuration -= delta;
                
            } else {
                //6
                if (tooFar) {
                    self.decision = [self decideWithAttackWeight:0
                                                      idleWeight:20
                                                     chaseWeight:80
                                                      moveWeight:0];
                } else {
                    //7
                    if (samePlane) {
                        
                        if (canReach) {
                            self.decision = [self decideWithAttackWeight:70
                                                              idleWeight:15
                                                             chaseWeight:0
                                                              moveWeight:15];
                        } else {
                            self.decision = [self decideWithAttackWeight:0
                                                              idleWeight:20
                                                             chaseWeight:50
                                                              moveWeight:30];
                        }
                        
                    } else {
                        self.decision = [self decideWithAttackWeight:0
                                                          idleWeight:50
                                                         chaseWeight:40
                                                          moveWeight:10];
                    }
                }
            }
        }
    }
}


@end
