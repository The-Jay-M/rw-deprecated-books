//
//  GameLayer.m
//  PompaDroid
//
//  Created by Ray Wenderlich on 2/8/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import "GameLayer.h"
#import "Robot.h"
#import "ArtificialIntelligence.h"
#import "GameScene.h"
#import "DamageNumber.h"
#import "HitEffect.h"
#import "Gauntlets.h"
#import "TrashCan.h"
#import "TitleScene.h"
#import "SimpleAudioEngine.h"

@implementation GameLayer

+(id)nodeWithLevel:(int)level
{
    return [[self alloc] initWithLevel:level];
}

-(id)initWithLevel:(int)level
{
    if ((self = [super init]))
    {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];
        _actors = [CCSpriteBatchNode batchNodeWithFile:@"sprites.pvr.ccz"];
        [_actors.texture setAliasTexParameters];
        [self addChild:_actors z:-5];
        [self loadLevel:level];
        [self initHero];
        [self initRobots];
        [self initWeapons];
        [self initBrains];
        [self initEffects];
        [self initMapObjects];
        [self scheduleUpdate];
    }
    return self;
}

-(void)initMapObjects
{
    CCTMXObjectGroup *objectGroup = [_tileMap objectGroupNamed:@"Objects"];
    self.mapObjects = [CCArray arrayWithCapacity:objectGroup.objects.count];
    
    NSMutableDictionary *object;
    NSString *type;
    CGPoint position, coord, origin;
    
    for (object in [objectGroup objects])
    {
        type = [object valueForKey:@"Type"];
        
        if (type && [type compare:@"TrashCan"] == NSOrderedSame)
        {
            position = ccp([[object valueForKey:@"x"] floatValue], [[object valueForKey:@"y"] floatValue]);
            coord = [self tileCoordForPosition:position];
            origin = [self tilePositionForCoord:coord anchorPoint:ccp(0.0, 0.0)];
                        
            TrashCan *trashCan = [TrashCan node];
            trashCan.scale *= kScaleFactor;
            CGSize scaledSize = CGSizeMake(trashCan.contentSize.width * kScaleFactor, trashCan.contentSize.height * kScaleFactor);
            CGPoint actualOrigin = ccpMult(origin, kPointFactor);
            trashCan.position = ccp(actualOrigin.x + scaledSize.width * trashCan.anchorPoint.x, actualOrigin.y + scaledSize.height * trashCan.anchorPoint.y);
            [_actors addChild:trashCan];
            [_mapObjects addObject:trashCan];
        }
    }
}

-(void)objectCollisionsForSprite:(ActionSprite *)sprite
{
    MapObject *mapObject;
    
    CCARRAY_FOREACH(_mapObjects, mapObject)
    {
        if (CGRectIntersectsRect(sprite.feetCollisionRect, mapObject.collisionRect))
        {
            float x = sprite.desiredPosition.x;
            float y = sprite.desiredPosition.y;
            CGRect intersection = CGRectIntersection(sprite.feetCollisionRect, mapObject.collisionRect);
            
            if (intersection.size.width > intersection.size.height)
            {
                if (sprite.groundPosition.y < mapObject.position.y)
                {
                    y = sprite.desiredPosition.y - intersection.size.height;
                }
                else
                {
                    y = sprite.desiredPosition.y + intersection.size.height;
                }
            }
            else
            {
                if (sprite.groundPosition.x < mapObject.position.x)
                {
                    x = sprite.desiredPosition.x - intersection.size.width;
                }
                else
                {
                    x = sprite.desiredPosition.x + intersection.size.width;
                }
            }
            
            sprite.desiredPosition = ccp(x, y);
        }
    }
}

-(CGPoint)tileCoordForPosition:(CGPoint)position
{
    float tileWidth = _tileMap.tileSize.width;
    float tileHeight = _tileMap.tileSize.height;
    float levelHeight = _tileMap.mapSize.height * tileHeight;
    
    float x = floor(position.x / tileWidth);
    float y = floor((levelHeight - position.y) / tileHeight);
    return ccp(x, y);
}

-(CGPoint)tilePositionForCoord:(CGPoint)coord anchorPoint:(CGPoint)anchorPoint
{
    float w = _tileMap.tileSize.width;
	float h = _tileMap.tileSize.height;
	return ccp((coord.x * w) + (w * anchorPoint.x), ((_tileMap.mapSize.height - coord.y - 1) * h) + (h * anchorPoint.y));
}

-(void)loadLevel:(int)level
{
    NSString *levelsPlist = [[NSBundle mainBundle] pathForResource:@"Levels" ofType:@"plist"];
    NSMutableArray *levelArray = [[NSMutableArray alloc] initWithContentsOfFile:levelsPlist];
    NSDictionary *levelData = [[NSDictionary alloc] initWithDictionary:levelArray[level]];
    
    NSString *tileMap = [levelData objectForKey:@"TileMap"];
    [self initTileMap:tileMap];
    
    //store the events
    _battleEvents = [CCArray arrayWithNSArray:[levelData objectForKey:@"BattleEvents"]];
    _totalLevels = levelArray.count;
    _currentLevel = level;

    NSInteger boss = [[levelData objectForKey:@"BossType"] intValue];
    [self initBossWithType:boss];

}

