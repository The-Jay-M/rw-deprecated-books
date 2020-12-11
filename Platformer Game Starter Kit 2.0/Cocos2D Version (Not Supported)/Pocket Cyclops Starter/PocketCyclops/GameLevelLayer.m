//
//  GameLevelLayer.m
//  PocketCyclops
//
//  Created by Jake Gundersen on 9/24/12.
//  Copyright 2012 Jake Gundersen. All rights reserved.
//

#import "GameLevelLayer.h"
#import "HUDLayer.h"

@interface GameLevelLayer() 
@end

@implementation GameLevelLayer

+(CCScene *)sceneWithLevel:(int)level {
    CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameLevelLayer *layer = [[GameLevelLayer alloc] initWithLevel:level];
	HUDLayer *hudLayer = [HUDLayer node];
    
	// add layer as a child to scene
	[scene addChild:hudLayer z:1 tag:25];
    [scene addChild:layer];
	
	// return the scene
	return scene;
}



+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameLevelLayer *layer = [GameLevelLayer node];
	HUDLayer *hudLayer = [HUDLayer node];
    
	// add layer as a child to scene
	[scene addChild:hudLayer z:1 tag:25];
    [scene addChild:layer];
	
	// return the scene
	return scene;
}

-(id)init {
    return [self initWithLevel:1];
}

// on "init" you need to initialize your instance
-(id) initWithLevel:(int)level
{
    if( (self=[super init])) {
                
	}
	return self;
}



@end
