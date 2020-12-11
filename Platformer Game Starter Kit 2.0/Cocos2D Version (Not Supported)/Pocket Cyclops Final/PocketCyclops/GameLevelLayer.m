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
#import "Crawler.h"
#import "Flyer.h"
#import "PowerUp.h"

@interface GameLevelLayer() {
    int currentLevel;
    PCTMXTiledMap *map;
    Player *player; 
    CCTMXLayer *walls;
    NSMutableArray *enemiesArray;
    NSMutableArray *powerUpsArray;
    CGPoint exitPoint;
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

-(void)setViewpointCenter:(CGPoint) position {
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    int x = MAX(position.x, winSize.width / 2);
    int y = MAX(position.y, winSize.height / 2);
    x = MIN(x, (map.mapSize.width * map.tileSize.width)
            - winSize.width / 2);
    y = MIN(y, (map.mapSize.height * map.tileSize.height)
            - winSize.height/2);
    CGPoint actualPosition = ccp(x, y);
    
    CGPoint centerOfView = ccp(winSize.width/2, winSize.height/2);
    CGPoint viewPoint = ccpSub(centerOfView, actualPosition);
    self.position = viewPoint;
    
}

-(void)checkForAndResolveCollisions:(Character *)c {
    //1
    NSArray *tiles = [map getSurroundingTilesAtPosition:c.position forLayer:walls];
    c.onGround = NO; //////Here
    c.onWall = NO;
    
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
                    c.onWall = YES; 
                    c.velocity = ccp(0.0, c.velocity.y);
                } else if (tileIndx == 3) {
                    //tile is right of the Character
                    c.desiredPosition = ccp(c.desiredPosition.x - intersection.size.width, c.desiredPosition.y);
                    c.onWall = YES; 
                    c.velocity = ccp(0.0, c.velocity.y);
                } 
                else {
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
                        
                        if (tileIndx == 6 || tileIndx == 7) {
                            c.onWall = YES;
                        }
                   
                        c.velocity = ccp(0.0, c.velocity.y);
                   
                    }                    
                }
            }
        }
        //8
        c.position = c.desiredPosition;
    }
}

-(void)checkForEnemyCollisions:(Enemy *)e {
    //1
    if (e.isActive && player.isActive) {
        //2
        if (CGRectIntersectsRect(player.collisionBoundingBox, e.collisionBoundingBox)) {
            //3
            CGPoint playerFootPoint = ccp(player.position.x, player.position.y - player.collisionBoundingBox.size.height / 2);
            //4
            if (player.velocity.y < 0 && playerFootPoint.y > e.position.y) {
                //5
                [player bounce];
                [e tookHit:player];  
            } else {
                [player tookHit:e];
            }
        }
    }
}

-(void)loadEnemies {
    CCTMXObjectGroup *enemies = [map objectGroupNamed:@"enemies"];
    
    enemiesArray = [NSMutableArray array];
    //1
    NSMutableArray *enemyTypes = [NSMutableArray array];
    NSMutableArray *enemyBatchNodes = [NSMutableArray array];
    
    for (NSDictionary *enemy in enemies.objects) {
        //2
        NSString *enemyType = [enemy objectForKey:@"type"];
        //3
        if (![enemyTypes containsObject:enemyType]) {
            //4
            NSString *spriteFramesFile = [NSString stringWithFormat:@"%@Images.plist", enemyType];
            //5
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: spriteFramesFile];
            //6
            CCSpriteBatchNode *enemyBatchNode = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"%@Images.png", enemyType]];
            //7
            [self addChild:enemyBatchNode];
            //8
            [enemyTypes addObject:enemyType];
            //9
            [enemyBatchNodes addObject:enemyBatchNode];
        }
        //10
        NSString *firstFrameName = [NSString stringWithFormat:@"%@1.png", enemyType];
        //11
        Enemy *enemyInstance = [[NSClassFromString(enemyType) alloc] initWithSpriteFrameName:firstFrameName];
        //12
        enemyInstance.position = ccp([[enemy objectForKey:@"x"] floatValue], [[enemy objectForKey:@"y"] floatValue]);
        //13
        enemyInstance.player = player;
        enemyInstance.map = map;
        //14
        int enemyIndx = [enemyTypes indexOfObject:enemyType];
        CCSpriteBatchNode *node = [enemyBatchNodes objectAtIndex:enemyIndx];
        //15
        [node addChild:enemyInstance];
        [enemiesArray addObject:enemyInstance];
    }
}

