//
//  DebugLayer.m
//  PompaDroid
//
//  Created by Allen Tan on 6/11/14.
//
//

#import "DebugLayer.h"

@interface DebugLayer()

@property (assign, nonatomic) NSInteger shapeNodeIndex;

@end

@implementation DebugLayer

+ (instancetype)nodeWithGameLayer:(GameLayer *)gameLayer
{
    return [[self alloc] initWithGameLayer:gameLayer];
}

- (instancetype)initWithGameLayer:(GameLayer *)gameLayer
{
    if (self = [super init]) {
        
        _shapeNodes = [NSMutableArray arrayWithCapacity:30];
        _gameLayer = gameLayer;
        
        for (int i = 0; i < 30; ++i) {
            SKShapeNode *shapeNode = [SKShapeNode node];
            shapeNode.hidden = YES;
            shapeNode.antialiased = NO;
            [self addChild:shapeNode];
            [_shapeNodes addObject:shapeNode];
        }
    }
    
    return self;
}
// 1
- (SKShapeNode *)getNextShapeNode
{
    SKShapeNode *shapeNode;
    
    if (self.shapeNodeIndex < self.shapeNodes.count) {
        
        shapeNode = self.shapeNodes[self.shapeNodeIndex];
        shapeNode.hidden = NO;
        
    } else {
        
        shapeNode = [SKShapeNode node];
        shapeNode.antialiased = NO;
        [self addChild:shapeNode];
        [self.shapeNodes addObject:shapeNode];
    }
    
    self.shapeNodeIndex++;
    
    return shapeNode;
}

// 2
- (void)drawCircleAtPosition:(CGPoint)position
                      radius:(CGFloat)radius
                       color:(UIColor *)color
                   zPosition:(CGFloat)zPosition
{
    SKShapeNode *shapeNode = [self getNextShapeNode];
    shapeNode.position = position;
    shapeNode.path = CGPathCreateWithEllipseInRect((CGRect){ { -radius, -radius }, { radius * 2, radius * 2 } }, NULL);
    shapeNode.strokeColor = color;
    shapeNode.zPosition = zPosition;
}

// 3
- (void)drawRect:(CGRect)rect
           color:(UIColor *)color
       zPosition:(CGFloat)zPosition
{
    SKShapeNode *shapeNode = [self getNextShapeNode];
    shapeNode.position = CGPointZero;
    shapeNode.path = CGPathCreateWithRect(rect, NULL);
    shapeNode.strokeColor = color;
    shapeNode.zPosition = zPosition;
}

// 4
- (void)drawShapesForActionSprite:(ActionSprite *)sprite
{
    if (!sprite.hidden) {
        
        [self drawCircleAtPosition:sprite.position
                            radius:sprite.detectionRadius
                             color:[UIColor blueColor]
                         zPosition:sprite.zPosition];
        
        for (NSInteger i = 0; i < sprite.contactPoints.count; i++){
            
            NSValue *value = sprite.contactPoints[i];
            ContactPoint contactPoint;
            [value getValue:&contactPoint];
            
            [self drawCircleAtPosition:contactPoint.position
                                radius:contactPoint.radius
                                 color:[UIColor greenColor]
                             zPosition:sprite.zPosition];
        }
        
        for (NSInteger i = 0; i < sprite.attackPoints.count; i++) {
            
            NSValue *value = sprite.attackPoints[i];
            ContactPoint attackPoint;
            [value getValue:&attackPoint];
            
            [self drawCircleAtPosition:attackPoint.position
                                radius:attackPoint.radius
                                 color:[UIColor redColor]
                             zPosition:sprite.zPosition];
        }
        
        [self drawRect:sprite.feetCollisionRect
                 color:[UIColor yellowColor]
             zPosition:sprite.zPosition];
    }
}

- (void)update:(NSTimeInterval)delta
{
    self.position = self.gameLayer.position;
    self.shapeNodeIndex = 0;
    
    [self drawShapesForActionSprite:self.gameLayer.hero];
    
    for (ActionSprite *robot in self.gameLayer.robots) {
        [self drawShapesForActionSprite:robot];
    }
}


@end
