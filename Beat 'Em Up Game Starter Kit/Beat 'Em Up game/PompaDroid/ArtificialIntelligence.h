//
//  ArtificialIntelligence.h
//  PompaDroid
//
//  Created by Allen Tan on 6/11/14.
//
//

#import <Foundation/Foundation.h>
#import "ActionSprite.h"
#import "WeightedDecision.h"

@interface ArtificialIntelligence : NSObject

@property (assign, nonatomic) CGFloat decisionDuration;
@property (weak, nonatomic) ActionSprite *controlledSprite;
@property (weak, nonatomic) ActionSprite *targetSprite;
@property (assign, nonatomic) AIDecision decision;
@property (strong, nonatomic) NSMutableArray *availableDecisions;

+ (instancetype)aiWithControlledSprite:(ActionSprite *)controlledSprite targetSprite:(ActionSprite *)targetSprite;

- (instancetype)initWithControlledSprite:(ActionSprite *)controlledSprite targetSprite:(ActionSprite *)targetSprite;

- (void)update:(NSTimeInterval)delta;

@end
