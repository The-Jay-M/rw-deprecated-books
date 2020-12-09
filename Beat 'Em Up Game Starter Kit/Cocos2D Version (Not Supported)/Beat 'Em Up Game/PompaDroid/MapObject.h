//
//  MapObject.h
//  PompaDroid
//
//  Created by Ray Wenderlich on 4/1/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface MapObject : CCSprite {
}

@property(nonatomic, assign)float detectionRadius;
@property(nonatomic, assign)ContactPoint *contactPoints;
@property(nonatomic, assign)int contactPointCount;
@property(nonatomic, assign)ObjectState objectState;

-(CGRect)collisionRect;
-(void)modifyContactPointAtIndex:(const NSUInteger)pointIndex offset:(const CGPoint)offset radius:(const float)radius;
-(void)destroyed;

@end
