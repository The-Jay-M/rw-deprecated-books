//
//  WeightedDecision.m
//  PompaDroid
//
//  Created by Allen Tan on 6/11/14.
//
//

#import "WeightedDecision.h"

@implementation WeightedDecision

+ (instancetype)decisionWithDecision:(AIDecision)decision
                           andWeight:(CGFloat)weight
{
    return [[self alloc] initWithDecision:decision
                                andWeight:weight];
}

- (instancetype)initWithDecision:(AIDecision)decision
                       andWeight:(CGFloat)weight
{
    if (self = [super init]) {
        _decision = decision;
        _weight = weight;
    }
    
    return self;
}

@end
