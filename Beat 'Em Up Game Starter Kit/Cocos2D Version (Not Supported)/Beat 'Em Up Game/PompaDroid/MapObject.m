//
//  MapObject.m
//  PompaDroid
//
//  Created by Ray Wenderlich on 4/1/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import "MapObject.h"

@implementation MapObject

-(void)destroyed
{
    self.objectState = kObjectStateDestroyed;
}

-(CGRect)collisionRect
{
    return CGRectZero;
}

-(void)dealloc
{
    free(_contactPoints);
}

-(void)setPosition:(CGPoint)position
{
    [super setPosition:position];
    [self transformPoints];
}

-(void)transformPoints
{
    int i;
    for (i = 0; i < _contactPointCount; i++)
    {
        _contactPoints[i].position = ccpAdd(_position, ccp(_contactPoints[i].offset.x, _contactPoints[i].offset.y));
    }
}

-(void)modifyContactPointAtIndex:(const NSUInteger)pointIndex offset:(const CGPoint)offset radius:(const float)radius
{
    ContactPoint *contactPoint = &_contactPoints[pointIndex];
    [self modifyPoint:contactPoint offset:offset radius:radius];
}

-(void)modifyPoint:(ContactPoint *)point offset:(const CGPoint)offset radius:(const float)radius
{
    point->offset = ccpMult(offset, kPointFactor);
    point->radius = radius * kPointFactor;
    point->position = ccpAdd(_position, point->offset);
}

@end
