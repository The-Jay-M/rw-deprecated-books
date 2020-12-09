//
//  AnimateGroup.m
//  PompaDroid
//
//  Created by Ray Wenderlich on 2/12/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import "AnimateGroup.h"
#import "AnimationMember.h"

@implementation AnimateGroup

+(id)actionWithAnimation:(CCAnimation *)animation members:(CCArray *)members
{
    return [[self alloc] initWithAnimation:animation members:members];
}

-(id)initWithAnimation:(CCAnimation *)animation members:(CCArray *)members
{
    if ((self = [super initWithAnimation:animation]))
    {
        self.members = members;
    }
    return self;
}

+(id)actionWithAnimation:(CCAnimation *)animation memberCount:(int)memberCount
{
    return [[self alloc] initWithAnimation:animation memberCount:memberCount];
}

-(id)initWithAnimation:(CCAnimation *)animation memberCount:(int)memberCount
{
    if ((self = [super initWithAnimation:animation]))
    {
        self.members = [CCArray arrayWithCapacity:memberCount];
    }
    return self;
}

-(void)startWithTarget:(id)target
{
    [super startWithTarget:target];
    
    AnimationMember *member;
    CCARRAY_FOREACH(_members, member)
    {
        [member start];
    }
}

-(void)stop
{
    [super stop];
    
    AnimationMember *member;
    CCARRAY_FOREACH(_members, member)
    {
        [member stop];
    }
}

-(void)update:(ccTime)t
{
    [super update:t];
    
    int frameIndex = MAX(0, _nextFrame - 1);

    AnimationMember *member;
    CCARRAY_FOREACH(_members, member)
    {
        [member setFrame:frameIndex];
    }
}

@end
