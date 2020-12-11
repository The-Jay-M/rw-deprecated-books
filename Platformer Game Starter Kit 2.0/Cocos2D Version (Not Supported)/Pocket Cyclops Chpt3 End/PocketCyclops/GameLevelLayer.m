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
#import "PCTMXTiledMap.h"
#import "Player.h"

@interface GameLevelLayer() {
    int currentLevel;
    PCTMXTiledMap *map;
    Player *player; 
    CCTMXLayer *walls;
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

-(void)checkForAndResolveCollisions:(Character *)c {
    //1
    NSArray *tiles = [map getSurroundingTilesAtPosition:c.position forLayer:walls];
    c.onGround = NO; //////Here
    
    for (NSDictionary *dic in tiles) {
        //2
        CGRect pRect = [c collisionBoundingBox];
        //3
        int gid = [[dic objectForKey:@"gid"] intValue];
        
        if (gid) {
            //4
            CGRect tileRect = CGRectMake([[dic objectForKey:@"x"] floatValue], [[dic objectForKey:@"y"] floatValue], map.tileSize.width, map.tileSize.height);
            //5
            if (CGRectIntersectsRect(pRect, tileRect)) {

                CGRect intersection = CGRectIntersection(pRect, tileRect);
                //6
                int tileIndx = [tiles indexOfObject:dic];
                
                if (tileIndx == 0) {
                    //tile is directly below the Character
                    c.desiredPosition = ccp(c.desiredPosition.x, c.desiredPosition.y + intersection.size.height);
                    c.velocity = ccp(c.velocity.x, 0.0); //////Here
                    c.onGround = YES; ///////Here

                } else if (tileIndx == 1) {
                    //tile is directly above the Character
                    c.desiredPosition = ccp(c.desiredPosition.x, c.desiredPosition.y - intersection.size.height);
                    c.velocity = ccp(c.velocity.x, 0.0); //////Here
                } else if (tileIndx == 2) {
                    //tile is left of the Character
                    c.desiredPosition = ccp(c.desiredPosition.x + intersection.size.width, c.desiredPosition.y);
                } else if (tileIndx == 3) {
                    //tile is right of the Character
                    c.desiredPosition = ccp(c.desiredPosition.x - intersection.size.width, c.desiredPosition.y);
                } else {
                    if (intersection.size.width > intersection.size.height) {
                        //7
                        //tile is diagonal, but resolving collision vertically
                        float resolutionHeight;
                        if (tileIndx > 5) {
                            resolutionHeight = intersection.size.height;
                            
                            if (c.velocity.y < 0) { ///////Here
                                c.onGround = YES; ///////Here
                                c.velocity = ccp(c.velocity.x, 0.0); ///////Here
                            }  ///////Here
                        } else {
                            resolutionHeight = -intersection.size.height;
                            
                            if (c.velocity.y > 0) { ///////Here
                                c.velocity = ccp(c.velocity.x, 0.0); ///////Here
                            }  ///////Here
                        }
                        c.desiredPosition = ccp(c.desiredPosition.x, c.desiredPosition.y + resolutionHeight);
                    } else {
                        //tile is diagonal, but resolving horizontally
                        float resolutionWidth;
                        if (tileIndx == 6 || tileIndx == 4) {
                            resolutionWidth = intersection.size.width;
                        } else {
                            resolutionWidth = -intersection.size.width;
                        }
                        c.desiredPosition = ccp(c.desiredPosition.x + resolutionWidth, c.desiredPosition.y);
                    }
                }
            }
        }
        //8
        c.position = c.desiredPosition;
    }
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

        NSString *lvlString = [lvlDict objectForKey:@"level"];
        map = [PCTMXTiledMap tiledMapWithTMXFile:lvlString];
        [self addChild:map];
        
        walls = [map layerNamed:@"walls"];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache]
         addSpriteFramesWithFile:@"PlayerImages.plist"];
        
        player = [[Player alloc]
                  initWithSpriteFrameName:@"Player1.png"];
        [self addChild:player];
        
        CCTMXObjectGroup *og = [map objectGroupNamed:@"objects"];
        NSDictionary *playerObj = [og objectNamed:@"player"];
        player.position = ccp([playerObj[@"x"] floatValue], [playerObj[@"y"] floatValue]);
        
        [self scheduleUpdate];
        
    }
    return self;
}

-(void) update:(ccTime)dt {
    [player update:dt];
    [self checkForAndResolveCollisions:player];
}

@end
