//
//  GameLayer.m
//  PompaDroid
//
//  Created by Allen Tan on 6/10/14.
//
//

#import "GameLayer.h"
#import "Robot.h"
#import "ArtificialIntelligence.h"
#import "DamageNumber.h"
#import "HitEffect.h"
#import "Gauntlets.h"
#import "TrashCan.h"
#import "UIColor+BGSK.h"

@interface GameLayer ()

@property (assign, nonatomic) CGFloat runDelay;
@property (assign, nonatomic) ActionDPadDirection previousDirection;
@property (assign, nonatomic) NSInteger activeEnemies;
@property (assign, nonatomic) CGFloat viewPointOffset;
@property (assign, nonatomic) CGFloat eventCenter;

@end

@implementation GameLayer

- (void)setEventState:(EventState)eventState
{
    _eventState = eventState;
    
    if (_eventState == kEventStateFreeWalk) {
        [_hud showGoMessage];
    }
}

- (void)setHud:(HudLayer *)hud
{
    _hud = hud;
    [_hud setHitPoints:_hero.hitPoints
             fromMaxHP:_hero.maxHitPoints];
}

- (void)dealloc
{
    [self.hero cleanup];
    
    Robot *robot;
    for (robot in self.robots) {
        [robot cleanup];
    }
    
    DamageNumber *damageNumber;
    for (damageNumber in self.damageNumbers) {
        [damageNumber cleanup];
    }
    
    HitEffect *hitEffect;
    for (hitEffect in self.hitEffects) {
        [hitEffect cleanup];
    }
    
    if (self.boss) {
        [self.boss cleanup];
    }

    Weapon *weapon;
    for (weapon in self.weapons) {
        [weapon cleanup];
    }
}

+ (instancetype)nodeWithLevel:(NSInteger)level
{
    return [[self alloc] initWithLevel:level];
}
- (instancetype)initWithLevel:(NSInteger)level
{
    if (self = [super init]) {
        [self loadLevel:level];
        [self initHero];
        [self initRobots];
        [self initWeapons];
        [self initBrains];
        [self initEffects];
        [self initMapObjects];
    }
    return self;
}

- (void)initMapObjects
{
    TMXObjectGroup *objectGroup = [self.tileMap groupNamed:@"Objects"];
    
    self.mapObjects = [NSMutableArray arrayWithCapacity:objectGroup.objects.count];
    
    NSMutableDictionary *object;
    NSString *type;
    CGPoint position, coord, origin;
    
    for (object in [objectGroup objects]) {
        type = object[@"Type"];
        
        if (type && [type compare:@"TrashCan"] == NSOrderedSame) {
            
            position = CGPointMake([object[@"x"] floatValue], [object[@"y"] floatValue]);
            
            coord = [self tileCoordForPosition:position];
            origin = [self tilePositionForCoord:coord
                                    anchorPoint:CGPointMake(0, 0)];
            
            TrashCan *trashCan = [TrashCan node];
            [trashCan setScale:kPointFactor];
            
            CGPoint actualOrigin = CGPointMultiplyScalar(origin, kPointFactor);
            trashCan.position = CGPointMake(actualOrigin.x + trashCan.size.width * trashCan.anchorPoint.x, actualOrigin.y + trashCan.size.height * trashCan.anchorPoint.y);
            
            [self addChild:trashCan];
            [self.mapObjects addObject:trashCan];
        }
    }
}
- (CGPoint)tileCoordForPosition:(CGPoint)position
{
    CGFloat tileWidth = self.tileMap.tileSize.width;
    CGFloat tileHeight = self.tileMap.tileSize.height;
    
    CGFloat levelHeight =
    self.tileMap.mapSize.height * tileHeight;
    
    CGFloat x = floor(position.x / tileWidth);
    CGFloat y = floor((levelHeight - position.y) / tileHeight);
    return CGPointMake(x, y);
}

- (CGPoint)tilePositionForCoord:(CGPoint)coord
                    anchorPoint:(CGPoint)anchorPoint
{
    CGFloat w = self.tileMap.tileSize.width;
    CGFloat h = self.tileMap.tileSize.height;
    return CGPointMake((coord.x * w) + (w * anchorPoint.x), ((self.tileMap.mapSize.height - coord.y - 1) * h) + (h * anchorPoint.y));
}

- (Weapon *)getWeapon
{
    Weapon *weapon;
    for (weapon in self.weapons) {
        if (weapon.weaponState == kWeaponStateNone){
            return weapon;
        }
    }
    return weapon;
}

- (void)initWeapons
{
    self.weapons = [NSMutableArray arrayWithCapacity:3];
    Weapon *weapon;
    
    for (NSInteger i = 0; i < 3; i++) {
        weapon = [Gauntlets node];
        weapon.hidden = YES;
        [weapon.shadow setScale:kPointFactor];
        [weapon setScale:kPointFactor];
        weapon.groundPosition = OFFSCREEN;
        [self addChild:weapon.shadow];
        [self addChild:weapon];
        [self.weapons addObject:weapon];
    }
}


- (void)startGame
{
    [self.hud displayLevel:self.currentLevel + 1];
    
    self.eventState = kEventStateScripted;
    
    CGPoint destination = CGPointMake(64.0 * kPointFactor,
                                      self.hero.position.y);
    
    [self.hero enterFrom:self.hero.position to:destination];
}