-(void)initBossWithType:(BossType)type
{
    if (type == kBossMohawk)
    {
        self.boss = [Boss node];
        _boss.delegate = self;
        [_actors addChild:_boss.shadow];
        _boss.shadow.scale *= kScaleFactor;
        [_actors addChild:_boss];
        _boss.scale *= kScaleFactor;
        _boss.visible = NO;
        _boss.position = OFFSCREEN;
        _boss.groundPosition = OFFSCREEN;
        _boss.desiredPosition = OFFSCREEN;
    }
}

-(void)initBrains
{
    self.brains = [[CCArray alloc] initWithCapacity:_robots.count + 1];
    ArtificialIntelligence *brain = [ArtificialIntelligence aiWithControlledSprite:_boss targetSprite:_hero];
    [_brains addObject:brain];
    
    Robot *robot;

    CCARRAY_FOREACH(_robots, robot)
    {
        brain = [ArtificialIntelligence aiWithControlledSprite:robot targetSprite:_hero];
        [_brains addObject:brain];
    }
}

-(void)initEffects
{
    int i;
        
    self.damageNumbers = [CCArray arrayWithCapacity:20];
    DamageNumber *number;
    
    for (i = 0; i < 20; i++)
    {
        number = [DamageNumber node];
        number.visible = NO;
        number.position = OFFSCREEN;
        [self addChild:number];
        [_damageNumbers addObject:number];
    }
    
    self.hitEffects = [CCArray arrayWithCapacity:20];
    HitEffect *effect;

    for (i = 0; i < 20; i++)
    {
        effect = [HitEffect node];
        effect.visible = NO;
        effect.scale *= kScaleFactor;
        effect.position = OFFSCREEN;
        [_actors addChild:effect];
        [_hitEffects addObject:effect];
    }

}

-(Weapon *)getWeapon
{
    Weapon *weapon;
    CCARRAY_FOREACH(_weapons, weapon)
    {
        if (weapon.weaponState == kWeaponStateNone)
        {
            return weapon;
        }
    }
    return weapon;
}

-(void)initWeapons
{
    int i;
    self.weapons = [CCArray arrayWithCapacity:3];
    Weapon *weapon;
    
    for (i = 0; i < 3; i++)
    {
        weapon = [Gauntlets node];
        weapon.visible = NO;
        weapon.shadow.scale *= kScaleFactor;
        weapon.scale *= kScaleFactor;
        weapon.groundPosition = OFFSCREEN;
        [_actors addChild:weapon.shadow];
        [_actors addChild:weapon];
        [_weapons addObject:weapon];
    }
}

-(DamageNumber *)getDamageNumber
{
    DamageNumber *number;
    CCARRAY_FOREACH(_damageNumbers, number)
    {
        if (number.numberOfRunningActions == 0)
        {
            return number;
        }
    }
    return number;
}

-(HitEffect *)getHitEffect
{
    HitEffect *effect;
    CCARRAY_FOREACH(_hitEffects, effect)
    {
        if (effect.numberOfRunningActions == 0)
        {
            return effect;
        }
    }
    return effect;
}

-(void)initRobots {
    int robotCount = 50;
    self.robots = [[CCArray alloc] initWithCapacity:robotCount];
    
    for (int i = 0; i < robotCount; i++) {
        Robot *robot = [Robot node];
        robot.delegate = self;
        [_actors addChild:robot.shadow];
        [_actors addChild:robot.smoke];
        [_actors addChild:robot];
        [_actors addChild:robot.belt];
        [_robots addObject:robot];
                
        robot.scale *= kScaleFactor;            //scaling simplified
        robot.shadow.scale *= kScaleFactor;
        robot.position = OFFSCREEN;             //this changed
        robot.groundPosition = robot.position;
        robot.desiredPosition = robot.position;
        robot.visible = NO;                     //added this line
                                                //this line was removed: [robot idle];
        robot.colorSet = kColorRandom;
    }
}

-(void)spawnEnemies:(CCArray *)enemies fromOrigin:(float)origin
{
    NSDictionary *enemyData;
    Robot *robot;
    
    int row, type, color;
    float offset;
    
    CCARRAY_FOREACH(enemies, enemyData)
    {
        row = [[enemyData objectForKey:@"Row"] floatValue];
        type = [[enemyData objectForKey:@"Type"] intValue];
        offset = [[enemyData objectForKey:@"Offset"] floatValue];
        
        if (type == kEnemyRobot)
        {
            color = [[enemyData objectForKey:@"Color"] intValue];
            
            //get an unused robot
            CCARRAY_FOREACH(_robots, robot)
            {
                if (robot.actionState == kActionStateNone)
                {
                    [robot stopAllActions];
                    robot.visible = NO;
                    robot.groundPosition = ccp(origin + (offset * (CENTER.x + robot.centerToSides)), robot.centerToBottom + _tileMap.tileSize.height * row * kPointFactor);
                    robot.position = robot.groundPosition;
                    robot.desiredPosition = robot.groundPosition;
                    [robot setColorSet:color];
                    [robot idle];
                    robot.visible = YES;
                    break;
                }
            }
        }
        else if (type == kEnemyBoss)
        {
            _boss.groundPosition = ccp(origin + (offset * (CENTER.x + _boss.centerToSides)), _boss.centerToBottom + _tileMap.tileSize.height * row * kPointFactor);
            _boss.position = _boss.groundPosition;
            _boss.desiredPosition = _boss.groundPosition;
            [_boss idle];
            _boss.visible = YES;
        }
    }
}

