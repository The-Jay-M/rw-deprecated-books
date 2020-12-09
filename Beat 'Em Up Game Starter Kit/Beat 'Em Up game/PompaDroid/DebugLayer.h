//
//  DebugLayer.h
//  PompaDroid
//
//  Created by Allen Tan on 6/11/14.
//
//

#import <SpriteKit/SpriteKit.h>
#import "GameLayer.h"

@interface DebugLayer : SKNode

@property (strong, nonatomic) NSMutableArray *shapeNodes;

@property (weak, nonatomic) GameLayer *gameLayer;

+ (instancetype)nodeWithGameLayer:(GameLayer *)gameLayer;

- (instancetype)initWithGameLayer:(GameLayer *)gameLayer;

- (void)update:(NSTimeInterval)delta;

@end