- (instancetype)init
{
    if (self = [super init])
    {
        [self loadLevel:0];
        [self initHero];
        [self initRobots];
        [self initBrains];
    }
    return self;
}

- (void)loadLevel:(NSInteger)level
{
    NSString *levelsPlist = [[NSBundle mainBundle] pathForResource:@"Levels" ofType:@"plist"];
    
    NSMutableArray *levelArray = [[NSMutableArray alloc] initWithContentsOfFile:levelsPlist];
    
    NSDictionary *levelData = [[NSDictionary alloc] initWithDictionary:[levelArray objectAtIndex:level]];
    
    NSString *tileMap = [levelData objectForKey:@"TileMap"];
    
    [self initTileMap:tileMap];
    
    //store the events
    self.battleEvents = [NSMutableArray arrayWithArray:[levelData objectForKey:@"BattleEvents"]];
    
    self.totalLevels = levelArray.count;
    self.currentLevel = level;
    
    BossType boss =
    [[levelData objectForKey:@"BossType"] integerValue];
    
    [self initBossWithType:boss];
}

- (void)initBossWithType:(BossType)type
{
    if (type == kBossMohawk) {
        
        self.boss = [Boss node];
        self.boss.delegate = self;
        [self addChild:_boss.shadow];
        [self.boss.shadow setScale:kPointFactor];
        [self addChild:_boss];
        [self.boss setScale:kPointFactor];
        self.boss.hidden = YES;
        self.boss.position = OFFSCREEN;
        self.boss.groundPosition = OFFSCREEN;
        self.boss.desiredPosition = OFFSCREEN;
    }
}

- (void)initHero
{
    self.hero = [Hero node];
    self.hero.delegate = self;
    
    [self.hero setScale:kPointFactor];
    [self.hero.shadow setScale:kPointFactor];
    
    [self addChild:self.hero.shadow];
    [self addChild:self.hero];
    
    //change self.hero.position = CGPointMake(100 * kPointFactor, 100 *kPointFactor); to
    
    self.hero.position = CGPointMake(-self.hero.centerToSides,
                                     80 * kPointFactor);
    
    //add the following two lines
    self.hero.desiredPosition = self.hero.position;
    self.hero.groundPosition = self.hero.position;
    
    //remove [self.hero idle];
}

- (void)initEffects
{
    self.damageNumbers = [NSMutableArray arrayWithCapacity:20];
    
    DamageNumber *number;
    
    for (NSInteger i = 0; i < 20; i++) {
        number = [DamageNumber node];
        number.hidden = YES;
        number.position = OFFSCREEN;
        [self addChild:number];
        [self.damageNumbers addObject:number];
    }
    
    self.hitEffects = [NSMutableArray arrayWithCapacity:20];
    HitEffect *effect;
    
    for (NSInteger i = 0; i < 20; i++) {
        effect = [HitEffect node];
        effect.hidden = YES;
        [effect setScale:kPointFactor];
        effect.position = OFFSCREEN;
        [self addChild:effect];
        [self.hitEffects addObject:effect];
    }
}

- (HitEffect *)getHitEffect
{
    HitEffect *effect;
    for (effect in self.hitEffects) {
        if (![effect hasActions]) {
            return effect;
        }
    }
    return effect;
}

- (DamageNumber *)getDamageNumber
{
    DamageNumber *number;
    for (number in self.damageNumbers) {
        if (![number hasActions]) {
            return number;
        }
    }
    return number;
}

- (void)initRobots {
    
    NSInteger robotCount = 50;
    self.robots = [NSMutableArray arrayWithCapacity:robotCount];
    
    for (NSInteger i = 0; i < robotCount; i++) {
        
        Robot *robot = [Robot node];
        robot.delegate = self;
        [self addChild:robot.shadow];
        [self addChild:robot.smoke];
        [self addChild:robot];
        [self addChild:robot.belt];
        [self.robots addObject:robot];
        
        [robot setScale:kPointFactor];  //scaling simplified
        [robot.shadow setScale:kPointFactor];
        robot.position = OFFSCREEN;     //this changed
        robot.groundPosition = robot.position;
        robot.desiredPosition = robot.position;
        robot.hidden = YES;
        //this line was removed: [robot idle];
        robot.colorSet = kColorRandom;
    }
}

- (void)initBrains
{
    self.brains =
    [NSMutableArray arrayWithCapacity:self.robots.count + 1];
    
    ArtificialIntelligence *brain =
    [ArtificialIntelligence aiWithControlledSprite:self.boss
                                      targetSprite:self.hero];
    
    [self.brains addObject:brain];
    
    for (Robot *robot in self.robots) {
        
        brain = [ArtificialIntelligence
                 aiWithControlledSprite:robot
                 targetSprite:self.hero];
        
        [self.brains addObject:brain];
    }
}

- (void)initTileMap:(NSString *)fileName
{
    self.tileMap = [JSTileMap mapNamed:fileName];
    [self.tileMap setScale:kPointFactor];
    [self addChild:self.tileMap];
}

