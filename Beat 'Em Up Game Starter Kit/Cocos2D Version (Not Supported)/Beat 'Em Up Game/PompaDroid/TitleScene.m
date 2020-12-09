//
//  TitleScene.m
//  PompaDroid
//
//  Created by Ray Wenderlich on 2/8/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import "TitleScene.h"
#import "TitleLayer.h"

@implementation TitleScene

-(id)init
{
    if ((self = [super init]))
    {
        TitleLayer *titleLayer = [TitleLayer node];
        [self addChild:titleLayer];
    }
    return self;
}

@end