-(void)loadPowerUps {
    //1
    CCTMXObjectGroup *powerUps = [map objectGroupNamed:@"powerups"];
    //2
    powerUpsArray = [NSMutableArray array];
    //3
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"PowerUpsImages.plist"];
    //4
    for (NSDictionary *powerUp in powerUps.objects) {
        //5
        NSString *powerUpType = [powerUp objectForKey:@"type"];
        //6
        NSString *spriteFrameName = [NSString stringWithFormat:@"%@.png", powerUpType];
        //7
        PowerUp *pu = [[PowerUp alloc] initWithSpriteFrameName:spriteFrameName];
        //8
        pu.position = ccp([[powerUp objectForKey:@"x"] floatValue], [[powerUp objectForKey:@"y"] floatValue]);
        //9
        pu.powerUpType = powerUpType;
        //10
        [powerUpsArray addObject:pu];
        [self addChild:pu];
    }
}

-(void)checkForPowerUpsCollisions {
    //1
    NSMutableArray *removeArray = [NSMutableArray array];
    //2
    for (PowerUp *p in powerUpsArray) {
        //3
        if (CGRectIntersectsRect([player collisionBoundingBox], p.boundingBox)) {
            //4
            if ([p.powerUpType isEqualToString:@"DoubleJump"]) {
                player.canDoubleJump = YES;
            } else {
                player.canWallSlide = YES;
            }
            //5
            [removeArray addObject:p];
        }
    }
    //6
    for (PowerUp *p in removeArray) {
        //7
        [powerUpsArray removeObject:p];
        [p removeFromParentAndCleanup:YES];
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
                [pNode addChild:bgNodeSprite z:(int)indx2 * -1 parallaxRatio:ccp(ratio, 0.6) positionOffset:ccp((indx * 1024), 30)];
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
        player.canDoubleJump = [[lvlDict objectForKey:@"doubleJump"] boolValue];
        player.canWallSlide = [[lvlDict objectForKey:@"wallSlide"] boolValue];

        [self loadEnemies];
        [self loadPowerUps];
        
        NSDictionary *exit = [og objectNamed:@"exit"];
        exitPoint = ccp([exit[@"x"] floatValue] + ([exit[@"width"] floatValue] / 2), [exit[@"y"] floatValue] + ([exit[@"height"] floatValue] / 2));
        
        [self scheduleUpdate];
        
    }
    return self;
}

-(void)checkForExit {
    //1
    float distanceToExit = ccpDistance(player.position, exitPoint);
    if (distanceToExit < 100) {
        //2
        if (currentLevel < 3) {
            //3
            int nextLevel = currentLevel + 1;
            [[CCDirector sharedDirector] replaceScene:[GameLevelLayer sceneWithLevel:nextLevel]];
        } else {
            //4
            CCLabelTTF *win = [CCLabelTTF labelWithString:@"You Win" fontName:@"Marker Felt" fontSize:60];
            CGSize winSize = [[CCDirector sharedDirector] winSize];
            win.position = ccp(winSize.width / 2.0 - self.position.x, 160 - self.position.y);
            [self addChild:win];
            //5
            [self performSelector:@selector(restart) withObject:nil afterDelay:3.0];
        }
    }
}

-(void)gameEnded {
    CCLabelTTF *gameOver = [CCLabelTTF labelWithString:@"You Lose" fontName:@"Marker Felt" fontSize:60];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    gameOver.position = ccp(winSize.width / 2.0 - self.position.x, 160 - self.position.y);
    
    [self addChild:gameOver];
    [self performSelector:@selector(restart) withObject:nil afterDelay:5.0];
}

-(void)restart {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"restart" object:nil];
}

-(void)update:(ccTime)dt {
    [player update:dt];
    [self checkForAndResolveCollisions:player];
    
    //1
    NSMutableArray *enemiesThatNeedDeleting = [NSMutableArray array];
    
    for (Enemy *e in enemiesArray) {
        [e update:dt];
        [self checkForAndResolveCollisions:e];
        [self checkForEnemyCollisions:e];
        
        //2
        if (!e.isActive && e.characterState == kStateDead) {
            [enemiesThatNeedDeleting addObject:e];
        }
        
    }
    
    //3
    for (Enemy *e in enemiesThatNeedDeleting) {
        [enemiesArray removeObject:e];
        [e removeFromParentAndCleanup:YES];
    }
    
    [self checkForPowerUpsCollisions];
    [self checkForExit];
    [self setViewpointCenter:player.position];
}

@end
