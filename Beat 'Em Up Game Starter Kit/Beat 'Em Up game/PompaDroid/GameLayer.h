//
//  GameLayer.h
//  PompaDroid
//
//  Created by Allen Tan on 6/10/14.
//
//

#import <SpriteKit/SpriteKit.h>
#import "JSTileMap.h"
#import "Hero.h"
#import "HudLayer.h"
#import "Boss.h"

@interface GameLayer : SKNode <ActionDPadDelegate, ActionButtonDelegate, ActionSpriteDelegate>

@property (strong, nonatomic) JSTileMap *tileMap;
@property (strong, nonatomic) Hero *hero;
@property (weak, nonatomic) HudLayer *hud;
@property (strong, nonatomic) NSMutableArray *robots;
@property (strong, nonatomic) NSMutableArray *brains;
@property (strong, nonatomic) NSMutableArray *battleEvents;
@property (strong, nonatomic) NSDictionary *currentEvent;
@property (assign, nonatomic) EventState eventState;
@property (assign, nonatomic) NSInteger totalLevels;
@property (assign, nonatomic) NSInteger currentLevel;
@property (strong, nonatomic) NSMutableArray *damageNumbers;
@property (strong, nonatomic) NSMutableArray *hitEffects;
@property (strong, nonatomic) Boss *boss;
@property (strong, nonatomic) NSMutableArray *weapons;
@property (strong, nonatomic) NSMutableArray *mapObjects;

- (void)update:(NSTimeInterval)delta;
- (void)startGame;
+ (instancetype)nodeWithLevel:(NSInteger)level;
- (instancetype)initWithLevel:(NSInteger)level;

@end