- (void)spawnEnemies:(NSMutableArray *)enemies
          fromOrigin:(CGFloat)origin
{
    
    for (NSDictionary *enemyData in enemies) {
        
        NSInteger row = [enemyData[@"Row"] integerValue];
        NSInteger type = [enemyData[@"Type"] integerValue];
        CGFloat offset = [enemyData[@"Offset"] floatValue];
        
        if (type == kEnemyRobot) {
            
            NSInteger color = [enemyData[@"Color"] integerValue];
            
            //get an unused robot
            for (Robot *robot in self.robots) {
                
                if (robot.actionState == kActionStateNone) {
                    [robot removeAllActions];
                    robot.hidden = YES;
                    robot.groundPosition = CGPointMake(origin + (offset * (CENTER.x + robot.centerToSides)), robot.centerToBottom + self.tileMap.tileSize.height * row * kPointFactor);
                    robot.position = robot.groundPosition;
                    robot.desiredPosition = robot.groundPosition;
                    [robot setColorSet:color];
                    [robot idle];
                    robot.hidden = NO;
                    break;
                }
            }
        }
        else if (type == kEnemyBoss) {
            
            self.boss.groundPosition = CGPointMake(origin + (offset * (CENTER.x + self.boss.centerToSides)), self.boss.centerToBottom + self.tileMap.tileSize.height * row * kPointFactor);
            
            self.boss.position = self.boss.groundPosition;
            self.boss.desiredPosition = self.boss.groundPosition;
            [self.boss idle];
            self.boss.hidden = NO;
            
        }
    }
}

- (void)actionDPad:(ActionDPad *)actionDPad
didChangeDirectionTo:(ActionDPadDirection)direction
{
    if (self.eventState == kEventStateScripted) return;
    
    CGPoint directionVector = [self vectorForDirection:direction];
    
    // 1
    if (!self.hero.weapon && self.runDelay > 0 &&
        self.previousDirection == direction &&
        (direction == kActionDPadDirectionRight ||
         direction == kActionDPadDirectionLeft)) {
            
            [self.hero runWithDirection:directionVector];
        }
    // 2
    else if (self.hero.actionState == kActionStateRun &&
             abs(self.previousDirection - direction) <= 1) {
        
        [self.hero moveWithDirection:directionVector];
    }
    // 3
    else {
        [self.hero walkWithDirection:directionVector];
        self.previousDirection = direction;
        self.runDelay = 0.2;
    }
}


- (void)actionDPad:(ActionDPad *)actionDPad
isHoldingDirection:(ActionDPadDirection)direction
{
    CGPoint directionVector = [self vectorForDirection:direction];
    [self.hero moveWithDirection:directionVector];
}

- (void)actionDPadTouchEnded:(ActionDPad *)actionDPad
{
    if (self.eventState != kEventStateScripted &&
        (self.hero.actionState == kActionStateWalk ||
         self.hero.actionState == kActionStateRun)) {
            
            [self.hero idle];
        }
}

- (CGPoint)vectorForDirection:(ActionDPadDirection)direction
{
    CGFloat maxX = 1.0;
    CGFloat maxY = 0.75;
    
    switch (direction) {
        case kActionDPadDirectionCenter:
            return CGPointZero;
            break;
        case kActionDPadDirectionUp:
            return CGPointMake(0.0, maxY);
            break;
        case kActionDPadDirectionUpRight:
            return CGPointMake(maxX, maxY);
            break;
        case kActionDPadDirectionRight:
            return CGPointMake(maxX, 0.0);
            break;
        case kActionDPadDirectionDownRight:
            return CGPointMake(maxX, -maxY);
            break;
        case kActionDPadDirectionDown:
            return CGPointMake(0.0, -maxY);
            break;
        case kActionDPadDirectionDownLeft:
            return CGPointMake(-maxX, -maxY);
            break;
        case kActionDPadDirectionLeft:
            return CGPointMake(-maxX, 0.0);
            break;
        case kActionDPadDirectionUpLeft:
            return CGPointMake(-maxX, maxY);
            break;
        default:
            return CGPointZero;
            break;
    }
}

- (void)update:(NSTimeInterval)delta
{
    [_hero update:delta];
    
    Weapon *weapon;
    for (weapon in self.weapons) {
        [weapon update:delta];
    }
    
    if (self.boss) {
        [self.boss update:delta];
    }
    
    for (ArtificialIntelligence *brain in self.brains) {
        [brain update:delta];
    }
    
    for (Robot *robot in self.robots) {
        [robot update:delta];
    }
    [self updatePositions];
    [self reorderActors];
    
    if (self.runDelay > 0) {
        self.runDelay -= delta;
    }
    
    if (self.eventState == kEventStateFreeWalk ||
        self.eventState == kEventStateScripted) {
        
        [self setViewpointCenter:self.hero.position];
    }
    
    [self updateEvent];
    
    if (self.viewPointOffset < 0) {
        
        self.viewPointOffset += SCREEN.width * delta;
        
        if (self.viewPointOffset >= 0) {
            self.viewPointOffset = 0;
        }
        
    } else if (self.viewPointOffset > 0) {
        
        self.viewPointOffset -= SCREEN.width * delta;
        
        if (self.viewPointOffset <= 0) {
            self.viewPointOffset = 0;
        }
    }
}

