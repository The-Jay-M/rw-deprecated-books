//
//  MapObject.h
//  PompaDroid
//
//  Created by Allen Tan on 6/11/14.
//
//

#import <SpriteKit/SpriteKit.h>

@interface MapObject : SKSpriteNode

@property (assign, nonatomic) CGFloat detectionRadius;
@property (assign, nonatomic) ContactPoint *contactPoints;
@property (assign, nonatomic) NSInteger contactPointCount;
@property (assign, nonatomic) ObjectState objectState;

- (CGRect)collisionRect;

- (void)modifyContactPointAtIndex:(const NSUInteger)pointIndex
                           offset:(const CGPoint)offset
                           radius:(const CGFloat)radius;
- (void)destroyed;

@end
