//
//  WeightedDecision.m
//  PompaDroid
//
//  Created by Ray Wenderlich on 3/13/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import "WeightedDecision.h"

@implementation WeightedDecision

+(id)decisionWithDecision:(AIDecision)decision andWeight:(float)weight
{
    return [[self alloc] initWithDecision:decision andWeight:weight];
}

-(id)initWithDecision:(AIDecision)decision andWeight:(float)weight
{
    if ((self = [super init]))
    {
        _decision = decision;
        _weight = weight;
    }
    return self;
}

@end