-(void)initTileMap:(NSString *)fileName
{
    _tileMap = [CCTMXTiledMap tiledMapWithTMXFile:fileName];
    
    for (CCTMXLayer *child in [_tileMap children]) {
        [[child texture] setAliasTexParameters];
	}
    
    _tileMap.scale *= kScaleFactor;
    
    [self addChild:_tileMap z:-6];
}

-(void)initHero
{
    self.hero = [Hero node];
    _hero.delegate = self;
    [_actors addChild:_hero.shadow];
    _hero.shadow.scale *= kScaleFactor;
    [_actors addChild:_hero];
    _hero.scale *= kScaleFactor;
    //change _hero.position = ccp(100 * kPointFactor, 100 * kPointFactor) to
    _hero.position = ccp(-_hero.centerToSides, 80 * kPointFactor);
    //add the following two lines
    _hero.desiredPosition = _hero.position;
    _hero.groundPosition = _hero.position;
    //remove [_hero idle];
}

-(void)actionDPad:(ActionDPad *)actionDPad didChangeDirectionTo:(ActionDPadDirection)direction
{
    if (_eventState != kEventStateScripted)
    {
        CGPoint directionVector = [self vectorForDirection:direction];
        
        if (!_hero.weapon && _runDelay > 0 && _previousDirection == direction && (direction == kActionDPadDirectionRight || direction == kActionDPadDirectionLeft))
        {
            [_hero runWithDirection:directionVector];
        }
        else if (_hero.actionState == kActionStateRun && abs(_previousDirection - direction) <= 1)
        {
            [_hero moveWithDirection:directionVector];
        }
        else
        {
            [_hero walkWithDirection:directionVector];
            _previousDirection = direction;
            _runDelay = 0.2;
        }
    }
}

-(void)actionDPad:(ActionDPad *)actionDPad isHoldingDirection:(ActionDPadDirection)direction
{
    CGPoint directionVector = [self vectorForDirection:direction];
    [_hero moveWithDirection:directionVector];
}

-(void)actionDPadTouchEnded:(ActionDPad *)actionDPad
{
    //modify the if condition as shown
    if (_eventState != kEventStateScripted && (_hero.actionState == kActionStateWalk || _hero.actionState == kActionStateRun))
    {
        [_hero idle];
    }
}

-(CGPoint)vectorForDirection:(ActionDPadDirection)direction
{
    float maxX = 1.0;
    float maxY = 0.75;
    switch (direction) {
        case kActionDPadDirectionCenter:
            return CGPointZero;
            break;
        case kActionDPadDirectionUp:
            return ccp(0.0, maxY);
            break;
        case kActionDPadDirectionUpRight:
            return ccp(maxX, maxY);
            break;
        case kActionDPadDirectionRight:
            return ccp(maxX, 0.0);
            break;
        case kActionDPadDirectionDownRight:
            return ccp(maxX, -maxY);
            break;
        case kActionDPadDirectionDown:
            return ccp(0.0, -maxY);
            break;
        case kActionDPadDirectionDownLeft:
            return ccp(-maxX, -maxY);
            break;
        case kActionDPadDirectionLeft:
            return ccp(-maxX, 0.0);
            break;
        case kActionDPadDirectionUpLeft:
            return ccp(-maxX, maxY);
            break;
        default:
            return CGPointZero;
            break;
    }
}

-(void)dealloc
{
    [self unscheduleUpdate];
}

-(NSInteger)getZFromYPosition:(float)yPosition
{
    return (_tileMap.mapSize.height * _tileMap.tileSize.height * kPointFactor) - yPosition;
}

-(void)reorderActors
{
    NSInteger spriteZ = [self getZFromYPosition:_hero.shadow.position.y];
    
    [_actors reorderChild:_hero.shadow z:spriteZ];
    [_actors reorderChild:_hero z:spriteZ];
    if (_hero.weapon)
    {
        [_actors reorderChild:_hero.weapon z:spriteZ];
    }

    Robot *robot;
    CCARRAY_FOREACH(_robots, robot)
    {
        spriteZ = [self getZFromYPosition:robot.shadow.position.y];
        [_actors reorderChild:robot.shadow z:spriteZ];
        [_actors reorderChild:robot.smoke z:spriteZ];
        [_actors reorderChild:robot z:spriteZ];
        [_actors reorderChild:robot.belt z:spriteZ];
    }
    
    if (_boss)
    {
        spriteZ = [self getZFromYPosition:_boss.shadow.position.y];
        [_actors reorderChild:_boss.shadow z:spriteZ];
        [_actors reorderChild:_boss z:spriteZ];
    }
    
    Weapon *weapon;
    CCARRAY_FOREACH(_weapons, weapon)
    {
        if (weapon.weaponState != kWeaponStateEquipped)
        {
            spriteZ = [self getZFromYPosition:weapon.shadow.position.y];
            [_actors reorderChild:weapon.shadow z:spriteZ];
            [_actors reorderChild:weapon z:spriteZ];
        }
    }
    
    MapObject *object;
    CCARRAY_FOREACH(_mapObjects, object)
    {
        spriteZ = [self getZFromYPosition:object.collisionRect.origin.y + object.collisionRect.size.height/2];
        [_actors reorderChild:object z:spriteZ];
    }
    
}

