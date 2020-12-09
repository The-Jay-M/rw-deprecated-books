//
//  ArtificialIntelligence.h
//  PompaDroid
//
//  Created by Ray Wenderlich on 3/13/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ActionSprite.h"
#import "WeightedDecision.h"

@interface ArtificialIntelligence : NSObject {
    WeightedDecision *_attackDecision;
    WeightedDecision *_idleDecision;
    WeightedDecision *_chaseDecision;
    WeightedDecision *_moveDecision;
}

@property(nonatomic, assign)float decisionDuration;
@property(nonatomic, weak)ActionSprite *controlledSprite;
@property(nonatomic, weak)ActionSprite *targetSprite;
@property(nonatomic, assign)AIDecision decision;
@property(nonatomic, strong)CCArray *availableDecisions;

+(id)aiWithControlledSprite:(ActionSprite *)controlledSprite targetSprite:(ActionSprite *)targetSprite;
-(id)initWithControlledSprite:(ActionSprite *)controlledSprite targetSprite:(ActionSprite *)targetSprite;
-(void)update:(ccTime)delta;

@end
