//
//  GameLevelLayer.m
//  PocketCyclops
//
//  Created by Jake Gundersen on 9/24/12.
//  Copyright 2012 Jake Gundersen. All rights reserved.
//

#import "GameLevelLayer.h"
#import "HUDLayer.h"
#import "SimpleAudioEngine.h"

@interface GameLevelLayer() {
    int currentLevel;
}

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
        //1
        currentLevel = level;
        //2
        NSString *path = [[NSBundle mainBundle] pathForResource:@"levels" ofType:@"plist"];
        NSDictionary *levelsDict = [NSDictionary dictionaryWithContentsOfFile:path];
        //3
        NSString *levelString = [NSString stringWithFormat:@"level%d", level];
        NSDictionary *lvlDict = levelsDict[levelString];
        //4
        NSString *bgMusic = lvlDict[@"music"];
        //5
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:bgMusic loop:YES];
        [SimpleAudioEngine sharedEngine].backgroundMusicVolume = 0.25;
        
        //1
        CCParallaxNode *pNode = [CCParallaxNode node];
        //2
        NSArray *backGroundArray = [lvlDict objectForKey:@"background"];
        //3
        for (NSArray *nodeArrays in backGroundArray) {
            for (NSString *bgChunkFilename in nodeArrays) {
                //4
                CCSprite *bgNodeSprite = [CCSprite spriteWithFile:bgChunkFilename];
                //5
                bgNodeSprite.anchorPoint = ccp(0.0, 0.0);
                //6
                int indx = [nodeArrays indexOfObject:bgChunkFilename];
                //7
                float indx2 = (float)[backGroundArray indexOfObject:nodeArrays] + 1.0;
                float ratio = ((4.0 - (float)indx2) / 8.0);
                if (indx2 == 4.0) {
                    ratio = 0.0;
                }
                //8
                [pNode addChild:bgNodeSprite z:(int)indx2 * -1 parallaxRatio:ccp(ratio, 0.6) positionOffset:ccp((indx * 2048), 30)];
            }
        }
        //9
        [self addChild:pNode];

    }
    return self;
}



@end