-(BOOL)collisionBetweenAttacker:(ActionSprite *)attacker andObject:(MapObject *)object atPosition:(CGPoint *)position
{
    //first phase: check if they're on the same plane
    float objectBottom = object.collisionRect.origin.y;
    float objectTop = objectBottom + object.collisionRect.size.height;
    float attackerBottom = attacker.feetCollisionRect.origin.y;
    float attackerTop = attackerBottom + attacker.feetCollisionRect.size.height;
    
    if ((attackerBottom > objectBottom && attackerBottom < objectTop) || (attackerTop > objectBottom && attackerTop < objectTop))
    {
        int i, j;
        float combinedRadius = attacker.detectionRadius + object.detectionRadius;
        
        //initial detection
        if (ccpDistanceSQ(attacker.position, object.position) <= combinedRadius * combinedRadius)
        {
            int attackPointCount = attacker.attackPointCount;
            int contactPointCount = object.contactPointCount;
            
            ContactPoint attackPoint, contactPoint;
            
            //secondary detection
            for (i = 0; i < attackPointCount; i++)
            {
                attackPoint = attacker.attackPoints[i];
                
                for (j = 0; j < contactPointCount; j++)
                {
                    contactPoint = object.contactPoints[j];
                    combinedRadius = attackPoint.radius + contactPoint.radius;
                    
                    if (ccpDistanceSQ(attackPoint.position, contactPoint.position) <= combinedRadius * combinedRadius)
                    {
                        //attack point collided with contact point
                        position->x = attackPoint.position.x;
                        position->y = attackPoint.position.y;
                        return YES;
                    }
                }
            }
        }
    }
    return NO;
}

-(void)update:(ccTime)delta
{
    [_hero update:delta];

    Weapon *weapon;
    CCARRAY_FOREACH(_weapons, weapon)
    {
        [weapon update:delta];
    }

    if (_boss)
    {
        [_boss update:delta];
    }
    
    ArtificialIntelligence *brain;
    CCARRAY_FOREACH(_brains, brain)
    {
        [brain update:delta];
    }
    
    Robot *robot;
    CCARRAY_FOREACH(_robots, robot)
    {
        [robot update:delta];
    }

    [self updatePositions];
    [self reorderActors];
    
    if (_runDelay > 0)
    {
        _runDelay -= delta;
    }
    
    if (_eventState == kEventStateFreeWalk || _eventState == kEventStateScripted)
    {
        [self setViewpointCenter:_hero.position];
    }
    
    [self updateEvent];
    
    if (_viewPointOffset < 0)
    {
        _viewPointOffset += SCREEN.width * delta;
        
        if (_viewPointOffset >= 0)
        {
            _viewPointOffset = 0;
        }
    }
    else if (_viewPointOffset > 0)
    {
        _viewPointOffset -= SCREEN.width * delta;
        
        if (_viewPointOffset <= 0)
        {
            _viewPointOffset = 0;
        }
    }
    
}

-(void)updateEvent
{
    if (_eventState == kEventStateBattle && _activeEnemies <= 0)
    {
        float maxCenterX = _tileMap.mapSize.width * _tileMap.tileSize.width * kPointFactor - CENTER.x;
        float cameraX = MAX(MIN(_hero.position.x, maxCenterX), CENTER.x);
        _viewPointOffset = cameraX  - _eventCenter;
        if (_battleEvents.count == 0)
        {
            [self exitLevel];
        }
        else
        {
            self.eventState = kEventStateFreeWalk;
        }
    }
    else if (_eventState == kEventStateFreeWalk)
    {
        //modified this part
        [self cycleEvents];
    }
    else if (_eventState == kEventStateScripted) //add this
    {
        float exitX = _tileMap.tileSize.width * _tileMap.mapSize.width * kPointFactor + _hero.centerToSides;
        if (_hero.position.x >= exitX)
        {
            _eventState = kEventStateEnd;
            if (_currentLevel < _totalLevels - 1)
            {
                //next level
                [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[GameScene nodeWithLevel:_currentLevel + 1]]];
            }
            else
            {
                //end game
                [_hud showMessage:@"YOU WIN" color:COLOR_FULLHP];
                [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:2.0], [CCCallBlock actionWithBlock:^(void){
                    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[TitleScene node]]];
                }], nil]];
            }
        }
    }
}

-(void)exitLevel
{
    _eventState = kEventStateScripted;
    float exitX = _tileMap.tileSize.width * _tileMap.mapSize.width * kPointFactor + _hero.centerToSides;
    [_hero enterFrom:_hero.position to:ccp(exitX, _hero.position.y)];
}

