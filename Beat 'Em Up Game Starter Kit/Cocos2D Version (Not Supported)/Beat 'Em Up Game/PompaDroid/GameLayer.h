//
//  GameLayer.h
//  PompaDroid
//
//  Created by Ray Wenderlich on 2/8/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Hero.h"
#import "HudLayer.h"
#import "Boss.h"

@interface GameLayer : CCLayer <ActionDPadDelegate, ActionButtonDelegate, ActionSpriteDelegate> {
    CCTMXTiledMap *_tileMap;
    CCSpriteBatchNode *_actors;
    float _runDelay;
    ActionDPadDirection _previousDirection;
    int _activeEnemies;
    float _viewPointOffset;
    float _eventCenter;
}

@property(nonatomic, strong)Hero *hero;
@property(nonatomic, weak)HudLayer *hud;
@property(nonatomic, strong)CCArray *robots;
@property(nonatomic, strong)CCArray *brains;
@property(nonatomic, strong)CCArray *battleEvents;
@property(nonatomic, strong)NSDictionary *currentEvent;
@property(nonatomic, assign)EventState eventState;
@property(nonatomic, assign)int totalLevels;
@property(nonatomic, assign)int currentLevel;
@property(nonatomic, strong)CCArray *damageNumbers;
@property(nonatomic, strong)CCArray *hitEffects;
@property(nonatomic, strong)Boss *boss;
@property(nonatomic, strong)CCArray *weapons;
@property(nonatomic, strong)CCArray *mapObjects;

+(id)nodeWithLevel:(int)level;
-(id)initWithLevel:(int)level;

@end
