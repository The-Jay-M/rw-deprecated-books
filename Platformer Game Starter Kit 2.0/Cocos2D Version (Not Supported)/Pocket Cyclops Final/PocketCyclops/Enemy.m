//
//  Enemy.m
//  PocketCyclops
//
//  Created by Ray Wenderlich on 1/23/13.
//  Copyright 2013 Jake Gundersen. All rights reserved.
//

#import "Enemy.h"


@implementation Enemy

-(id)initWithSpriteFrameName:(NSString *)spriteFrameName {
    if (self = [super initWithSpriteFrameName:spriteFrameName]) {
        self.life = 100;
    }
    return self;
}

-(void)tookHit:(Character *)character {
    self.life = self.life - 100;
    if (self.life <= 0) {
        [self changeState:kStateDead];
    }
}

-(void)removeSelf {
    self.isActive = NO;
}

@end