-(void)cycleEvents
{
    NSDictionary *event;
    int column;
    float tileWidth = _tileMap.tileSize.width * kPointFactor;
    CCARRAY_FOREACH(_battleEvents, event)
    {
        column = [[event objectForKey:@"Column"] intValue];
        float maxCenterX = _tileMap.mapSize.width * _tileMap.tileSize.width * kPointFactor - CENTER.x;
        float columnPosition = column * tileWidth - tileWidth/2;
        _eventCenter = MAX(MIN(columnPosition, maxCenterX), CENTER.x);
        if (_hero.position.x >= _eventCenter) // 1
        {
            _currentEvent = event;
            _eventState = kEventStateBattle;
            CCArray *enemyData = [CCArray arrayWithNSArray:[event objectForKey:@"Enemies"]];
            _activeEnemies = enemyData.count;
            [self spawnEnemies:enemyData fromOrigin:_eventCenter];
            [self setViewpointCenter:ccp(_eventCenter, _hero.position.y)];
            break;
        }
    }
    
    if (_eventState == kEventStateBattle)
    {
        [_battleEvents removeObject:_currentEvent];
    }
}

-(void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    _eventState = kEventStateScripted;
    [_hero enterFrom:_hero.position to:ccp(64.0, _hero.position.y)];
    [self performSelector:@selector(triggerEvent:) withObject:[NSNumber numberWithInt:kEventStateFreeWalk] afterDelay:1.2];
    
    [_hud displayLevel:_currentLevel + 1];
}

-(void)triggerEvent:(NSNumber *)eventId
{
    self.eventState = [eventId intValue];
}

-(void)updatePositions
{
    float mapWidth = _tileMap.mapSize.width * _tileMap.tileSize.width * kPointFactor;
    float floorHeight = 3 * _tileMap.tileSize.height * kPointFactor;
    float posX, posY;
    
    if (_hero.actionState > kActionStateNone)
    {
        [self objectCollisionsForSprite:_hero];
        
        // 1
        if (_eventState == kEventStateFreeWalk)
        {
            posX = MIN(mapWidth - _hero.feetCollisionRect.size.width/2, MAX(_hero.feetCollisionRect.size.width/2, _hero.desiredPosition.x));
            posY = MIN(floorHeight + (_hero.centerToBottom - _hero.feetCollisionRect.size.height), MAX(_hero.centerToBottom, _hero.desiredPosition.y));
            
            _hero.groundPosition = ccp(posX, posY);
            _hero.position = ccp(_hero.groundPosition.x, _hero.groundPosition.y + _hero.jumpHeight);
        }
        else if (_eventState == kEventStateBattle)
        {
            posX = MIN(MIN(mapWidth - _hero.feetCollisionRect.size.width/2, _eventCenter + CENTER.x - _hero.feetCollisionRect.size.width/2), MAX(_eventCenter - CENTER.x + _hero.feetCollisionRect.size.width/2, _hero.desiredPosition.x));
            posY = MIN(floorHeight + (_hero.centerToBottom - _hero.feetCollisionRect.size.height), MAX(_hero.centerToBottom, _hero.desiredPosition.y));
            _hero.groundPosition = ccp(posX, posY);
            _hero.position = ccp(_hero.groundPosition.x, _hero.groundPosition.y + _hero.jumpHeight);
        }
    }
    
    Robot *robot;
    CCARRAY_FOREACH(_robots, robot)
    {
        if (robot.actionState > kActionStateNone)
        {
            [self objectCollisionsForSprite:robot];            
            
            posY = MIN(floorHeight + (robot.centerToBottom - robot.feetCollisionRect.size.height), MAX(robot.centerToBottom, robot.desiredPosition.y));
            robot.groundPosition = ccp(robot.desiredPosition.x, posY);
            robot.position = ccp(robot.groundPosition.x, robot.groundPosition.y + robot.jumpHeight);
            
            if (robot.actionState == kActionStateDead && _hero.groundPosition.x - robot.groundPosition.x >= CENTER.x + robot.contentSize.width/2 * kScaleFactor)
            {
                robot.visible = NO;
                [robot reset];
            }
            
        
        }
    }
    
    if (_boss && _boss.actionState > kActionStateNone)
    {
        [self objectCollisionsForSprite:_boss];
        
        posY = MIN(floorHeight + (_boss.centerToBottom - _boss.feetCollisionRect.size.height), MAX(_boss.centerToBottom, _boss.desiredPosition.y));
        _boss.groundPosition = ccp(_boss.desiredPosition.x, posY);
        _boss.position = ccp(_boss.groundPosition.x, _boss.groundPosition.y + _boss.jumpHeight);
    }
    
    Weapon *weapon;
    CCARRAY_FOREACH(_weapons, weapon)
    {
        if (weapon.weaponState > kWeaponStateEquipped)
        {
            weapon.position = ccp(weapon.groundPosition.x, weapon.groundPosition.y + weapon.jumpHeight);
        }
    }

}

-(void)setViewpointCenter:(CGPoint) position {
    int x = MAX(position.x, CENTER.x);
    int y = MAX(position.y, CENTER.y);
    x = MIN(x, (_tileMap.mapSize.width * _tileMap.tileSize.width * kPointFactor)
            - CENTER.x);
    y = MIN(y, (_tileMap.mapSize.height * _tileMap.tileSize.height * kPointFactor)
            - CENTER.y);
    CGPoint actualPosition = ccp(x, y);

    CGPoint viewPoint = ccpSub(CENTER, actualPosition);
    self.position = ccp(viewPoint.x + _viewPointOffset, viewPoint.y);
}

