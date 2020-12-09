//
//  WeightedDecision.h
//  PompaDroid
//
//  Created by Ray Wenderlich on 3/13/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeightedDecision : NSObject {
    AIDecision _decision;
    int _weight;
}

@property(nonatomic, assign)AIDecision decision;
@property(nonatomic, assign)int weight;

+(id)decisionWithDecision:(AIDecision)decision andWeight:(float)weight;
-(id)initWithDecision:(AIDecision)decision andWeight:(float)weight;

@end
