//
//  ArtificialIntelligence.m
//  PompaDroid
//
//  Created by Ray Wenderlich on 3/13/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import "ArtificialIntelligence.h"

@implementation ArtificialIntelligence

+(id)aiWithControlledSprite:(ActionSprite *)controlledSprite targetSprite:(ActionSprite *)targetSprite
{
    return [[self alloc] initWithControlledSprite:controlledSprite targetSprite:targetSprite];
}

-(id)initWithControlledSprite:(ActionSprite *)controlledSprite targetSprite:(ActionSprite *)targetSprite
{
    if ((self = [super init]))
    {
        self.controlledSprite = controlledSprite;
        self.targetSprite = targetSprite;
        self.availableDecisions = [CCArray arrayWithCapacity:4];
        
        _attackDecision = [WeightedDecision decisionWithDecision:kDecisionAttack andWeight:0];
        _idleDecision = [WeightedDecision decisionWithDecision:kDecisionStayPut andWeight:0];
        _chaseDecision = [WeightedDecision decisionWithDecision:kDecisionChase andWeight:0];
        _moveDecision = [WeightedDecision decisionWithDecision:kDecisionMove andWeight:0];
        
        [_availableDecisions addObject:_attackDecision];
        [_availableDecisions addObject:_idleDecision];
        [_availableDecisions addObject:_chaseDecision];
        [_availableDecisions addObject:_moveDecision];
        
        _decisionDuration = 0;
    }
    return self;
}

-(AIDecision)decideWithAttackWeight:(int)attackWeight idleWeight:(int)idleWeight chaseWeight:(int)chaseWeight moveWeight:(int)moveWeight
{
    int totalWeight = attackWeight + idleWeight + chaseWeight + moveWeight;
    _attackDecision.weight = attackWeight;
    _idleDecision.weight = idleWeight;
    _chaseDecision.weight = chaseWeight;
    _moveDecision.weight = moveWeight;
    
    int choice = random_range(1, totalWeight);
    int minInclusive = 1;
    int maxExclusive = minInclusive;
    int decisionWeight;
    
    WeightedDecision *weightedDecision;
    CCARRAY_FOREACH(_availableDecisions, weightedDecision)
    {
        decisionWeight = weightedDecision.weight;
        if (decisionWeight > 0)
        {
            maxExclusive = minInclusive + decisionWeight;
            
            if (choice >= minInclusive && choice < maxExclusive)
            {
                self.decision = weightedDecision.decision;
                return weightedDecision.decision;
            }
        }
        minInclusive = maxExclusive;
    }
    return -1;
}

-(void)setDecision:(AIDecision)decision
{
    _decision = decision;
    
    if (_decision == kDecisionAttack)
    {
        [_controlledSprite attack];
        _decisionDuration = frandom_range(0.25, 1.0);
    }
    else if (_decision == kDecisionStayPut)
    {
        [_controlledSprite idle];
        _decisionDuration = frandom_range(0.25, 1.5);
    }
    else if (_decision == kDecisionChase)
    {
        float reachDistance = _targetSprite.centerToSides + _controlledSprite.attackPoints[0].offset.x + _controlledSprite.attackPoints[0].radius;
        CGPoint reachPosition = ccp(_targetSprite.groundPosition.x + (random_sign * reachDistance), _targetSprite.groundPosition.y);
        CGPoint moveDirection = ccpNormalize(ccpSub(reachPosition, _controlledSprite.groundPosition));
        [_controlledSprite walkWithDirection:moveDirection];
        _decisionDuration = frandom_range(0.5, 1.0);
    }
    else if (_decision == kDecisionMove)
    {
        float randomX = random_sign * frandom_range(20.0 * kPointFactor, 100.0 * kPointFactor);
        float randomY = random_sign * frandom_range(10.0  * kPointFactor, 40.0 * kPointFactor);
        CGPoint randomPoint = ccp(_targetSprite.groundPosition.x + randomX, _targetSprite.groundPosition.y + randomY);
        CGPoint moveDirection = ccpNormalize(ccpSub(randomPoint, _controlledSprite.groundPosition));
        [_controlledSprite walkWithDirection:moveDirection];
        _decisionDuration = frandom_range(0.25, 0.5);
    }
}

-(void)update:(ccTime)delta
{
    if (_targetSprite && _controlledSprite && _controlledSprite.actionState > kActionStateNone)
    {
        //1
        float distanceSQ = ccpDistanceSQ(_controlledSprite.groundPosition, _targetSprite.groundPosition);
        float planeDist = fabsf(_controlledSprite.shadow.position.y - _targetSprite.shadow.position.y);
        
        float combinedRadius = _controlledSprite.detectionRadius + _targetSprite.detectionRadius;
        
        BOOL samePlane = NO;
        BOOL canReach = NO;
        BOOL tooFar = YES;
        BOOL canMove = NO;
        
        //2
        if (_controlledSprite.actionState == kActionStateWalk || _controlledSprite.actionState == kActionStateIdle)
        {
            canMove = YES;
        }

        
        if (canMove)
        {
            //measure distances
            if (distanceSQ <= combinedRadius * combinedRadius)
            {
                tooFar = NO;
                
                //3
                if (fabsf(planeDist) <= kPlaneHeight)
                {
                    samePlane = YES;
                    
                    //check if any attack points can reach the target's contact points
                    int attackPointCount = _controlledSprite.attackPointCount;
                    int contactPointCount = _targetSprite.contactPointCount;
                    
                    int i, j;
                    ContactPoint attackPoint, contactPoint;
                    for (i = 0; i < attackPointCount; i++)
                    {
                        attackPoint = _controlledSprite.attackPoints[i];
                        
                        for (j = 0; j < contactPointCount; j++)
                        {
                            contactPoint = _targetSprite.contactPoints[j];
                            combinedRadius = attackPoint.radius + contactPoint.radius;
                            
                            if (ccpDistanceSQ(attackPoint.position, contactPoint.position) <= combinedRadius * combinedRadius)
                            {
                                canReach = YES;
                                break;
                            }
                        }
                        
                        if (canReach)
                        {
                            break;
                        }
                    }
                }
            }
            
            //4
            if (canReach && _decision == kDecisionChase)
            {
                self.decision = kDecisionStayPut;
            }
            
            //5
            if (_decisionDuration > 0)
            {
                _decisionDuration -= delta;
            }
            else
            {
                //6
                if (tooFar)
                {
                    self.decision = [self decideWithAttackWeight:0 idleWeight:20 chaseWeight:80 moveWeight:0];
                }
                else
                {
                    //7
                    if (samePlane)
                    {
                        if (canReach)
                        {
                            self.decision = [self decideWithAttackWeight:70 idleWeight:15 chaseWeight:0 moveWeight:15];
                        }
                        else
                        {
                            self.decision = [self decideWithAttackWeight:0 idleWeight:20 chaseWeight:50 moveWeight:30];
                        }
                        
                    }
                    else
                    {
                        self.decision = [self decideWithAttackWeight:0 idleWeight:50 chaseWeight:40 moveWeight:10];
                    }
                }
            }
        }
    }
}

@end