-(void)actionButtonWasPressed:(ActionButton *)actionButton
{
    if (_eventState != kEventStateScripted)
    {
        if (actionButton.tag == kTagButtonA)
        {
            //replace the contents of this if statement
            BOOL pickedUpWeapon = NO;
            if (!_hero.weapon)
            {
                //check collision for all weapons
                Weapon *weapon;
                CCARRAY_FOREACH(_weapons, weapon)
                {
                    if (weapon.weaponState == kWeaponStateUnequipped)
                    {
                        if ([self collisionBetweenPlayer:_hero andWeapon:weapon])
                        {
                            pickedUpWeapon = [_hero pickUpWeapon:weapon];
                            [_actors reorderChild:weapon z:_hero.zOrder + 1];
                            break;
                        }
                    }
                }
            }
            
            if (!pickedUpWeapon)
            {
                [_hero attack];
            }
        }
        else if (actionButton.tag == kTagButtonB)
        {
            //replace the contents of this else if statement
            if (_hero.weapon)
            {
                [_hero dropWeapon];
            }
            else
            {
                CGPoint directionVector = [self vectorForDirection:_hud.dPad.direction];
                [_hero jumpRiseWithDirection:directionVector];
            }
        }
    }
}

-(void)actionButtonIsHeld:(ActionButton *)actionButton{
}

-(void)actionButtonWasReleased:(ActionButton *)actionButton
{
    if (actionButton.tag == kTagButtonB)
    {
        [_hero jumpCutoff];
    }
}

#if DRAW_DEBUG_SHAPES

-(void)draw
{
    [super draw];
    [self drawShapesForActionSprite:_hero];

    ActionSprite *actionSprite;
    CCARRAY_FOREACH(_robots, actionSprite)
    {
        [self drawShapesForActionSprite:actionSprite];
    }
    
    if (self.boss) {
        [self drawShapesForActionSprite:self.boss];
    }
}

-(void)drawShapesForActionSprite:(ActionSprite *)sprite
{
    if (sprite.visible)
    {
        int i;
        
        ccDrawColor4B(0, 0, 255, 255);
        ccDrawCircle(sprite.position, sprite.detectionRadius, 0, 16, NO);
        
        ccDrawColor4B(0, 255, 0, 255);
        for (i = 0; i < sprite.contactPointCount; i++)
        {
            ccDrawCircle(sprite.contactPoints[i].position, sprite.contactPoints[i].radius, 0, 8, NO);
        }
        
        ccDrawColor4B(255, 0, 0, 255);
        for (i = 0; i < sprite.attackPointCount; i++)
        {
            ccDrawCircle(sprite.attackPoints[i].position, sprite.attackPoints[i].radius, 0, 8, NO);
        }
        
        ccDrawColor4B(255, 255, 0, 255);
        ccDrawRect(sprite.feetCollisionRect.origin, ccp(sprite.feetCollisionRect.origin.x + sprite.feetCollisionRect.size.width, sprite.feetCollisionRect.origin.y + sprite.feetCollisionRect.size.height));
    }
}

#endif

//add these methods
-(BOOL)actionSpriteDidDie:(ActionSprite *)actionSprite
{
    if (actionSprite == _hero)
    {
        [_hud setHitPoints:0 fromMaxHP:_hero.maxHitPoints];
        [_hud showMessage:@"GAME OVER" color:COLOR_LOWHP];
        [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:2.0], [CCCallBlock actionWithBlock:^(void){
           [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[TitleScene node]]];
        }], nil]];
    }
    else
    {
        _activeEnemies--;
        return YES;
    }
    
    return NO;
}

-(void)setHud:(HudLayer *)hud
{
    _hud = hud;
    [_hud setHitPoints:_hero.hitPoints fromMaxHP:_hero.maxHitPoints];
}

