//
//  DamageNumber.m
//  PompaDroid
//
//  Created by Ray Wenderlich on 3/15/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import "DamageNumber.h"


@implementation DamageNumber

-(id)init
{
    if ((self = [super initWithString:@"0" fntFile:@"DamageFont.fnt"]))
    {
        self.damageAction = [CCSequence actions:[CCShow action], [CCMoveBy actionWithDuration:0.6 position:ccp(0.0, 40.0 * kPointFactor)], [CCHide action], nil];
    }
    return self;
}

-(void)showWithValue:(int)value fromOrigin:(CGPoint)origin
{
    self.string = [NSString stringWithFormat:@"%d", value];
    self.position = origin;
    [self stopAllActions];
    [self runAction:_damageAction];
}

@end