- (void)updateEvent
{
    if (self.eventState == kEventStateBattle &&
        self.activeEnemies <= 0) {
        
        CGFloat maxCenterX =
        self.tileMap.mapSize.width *
        self.tileMap.tileSize.width *
        kPointFactor - CENTER.x;
        
        CGFloat cameraX =
        MAX(MIN(self.hero.position.x, maxCenterX), CENTER.x);
        
        self.viewPointOffset = cameraX  - self.eventCenter;
        
        //add this
        if (self.battleEvents.count == 0) {
            [self exitLevel];
        } else {
            self.eventState = kEventStateFreeWalk;
        }
        
    } else if (self.eventState == kEventStateFreeWalk) {
        //modified this part
        [self cycleEvents];
        
        //add this
    } else if (self.eventState == kEventStateScripted) {
        
        CGFloat exitX =
        self.tileMap.tileSize.width *
        self.tileMap.mapSize.width *
        kPointFactor + self.hero.centerToSides;
        
        if (self.hero.position.x >= exitX) {
            
            self.eventState = kEventStateEnd;
            if (self.currentLevel < self.totalLevels - 1) {
                
                //next level
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"PresentGame"
                 object:nil
                 userInfo:@{@"Level" : @(self.currentLevel + 1)}];
                
            } else {
                //end game
                [self.hud showMessage:@"YOU WIN" color:[UIColor fullHPColor]];
                
                [self runAction:[SKAction sequence:@[[SKAction waitForDuration:2.0], [SKAction runBlock:^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"PresentTitle" object:nil];
                }]]]];
            }
        }
    }
}

- (void)exitLevel
{
    self.eventState = kEventStateScripted;
    
    CGFloat exitX =
    self.tileMap.tileSize.width *
    self.tileMap.mapSize.width *
    kPointFactor + self.hero.centerToSides;
    
    [self.hero exitFrom:self.hero.position
                     to:CGPointMake(exitX, self.hero.position.y)];
}


- (void)cycleEvents
{
    
    NSDictionary *event;
    NSInteger column;
    
    CGFloat tileWidth =
    self.tileMap.tileSize.width * kPointFactor;
    
    for (event in self.battleEvents) {
        
        column = [event[@"Column"] integerValue];
        
        CGFloat maxCenterX = self.tileMap.mapSize.width * self.tileMap.tileSize.width * kPointFactor - CENTER.x;
        
        CGFloat columnPosition = column * tileWidth - tileWidth/2;
        
        self.eventCenter =
        MAX(MIN(columnPosition, maxCenterX), CENTER.x);
        
        //1
        if (self.hero.position.x >= self.eventCenter) {
            
            self.currentEvent = event;
            self.eventState = kEventStateBattle;
            NSMutableArray *enemyData =
            [NSMutableArray arrayWithArray:event[@"Enemies"]];
            self.activeEnemies = enemyData.count;
            [self spawnEnemies:enemyData fromOrigin:self.eventCenter];
            [self setViewpointCenter:CGPointMake(self.eventCenter, self.hero.position.y)];
            break;
        }
    }
    
    if (self.eventState == kEventStateBattle) {
        [self.battleEvents removeObject:self.currentEvent];
    }
}

- (CGFloat)getZFromYPosition:(CGFloat)yPosition
{
    return SCREEN.height - yPosition;
}

- (void)reorderActors
{
    CGFloat zPosition =
    [self getZFromYPosition:self.hero.shadow.position.y];
    
    self.hero.zPosition = zPosition;
    
    for (Robot *robot in self.robots) {
        zPosition =
        [self getZFromYPosition:robot.shadow.position.y];
        robot.zPosition = zPosition;
    }
    if (self.boss) {
        zPosition =
        [self getZFromYPosition:self.boss.shadow.position.y];
        
        self.boss.zPosition = zPosition;
    }
    
    Weapon *weapon;
    for (weapon in self.weapons) {
        if (weapon.weaponState != kWeaponStateEquipped) {
            zPosition =
            [self getZFromYPosition:weapon.shadow.position.y];
            weapon.zPosition = zPosition;
        }
    }
    
    MapObject *object;
    for (object in self.mapObjects) {
        
        zPosition = [self getZFromYPosition:object.collisionRect.origin.y + object.collisionRect.size.height/2];
        
        object.zPosition = zPosition;
    }
}