-(BOOL)actionSpriteDidAttack:(ActionSprite *)actionSprite
{
    BOOL didHit = NO;
    if (actionSprite == _hero)
    {
        CGPoint attackPosition;
        Robot *robot;
        CCARRAY_FOREACH(_robots, robot)
        {
            if (robot.actionState < kActionStateKnockedOut && robot.actionState != kActionStateNone)
            {
                if ([self collisionBetweenAttacker:_hero andTarget:robot atPosition:&attackPosition])
                {
                    BOOL showEffect = YES;
                    
                    DamageNumber *damageNumber = [self getDamageNumber];
                    
                    if (_hero.actionState == kActionStateJumpAttack)
                    {
                        //add this
                        [[SimpleAudioEngine sharedEngine] playEffect:@"hit1.caf"];
                        [robot knockoutWithDamage:_hero.jumpAttackDamage direction:ccp(_hero.directionX, 0)];
                        [damageNumber showWithValue:_hero.jumpAttackDamage fromOrigin:robot.position];
                        showEffect = NO;
                    }
                    else if (_hero.actionState == kActionStateRunAttack)
                    {
                        //add this
                        [[SimpleAudioEngine sharedEngine] playEffect:@"hit0.caf"];
                        [robot knockoutWithDamage:_hero.runAttackDamage direction:ccp(_hero.directionX, 0)];
                        [damageNumber showWithValue:_hero.runAttackDamage fromOrigin:robot.position];
                    }
                    else if (_hero.actionState == kActionStateAttackThree)
                    {
                        //add this
                        [[SimpleAudioEngine sharedEngine] playEffect:@"hit1.caf"];
                        [robot knockoutWithDamage:_hero.attackThreeDamage direction:ccp(_hero.directionX, 0)];
                        [damageNumber showWithValue:_hero.attackThreeDamage fromOrigin:robot.position];
                        showEffect = NO;
                    }
                    else if (_hero.actionState == kActionStateAttackTwo)
                    {
                        //add this
                        [[SimpleAudioEngine sharedEngine] playEffect:@"hit0.caf"];
                        [robot hurtWithDamage:_hero.attackTwoDamage force:_hero.attackForce direction:ccp(_hero.directionX, 0.0)];
                        [damageNumber showWithValue:_hero.attackTwoDamage fromOrigin:robot.position];
                    }
                    else
                    {
                        //add this
                        [[SimpleAudioEngine sharedEngine] playEffect:@"hit0.caf"];
                        [robot hurtWithDamage:_hero.attackDamage force:_hero.attackForce direction:ccp(_hero.directionX, 0.0)];
                        [damageNumber showWithValue:_hero.attackDamage fromOrigin:robot.position];
                    }
                    didHit = YES;
                    
                    if (showEffect)
                    {
                        HitEffect *hitEffect = [self getHitEffect];
                        [_actors reorderChild:hitEffect z:MAX(robot.zOrder, _hero.zOrder) + 1];
                        [hitEffect showEffectAtPosition:attackPosition];
                    }
                }
            }
        }
        
        if (_boss && _boss.actionState < kActionStateKnockedOut && _boss.actionState != kActionStateNone)
        {
            if ([self collisionBetweenAttacker:_hero andTarget:_boss atPosition:&attackPosition])
            {
                BOOL showEffect = YES;
                DamageNumber *damageNumber = [self getDamageNumber];
                
                if (_hero.actionState == kActionStateJumpAttack)
                {
                    //add this
                    [[SimpleAudioEngine sharedEngine] playEffect:@"hit1.caf"];
                    [_boss hurtWithDamage:_hero.jumpAttackDamage force:_hero.attackForce direction:ccp(_hero.directionX, 0)];
                    [damageNumber showWithValue:_hero.jumpAttackDamage fromOrigin:_boss.position];
                    showEffect = NO;
                }
                else if (_hero.actionState == kActionStateRunAttack)
                {
                    //add this
                    [[SimpleAudioEngine sharedEngine] playEffect:@"hit0.caf"];
                    [_boss hurtWithDamage:_hero.runAttackDamage force:_hero.attackForce direction:ccp(_hero.directionX, 0)];
                    [damageNumber showWithValue:_hero.runAttackDamage fromOrigin:_boss.position];
                }
                else if (_hero.actionState == kActionStateAttackThree)
                {
                    //add this
                    [[SimpleAudioEngine sharedEngine] playEffect:@"hit1.caf"];
                    [_boss hurtWithDamage:_hero.attackThreeDamage force:_hero.attackForce direction:ccp(_hero.directionX, 0)];
                    [damageNumber showWithValue:_hero.attackThreeDamage fromOrigin:_boss.position];
                    showEffect = NO;
                }
                else if (_hero.actionState == kActionStateAttackTwo)
                {
                    //add this
                    [[SimpleAudioEngine sharedEngine] playEffect:@"hit0.caf"];
                    [_boss hurtWithDamage:_hero.attackTwoDamage force:_hero.attackForce/2 direction:ccp(_hero.directionX, 0.0)];
                    [damageNumber showWithValue:_hero.attackTwoDamage fromOrigin:_boss.position];
                }
                else
                {
                    //add this
                    [[SimpleAudioEngine sharedEngine] playEffect:@"hit0.caf"];
                    [_boss hurtWithDamage:_hero.attackDamage force:0 direction:ccp(_hero.directionX, 0.0)];
                    [damageNumber showWithValue:_hero.attackDamage fromOrigin:_boss.position];
                }
                didHit = YES;
                
                if (showEffect)
                {
                    HitEffect *hitEffect = [self getHitEffect];
                    [_actors reorderChild:hitEffect z:MAX(_boss.zOrder, _hero.zOrder) + 1];
                    [hitEffect showEffectAtPosition:attackPosition];
                }
            }
        }
        
        MapObject *mapObject;
        CCARRAY_FOREACH(_mapObjects, mapObject)
        {
            if ([self collisionBetweenAttacker:_hero andObject:mapObject atPosition:&attackPosition])
            {
                HitEffect *hitEffect = [self getHitEffect];
                [_actors reorderChild:hitEffect z:MAX(mapObject.zOrder, _hero.zOrder) + 1];
                [hitEffect showEffectAtPosition:attackPosition];
                
                if (mapObject.objectState != kObjectStateDestroyed)
                {
                    //add this
                    [[SimpleAudioEngine sharedEngine] playEffect:@"hit1.caf"];
                    [mapObject destroyed];
                    Weapon *weapon = [self getWeapon];
                    [weapon droppedFrom:mapObject.contentSize.height/2 * kScaleFactor to:ccp(mapObject.position.x, mapObject.position.y - mapObject.contentSize.height/2 * kScaleFactor)];
                    weapon.visible = YES;
                }
                else//add this
                {
                    [[SimpleAudioEngine sharedEngine] playEffect:@"hit0.caf"];
                }
            }
        }
        
        return didHit;
    }
    else if (actionSprite == _boss) 
    {
        if (_hero.actionState < kActionStateKnockedOut && _hero.actionState != kActionStateNone)
        {
            CGPoint attackPosition;
            if ([self collisionBetweenAttacker:_boss andTarget:_hero atPosition:&attackPosition])
            {
                //add this
                [[SimpleAudioEngine sharedEngine] playEffect:@"hit1.caf"];
                
                [_hero knockoutWithDamage:_boss.attackDamage direction:ccp(actionSprite.directionX, 0.0)];
                [_hud setHitPoints:_hero.hitPoints fromMaxHP:_hero.maxHitPoints];
                didHit = YES;
                
                DamageNumber *damageNumber = [self getDamageNumber];
                [damageNumber showWithValue:_boss.attackDamage fromOrigin:_hero.position];
                
                HitEffect *hitEffect = [self getHitEffect];
                [_actors reorderChild:hitEffect z:MAX(_boss.zOrder, _hero.zOrder) + 1];
                [hitEffect showEffectAtPosition:attackPosition];
            }
        }
    }
    else
    {
        if (_hero.actionState < kActionStateKnockedOut && _hero.actionState != kActionStateNone)
        {
            CGPoint attackPosition;
            if ([self collisionBetweenAttacker:actionSprite andTarget:_hero atPosition:&attackPosition])
            {
                //add this
                [[SimpleAudioEngine sharedEngine] playEffect:@"hit0.caf"];
                
                [_hero hurtWithDamage:actionSprite.attackDamage force:actionSprite.attackForce direction:ccp(actionSprite.directionX, 0.0)];
                [_hud setHitPoints:_hero.hitPoints fromMaxHP:_hero.maxHitPoints];
                didHit = YES;
                
                DamageNumber *damageNumber = [self getDamageNumber];
                [damageNumber showWithValue:actionSprite.attackDamage fromOrigin:_hero.position];
                
                HitEffect *hitEffect = [self getHitEffect];
                [_actors reorderChild:hitEffect z:MAX(actionSprite.zOrder, _hero.zOrder) + 1];
                [hitEffect showEffectAtPosition:attackPosition];
            }
        }
    }
    
    return didHit;
}

