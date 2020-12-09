//
//  MapObject.m
//  PompaDroid
//
//  Created by Allen Tan on 6/11/14.
//
//

#import "MapObject.h"

@implementation MapObject

- (void)dealloc
{
    free(self.contactPoints);
}

- (void)destroyed
{
    self.objectState = kObjectStateDestroyed;
}

- (CGRect)collisionRect
{
    return CGRectZero;
}

- (void)setPosition:(CGPoint)position
{
    [super setPosition:position];
    [self transformPoints];
}

- (void)transformPoints
{
    for (NSInteger i = 0; i < _contactPointCount; i++) {
        CGPoint point = CGPointMake(self.contactPoints[i].offset.x,
                                    self.contactPoints[i].offset.y);
        
        self.contactPoints[i].position =
        CGPointAdd(self.position, point);
    }
}

- (void)modifyContactPointAtIndex:(const NSUInteger)pointIndex
                           offset:(const CGPoint)offset
                           radius:(const CGFloat)radius
{
    ContactPoint *contactPoint = &self.contactPoints[pointIndex];
    [self modifyPoint:contactPoint offset:offset radius:radius];
}

- (void)modifyPoint:(ContactPoint *)point
             offset:(const CGPoint)offset
             radius:(const CGFloat)radius
{
    point->offset = CGPointMultiplyScalar(offset, kPointFactor);
    point->radius = radius * kPointFactor;
    point->position = CGPointAdd(self.position, point->offset);
}

@end
