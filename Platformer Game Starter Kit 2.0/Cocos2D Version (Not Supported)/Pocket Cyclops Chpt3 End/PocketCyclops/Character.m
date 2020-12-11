//
//  Character.m
//  PocketCyclops
//
//  Created by Ray Wenderlich on 1/9/13.
//  Copyright 2013 Jake Gundersen. All rights reserved.
//

#import "Character.h"

@implementation Character

-(void)update:(ccTime)dt {
}

-(CGRect)collisionBoundingBox {
    CGPoint diff = ccpSub(self.desiredPosition, self.position);
    return CGRectOffset(self.boundingBox, diff.x, diff.y);
}


@end