- (void)updatePositions
{
    CGFloat mapWidth = self.tileMap.mapSize.width * self.tileMap.tileSize.width * kPointFactor;
    
    CGFloat floorHeight = 3 * self.tileMap.tileSize.height * kPointFactor;
    
    CGFloat posX, posY;
    
    if (self.hero.actionState > kActionStateNone)
    {
        [self objectCollisionsForSprite:self.hero];
        // 1
        if (self.eventState == kEventStateFreeWalk)
        {
            posX = MIN(mapWidth - self.hero.feetCollisionRect.size.width/2, MAX(self.hero.feetCollisionRect.size.width/2, self.hero.desiredPosition.x));
            
            posY = MIN(floorHeight + (self.hero.centerToBottom - self.hero.feetCollisionRect.size.height), MAX(self.hero.centerToBottom, self.hero.desiredPosition.y));
            
            self.hero.groundPosition = CGPointMake(posX, posY);
            
            self.hero.position = CGPointMake(self.hero.groundPosition.x, self.hero.groundPosition.y + self.hero.jumpHeight);
        }
        // 2
        else if (self.eventState == kEventStateBattle)
        {
            posX = MIN(MIN(mapWidth - self.hero.feetCollisionRect.size.width/2, self.eventCenter + CENTER.x - self.hero.feetCollisionRect.size.width/2), MAX(self.eventCenter - CENTER.x + self.hero.feetCollisionRect.size.width/2, self.hero.desiredPosition.x));
            posY = MIN(floorHeight + (self.hero.centerToBottom - self.hero.feetCollisionRect.size.height), MAX(self.hero.centerToBottom, self.hero.desiredPosition.y));
            
            self.hero.groundPosition = CGPointMake(posX, posY);
            
            self.hero.position = CGPointMake(self.hero.groundPosition.x, self.hero.groundPosition.y + self.hero.jumpHeight);
        }
    }
    
    Robot *robot;
    for (robot in self.robots)
    {
        if (robot.actionState > kActionStateNone)
        {
            [self objectCollisionsForSprite:robot];
            
            posY = MIN(floorHeight + (robot.centerToBottom - robot.feetCollisionRect.size.height), MAX(robot.centerToBottom, robot.desiredPosition.y));
            
            robot.groundPosition = CGPointMake(robot.desiredPosition.x, posY);
            
            robot.position = CGPointMake(robot.groundPosition.x, robot.groundPosition.y + robot.jumpHeight);
            
            if (robot.actionState == kActionStateDead && self.hero.groundPosition.x - robot.groundPosition.x >= SCREEN.width + robot.size.width/2)
            {
                robot.hidden = YES;
                [robot reset];
            }
        }
    }
    
    if (self.boss && self.boss.actionState > kActionStateNone) {
        [self objectCollisionsForSprite:self.boss];
        
        posY = MIN(floorHeight + (self.boss.centerToBottom - self.boss.feetCollisionRect.size.height), MAX(self.boss.centerToBottom, self.boss.desiredPosition.y));
        
        self.boss.groundPosition = CGPointMake(self.boss.desiredPosition.x, posY);
        
        self.boss.position = CGPointMake(self.boss.groundPosition.x, self.boss.groundPosition.y + self.boss.jumpHeight);
        
    }
    
    Weapon *weapon;
    for (weapon in self.weapons) {
        if (weapon.weaponState > kWeaponStateEquipped) {
            weapon.position =
            CGPointMake(weapon.groundPosition.x,
                        weapon.groundPosition.y + weapon.jumpHeight);
        }
    }
}


- (void)setViewpointCenter:(CGPoint)position {
    
    NSInteger x = MAX(position.x, CENTER.x);
    NSInteger y = MAX(position.y, CENTER.y);
    
    x = MIN(x, (self.tileMap.mapSize.width *    self.tileMap.tileSize.width * kPointFactor)
            - CENTER.x);
    
    y = MIN(y, (self.tileMap.mapSize.height * self.tileMap.tileSize.height * kPointFactor)
            - CENTER.y);
    
    CGPoint actualPosition = CGPointMake(x, y);
    CGPoint viewPoint = CGPointSubtract(CENTER, actualPosition);
    
    self.position = CGPointMake(viewPoint.x + self.viewPointOffset, viewPoint.y);
}

- (BOOL)actionSpriteDidDie:(ActionSprite *)actionSprite
{
    if (actionSprite == self.hero) {
        [self.hud setHitPoints:0 fromMaxHP:self.hero.maxHitPoints];
        
        [self.hud showMessage:@"GAME OVER"
                        color:[UIColor lowHPColor]];
        
        [self runAction:[SKAction sequence:@[[SKAction waitForDuration:2.0], [SKAction runBlock:^{[[NSNotificationCenter defaultCenter] postNotificationName:@"PresentTitle" object:nil];}]]]];
    } else {
        
        self.activeEnemies--;
        return YES;
    }
    
    return NO;
}


