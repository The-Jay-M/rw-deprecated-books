//
//  WeightedDecision.h
//  PompaDroid
//
//  Created by Allen Tan on 6/11/14.
//
//

#import <Foundation/Foundation.h>

@interface WeightedDecision : NSObject

@property (assign, nonatomic) AIDecision decision;
@property (assign, nonatomic) NSInteger weight;

+ (instancetype)decisionWithDecision:(AIDecision)decision
                           andWeight:(CGFloat)weight;

- (instancetype)initWithDecision:(AIDecision)decision
                       andWeight:(CGFloat)weight;

@end