-(BOOL)collisionBetweenAttacker:(ActionSprite *)attacker andTarget:(ActionSprite *)target atPosition:(CGPoint *)position
{
    //first phase: check if they're on the same plane
    float planeDist = attacker.shadow.position.y - target.shadow.position.y;
    
    if (fabsf(planeDist) <= kPlaneHeight)
    {
        int i, j;
        float combinedRadius = attacker.detectionRadius + target.detectionRadius;
        
        //initial detection
        if (ccpDistanceSQ(attacker.position, target.position) <= combinedRadius * combinedRadius)
        {
            int attackPointCount = attacker.attackPointCount;
            int contactPointCount = target.contactPointCount;
            
            ContactPoint attackPoint, contactPoint;
            
            //secondary detection
            for (i = 0; i < attackPointCount; i++)
            {
                attackPoint = attacker.attackPoints[i];
                
                for (j = 0; j < contactPointCount; j++)
                {
                    contactPoint = target.contactPoints[j];
                    combinedRadius = attackPoint.radius + contactPoint.radius;
                    
                    if (ccpDistanceSQ(attackPoint.position, contactPoint.position) <= combinedRadius * combinedRadius)
                    {
                        //attack point collided with contact point
                        position->x = attackPoint.position.x;
                        position->y = attackPoint.position.y;
                        return YES;
                    }
                }
            }
        }
    }
    return NO;
}

-(BOOL)collisionBetweenPlayer:(ActionSprite *)player andWeapon:(Weapon *)weapon
{
    //first phase: check if they're on the same plane
    float planeDist = player.shadow.position.y - weapon.shadow.position.y;
    
    if (fabsf(planeDist) <= kPlaneHeight)
    {
        float combinedRadius = player.detectionRadius + weapon.detectionRadius;
        int i;

        //initial detection
        if (ccpDistanceSQ(player.position, weapon.position) <= combinedRadius * combinedRadius)
        {
            int contactPointCount = player.contactPointCount;
            ContactPoint contactPoint;
            
            //secondary detection
            for (i = 0; i < contactPointCount; i++)
            {
                contactPoint = player.contactPoints[i];
                combinedRadius = contactPoint.radius + weapon.detectionRadius;
                
                if (ccpDistanceSQ(contactPoint.position, weapon.position) <= combinedRadius * combinedRadius)
                {
                    return YES;
                }
            }
        }
    }
    return NO;
}

-(void)setEventState:(EventState)eventState
{
    _eventState = eventState;
    
    if (_eventState == kEventStateFreeWalk)
    {
        [_hud showGoMessage];
    }
}

@end