- (BOOL)actionSpriteDidAttack:(ActionSprite *)actionSprite
{
    
    BOOL didHit = NO;
    if (actionSprite == self.hero) {
        
        CGPoint attackPosition;
        Robot *robot;
        for (robot in self.robots) {
            
            
            if (robot.actionState < kActionStateKnockedOut &&
                robot.actionState != kActionStateNone) {
                
                if ([self collisionBetweenAttacker:self.hero
                                         andTarget:robot
                                        atPosition:&attackPosition]) {
                    
                    BOOL showEffect = YES;
                    
                    DamageNumber *damageNumber = [self getDamageNumber];
                    
                    damageNumber.zPosition =
                    MAX(robot.zPosition, self.hero.zPosition) + 1;
                    
                    if (self.hero.actionState == kActionStateJumpAttack) {
                        
                        //add this
                        [self runAction:[SKAction playSoundFileNamed:@"hit1.caf" waitForCompletion:NO]];
                        
                        [robot knockoutWithDamage:self.hero.jumpAttackDamage
                                        direction:CGPointMake(self.hero.directionX, 0)];
                        
                        [damageNumber showWithValue:self.hero.jumpAttackDamage
                                         fromOrigin:robot.position];
                        
                        showEffect = NO;
                        
                    } else if (self.hero.actionState ==
                               kActionStateRunAttack) {
                        
                        //add this
                        [self runAction:[SKAction playSoundFileNamed:@"hit0.caf" waitForCompletion:NO]];
                        
                        [robot knockoutWithDamage:self.hero.runAttackDamage
                                        direction:CGPointMake(self.hero.directionX, 0)];
                        
                        [damageNumber showWithValue:self.hero.runAttackDamage
                                         fromOrigin:robot.position];
                        
                    } else if (self.hero.actionState ==
                               kActionStateAttackThree)  {
                        
                        //add this
                        [self runAction:[SKAction playSoundFileNamed:@"hit1.caf" waitForCompletion:NO]];
                        
                        [robot knockoutWithDamage:self.hero.attackThreeDamage
                                        direction:CGPointMake(self.hero.directionX, 0)];
                        
                        [damageNumber showWithValue:self.hero.attackThreeDamage
                                         fromOrigin:robot.position];
                        
                        showEffect = NO;
                        
                    } else if (self.hero.actionState ==
                               kActionStateAttackTwo) {
                        
                        //add this
                        [self runAction:[SKAction playSoundFileNamed:@"hit0.caf" waitForCompletion:NO]];
                        
                        [robot hurtWithDamage:self.hero.attackTwoDamage
                                        force:self.hero.attackForce
                                    direction:CGPointMake(self.hero.directionX, 0.0)];
                        
                        [damageNumber showWithValue:self.hero.attackTwoDamage
                                         fromOrigin:robot.position];
                        
                    } else {
                        
                        //add this
                        [self runAction:[SKAction playSoundFileNamed:@"hit0.caf" waitForCompletion:NO]];
                        
                        [robot hurtWithDamage:self.hero.attackDamage
                                        force:self.hero.attackForce
                                    direction:CGPointMake(self.hero.directionX, 0.0)];
                        
                        [damageNumber showWithValue:self.hero.attackDamage
                                         fromOrigin:robot.position];
                    }
                    
                    didHit = YES;
                    
                    if (showEffect) {
                        HitEffect *hitEffect = [self getHitEffect];
                        hitEffect.zPosition = damageNumber.zPosition + 1;
                        [hitEffect showEffectAtPosition:attackPosition];
                    }
                }
            }
        }
        
        if (self.boss &&
            self.boss.actionState < kActionStateKnockedOut &&
            self.boss.actionState != kActionStateNone) {
            
            if ([self collisionBetweenAttacker:self.hero
                                     andTarget:self.boss
                                    atPosition:&attackPosition]) {
                
                BOOL showEffect = YES;
                DamageNumber *damageNumber = [self getDamageNumber];
                damageNumber.zPosition = MAX(self.boss.zPosition,
                                             self.hero.zPosition) + 1;
                
                if (self.hero.actionState == kActionStateJumpAttack) {
                    
                    //add this
                    [self runAction:[SKAction playSoundFileNamed:@"hit1.caf" waitForCompletion:NO]];
                    
                    [self.boss hurtWithDamage:self.hero.jumpAttackDamage force:self.hero.attackForce direction:CGPointMake(self.hero.directionX, 0)];
                    
                    [damageNumber showWithValue:self.hero.jumpAttackDamage fromOrigin:self.boss.position];
                    
                    showEffect = NO;
                    
                } else if (self.hero.actionState ==
                           kActionStateRunAttack) {
                    
                    //add this
                    [self runAction:[SKAction playSoundFileNamed:@"hit0.caf" waitForCompletion:NO]];
                    
                    [self.boss hurtWithDamage:self.hero.runAttackDamage force:self.hero.attackForce direction:CGPointMake(self.hero.directionX, 0)];
                    
                    [damageNumber showWithValue:self.hero.runAttackDamage fromOrigin:self.boss.position];
                    
                } else if (self.hero.actionState ==
                           kActionStateAttackThree) {
                    
                    //add this
                    [self runAction:[SKAction playSoundFileNamed:@"hit1.caf" waitForCompletion:NO]];
                    
                    [self.boss hurtWithDamage:self.hero.attackThreeDamage force:self.hero.attackForce direction:CGPointMake(self.hero.directionX, 0)];
                    
                    [damageNumber showWithValue:self.hero.attackThreeDamage fromOrigin:self.boss.position];
                    
                    showEffect = NO;
                    
                } else if (self.hero.actionState ==
                           kActionStateAttackTwo) {
                    
                    //add this
                    [self runAction:[SKAction playSoundFileNamed:@"hit0.caf" waitForCompletion:NO]];
                    
                    [self.boss hurtWithDamage:self.hero.attackTwoDamage force:self.hero.attackForce/2 direction:CGPointMake(self.hero.directionX, 0.0)];
                    
                    [damageNumber showWithValue:self.hero.attackTwoDamage fromOrigin:self.boss.position];
                    
                } else {
                    
                    //add this
                    [self runAction:[SKAction playSoundFileNamed:@"hit0.caf" waitForCompletion:NO]];
                    
                    [self.boss hurtWithDamage:self.hero.attackDamage force:0 direction:CGPointMake(self.hero.directionX, 0.0)];
                    
                    [damageNumber showWithValue:self.hero.attackDamage fromOrigin:self.boss.position];
                }
                
                didHit = YES;
                
                if (showEffect) {
                    HitEffect *hitEffect = [self getHitEffect];
                    hitEffect.zPosition = damageNumber.zPosition + 1;
                    [hitEffect showEffectAtPosition:attackPosition];
                }
            }
        }
        
        MapObject *mapObject;
        for (mapObject in self.mapObjects) {
            
            if ([self collisionBetweenAttacker:self.hero
                                     andObject:mapObject
                                    atPosition:&attackPosition]) {
                
                HitEffect *hitEffect = [self getHitEffect];
                hitEffect.zPosition = MAX(mapObject.zPosition,
                                          self.hero.zPosition) + 1;
                
                [hitEffect showEffectAtPosition:attackPosition];
                
                if (mapObject.objectState != kObjectStateDestroyed) {
                    
                    //add this
                    [self runAction:[SKAction playSoundFileNamed:@"hit1.caf" waitForCompletion:NO]];
                    
                    [mapObject destroyed];
                    Weapon *weapon = [self getWeapon];
                    [weapon droppedFrom:mapObject.size.height/2 to:CGPointMake(mapObject.position.x, mapObject.position.y - mapObject.size.height/2)];
                    weapon.hidden = NO;
                }
                //add this else clause
                else {
                    [self runAction:[SKAction playSoundFileNamed:@"hit0.caf" waitForCompletion:NO]];
                }
            }
        }
        
        return didHit;
        
    }
    
    else if (actionSprite == self.boss) {
        
        if (self.hero.actionState < kActionStateKnockedOut &&
            self.hero.actionState != kActionStateNone) {
            
            CGPoint attackPosition;
            
            if ([self collisionBetweenAttacker:self.boss
                                     andTarget:self.hero
                                    atPosition:&attackPosition]) {
                
                //add this
                [self runAction:[SKAction playSoundFileNamed:@"hit1.caf"
                                           waitForCompletion:NO]];
                
                [self.hero knockoutWithDamage:self.boss.attackDamage
                                    direction:CGPointMake(actionSprite.directionX, 0.0)];
                
                [self.hud setHitPoints:self.hero.hitPoints
                             fromMaxHP:self.hero.maxHitPoints];
                
                didHit = YES;
                
                DamageNumber *damageNumber = [self getDamageNumber];
                
                [damageNumber showWithValue:self.boss.attackDamage
                                 fromOrigin:self.hero.position];
                
                damageNumber.zPosition = MAX(self.boss.zPosition,
                                             self.hero.zPosition) + 1;
                
                HitEffect *hitEffect = [self getHitEffect];
                hitEffect.zPosition = damageNumber.zPosition + 1;
                [hitEffect showEffectAtPosition:attackPosition];
            }
        }
    }
    
    else {
        
        if (self.hero.actionState < kActionStateKnockedOut &&
            self.hero.actionState != kActionStateNone) {
            
            CGPoint attackPosition;
            if ([self collisionBetweenAttacker:actionSprite
                                     andTarget:self.hero
                                    atPosition:&attackPosition]) {
                
                //add this
                [self runAction:[SKAction playSoundFileNamed:@"hit0.caf"
                                           waitForCompletion:NO]];
                
                [self.hero hurtWithDamage:actionSprite.attackDamage
                                    force:actionSprite.attackForce
                                direction:CGPointMake(actionSprite.directionX, 0.0)];
                
                [self.hud setHitPoints:self.hero.hitPoints
                             fromMaxHP:self.hero.maxHitPoints];
                
                didHit = YES;
                
                DamageNumber *damageNumber = [self getDamageNumber];
                
                damageNumber.zPosition =
                MAX(actionSprite.zPosition, self.hero.zPosition) + 1;
                
                [damageNumber showWithValue:actionSprite.attackDamage
                                 fromOrigin:self.hero.position];
                
                HitEffect *hitEffect = [self getHitEffect];
                hitEffect.zPosition = damageNumber.zPosition + 1;
                [hitEffect showEffectAtPosition:attackPosition];
            }
        }
    }
    
    return didHit;
}


