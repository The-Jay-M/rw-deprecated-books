//
//  TrashCan.m
//  PompaDroid
//
//  Created by Ray Wenderlich on 4/1/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import "TrashCan.h"

@implementation TrashCan

-(id)init
{
    if ((self = [super initWithSpriteFrameName:@"trashcan.png"]))
    {
        self.objectState = kObjectStateActive;
        self.detectionRadius = 57.0 * kPointFactor;
        self.contactPointCount = 5;
        self.contactPoints = malloc(sizeof(ContactPoint) * self.contactPointCount);
        
        [self modifyContactPointAtIndex:0 offset:ccp(0.0, 2.0) radius:33.0];
        [self modifyContactPointAtIndex:1 offset:ccp(0.0, -15.0) radius:33.0];
        [self modifyContactPointAtIndex:2 offset:ccp(0.0, 26.0) radius:17.0];
        [self modifyContactPointAtIndex:3 offset:ccp(19.0, 29.0) radius:16.0];
        [self modifyContactPointAtIndex:4 offset:ccp(-23.0, -38.0) radius:10.0];
    }
    return self;
}

-(void)destroyed
{
    CCSpriteFrame *destroyedFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"trashcan_hit.png"];
    [self setDisplayFrame:destroyedFrame];
    [super destroyed];
}

-(CGRect)collisionRect
{
    return CGRectMake(self.position.x - self.contentSize.width/2 * kScaleFactor, self.position.y - self.contentSize.height/2 * kScaleFactor, 64 * kPointFactor, 32 * kPointFactor);
}

@end
