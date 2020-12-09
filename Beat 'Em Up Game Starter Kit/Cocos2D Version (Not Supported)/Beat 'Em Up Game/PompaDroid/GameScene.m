//
//  GameScene.m
//  PompaDroid
//
//  Created by Ray Wenderlich on 2/8/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import "GameScene.h"
#import "GameLayer.h"
#import "HudLayer.h"

@implementation GameScene

-(id)init
{
    if ((self = [super init]))
    {
        GameLayer *gameLayer = [GameLayer node];
        [self addChild:gameLayer z:0];
        
        HudLayer *hudLayer = [HudLayer node];
        [self addChild:hudLayer z:1];
        
        hudLayer.dPad.delegate = gameLayer;
        gameLayer.hud = hudLayer;
        
        hudLayer.buttonA.delegate = gameLayer;
        hudLayer.buttonB.delegate = gameLayer;

    }
    return self;
}

+(id)nodeWithLevel:(int)level
{
    return [[self alloc] initWithLevel:level];
}

-(id)initWithLevel:(int)level
{
    if ((self = [super init]))
    {
        GameLayer *gameLayer = [GameLayer nodeWithLevel:level];
        [self addChild:gameLayer z:0];
        
        HudLayer *hudLayer = [HudLayer node];
        [self addChild:hudLayer z:1];
        
        hudLayer.dPad.delegate = gameLayer;
        gameLayer.hud = hudLayer;
        
        hudLayer.buttonA.delegate = gameLayer;
        hudLayer.buttonB.delegate = gameLayer;
    }
    return self;
}

@end