- (void)actionSpriteDidFinishAutomatedWalking:(ActionSprite *)actionSprite
{
    self.eventState = kEventStateFreeWalk;
}

- (BOOL)collisionBetweenAttacker:(ActionSprite *)attacker
                       andObject:(MapObject *)object
                      atPosition:(CGPoint *)position
{
    //first phase: check if they're on the same plane
    CGFloat objectBottom = object.collisionRect.origin.y;
    
    CGFloat objectTop =
    objectBottom + object.collisionRect.size.height;
    
    CGFloat attackerBottom = attacker.feetCollisionRect.origin.y;
    
    CGFloat attackerTop =
    attackerBottom + attacker.feetCollisionRect.size.height;
    
    if ((attackerBottom > objectBottom &&
         attackerBottom < objectTop) ||
        (attackerTop > objectBottom &&
         attackerTop < objectTop)) {
            
            NSInteger i, j;
            CGFloat combinedRadius =
            attacker.detectionRadius + object.detectionRadius;
            
            //initial detection
            if (CGPointDistanceSQ(attacker.position, object.position)
                <= combinedRadius * combinedRadius) {
                
                NSInteger attackPointCount = attacker.attackPoints.count;
                NSInteger contactPointCount = object.contactPointCount;
                
                ContactPoint attackPoint, contactPoint;
                
                //secondary detection
                for (i = 0; i < attackPointCount; i++) {
                    
                    NSValue *value = attacker.attackPoints[i];
                    [value getValue:&attackPoint];
                    
                    for (j = 0; j < contactPointCount; j++) {
                        
                        contactPoint = object.contactPoints[j];
                        
                        combinedRadius =
                        attackPoint.radius + contactPoint.radius;
                        
                        if (CGPointDistanceSQ(attackPoint.position, contactPoint.position) <= combinedRadius * combinedRadius)
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

- (BOOL)collisionBetweenPlayer:(ActionSprite *)player
                     andWeapon:(Weapon *)weapon
{
    // 1: check if they're on the same plane
    CGFloat planeDist =
    player.shadow.position.y - weapon.shadow.position.y;
    
    if (fabsf(planeDist) <= kPlaneHeight) {
        
        CGFloat combinedRadius =
        player.detectionRadius + weapon.detectionRadius;
        
        NSInteger i;
        
        // 2: initial detection
        if (CGPointDistanceSQ(player.position, weapon.position) <=
            combinedRadius * combinedRadius) {
            
            NSInteger contactPointCount = player.contactPoints.count;
            ContactPoint contactPoint;
            
            // 3: secondary detection
            for (i = 0; i < contactPointCount; i++) {
                
                NSValue *value = player.contactPoints[i];
                [value getValue:&contactPoint];
                
                combinedRadius =
                contactPoint.radius + weapon.detectionRadius;
                
                if (CGPointDistanceSQ(contactPoint.position, weapon.position) <= combinedRadius * combinedRadius) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (void)objectCollisionsForSprite:(ActionSprite *)sprite
{
    
    MapObject *mapObject;
    
    for (mapObject in self.mapObjects) {
        
        if (CGRectIntersectsRect(sprite.feetCollisionRect,
                                 mapObject.collisionRect)) {
            
            CGFloat x = sprite.desiredPosition.x;
            CGFloat y = sprite.desiredPosition.y;
            
            CGRect intersect =
            CGRectIntersection(sprite.feetCollisionRect,
                               mapObject.collisionRect);
            
            if (intersect.size.width > intersect.size.height) {
                if (sprite.groundPosition.y < mapObject.position.y) {
                    y = sprite.desiredPosition.y - intersect.size.height;
                } else {
                    y = sprite.desiredPosition.y + intersect.size.height;
                }
            } else {
                if (sprite.groundPosition.x < mapObject.position.x) {
                    x = sprite.desiredPosition.x - intersect.size.width;
                } else {
                    x = sprite.desiredPosition.x + intersect.size.width;
                }
            }
            
            sprite.desiredPosition = CGPointMake(x, y);
        }
    }
}

- (BOOL)collisionBetweenAttacker:(ActionSprite *)attacker
                       andTarget:(ActionSprite *)target
                      atPosition:(CGPoint *)position
{
    //first phase: check if they're on the same plane
    CGFloat planeDist =
    attacker.shadow.position.y - target.shadow.position.y;
    
    if (fabsf(planeDist) <= kPlaneHeight) {
        
        NSInteger i, j;
        CGFloat combinedRadius =
        attacker.detectionRadius + target.detectionRadius;
        
        //initial detection
        if (CGPointDistanceSQ(attacker.position, target.position)
            <= combinedRadius * combinedRadius) {
            
            NSInteger attackPointCount = attacker.attackPoints.count;
            NSInteger contactPointCount = target.contactPoints.count;
            
            ContactPoint attackPoint, contactPoint;
            
            //secondary detection
            for (i = 0; i < attackPointCount; i++) {
                
                NSValue *value = attacker.attackPoints[i];
                [value getValue:&attackPoint];
                
                for (j = 0; j < contactPointCount; j++) {
                    
                    NSValue *value = target.contactPoints[j];
                    [value getValue:&contactPoint];
                    
                    combinedRadius =
                    attackPoint.radius + contactPoint.radius;
                    
                    if (CGPointDistanceSQ(attackPoint.position, contactPoint.position) <= combinedRadius * combinedRadius) {
                        
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

#pragma mark - ActionButtonDelegate methods
- (void)actionButtonWasPressed:(ActionButton *)actionButton
{
    if (self.eventState == kEventStateScripted) return;
    
    if ([actionButton.name isEqualToString:@"ButtonA"]) {
        
        //replace the contents of this if statement
        BOOL pickedUpWeapon = NO;
        
        if (!self.hero.weapon) {
            
            //check collision for all weapons
            for (Weapon *weapon in self.weapons) {
                
                if (weapon.weaponState == kWeaponStateUnequipped) {
                    
                    if ([self collisionBetweenPlayer:self.hero
                                           andWeapon:weapon]) {
                        
                        pickedUpWeapon = [self.hero pickUpWeapon:weapon];
                        weapon.zPosition = self.hero.zPosition + 1;
                        break;
                    }
                }
            }
        }
        
        if (!pickedUpWeapon) {
            [self.hero attack];
        }
        
    } else if ([actionButton.name isEqualToString:@"ButtonB"]) {
        
        //replace the contents of this else if statement
        if (self.hero.weapon) {
            [self.hero dropWeapon];
        } else {
            CGPoint directionVector =
            [self vectorForDirection:self.hud.dPad.direction];
            [self.hero jumpRiseWithDirection:directionVector];
        }
    }
}

- (void)actionButtonWasReleased:(ActionButton *)actionButton
{
    if (self.eventState == kEventStateScripted) return;
    
    if ([actionButton.name isEqualToString:@"ButtonB"]) {
        [self.hero jumpCutoff];
    }
}

- (void)actionButtonIsHeld:(ActionButton *)actionButton{
}




@end
