//
//  MyScene.m
//  SpaceGame
//
//  Created by Ray Wenderlich on 10/22/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

#import "MyScene.h"
#import "LevelManager.h"
#import "Player.h"
#import "Asteroid.h"
#import "PlayerLaser.h"
#import "ParallaxNode.h"

@import CoreMotion;

@interface MyScene() <SKPhysicsContactDelegate>
@end

@implementation MyScene {
  SKNode *_gameLayer;
  SKNode *_hudLayer;
  SKLabelNode *_titleLabel1;
  SKLabelNode *_titleLabel2;
  SKLabelNode *_playLabel;
  SKAction *_soundExplosionLarge;
  SKAction *_soundExplosionSmall;
  SKAction *_soundLaserEnemy;
  SKAction *_soundLaserShip;
  SKAction *_soundShake;
  SKAction *_soundPowerup;
  SKAction *_soundBoss;
  SKAction *_soundCannon;
  SKAction *_soundTitle;
  LevelManager *_levelManager;
  CMMotionManager *_motionManager;
  NSTimeInterval _lastUpdateTime;
  NSTimeInterval _deltaTime;
  NSTimeInterval _timeSinceLastAsteroidSpawn;
  NSTimeInterval _timeForNextAsteroidSpawn;
  ParallaxNode *_parallaxNode;
  SKSpriteNode *_spacedust1;
  SKSpriteNode *_spacedust2;
  SKSpriteNode *_planetsunrise;
  SKSpriteNode *_galaxy;
  SKSpriteNode *_spatialanomaly;
  SKSpriteNode *_spatialanomaly2;
}

#pragma mark - Init functions

-(id)initWithSize:(CGSize)size {
  if (self = [super initWithSize:size]) {
    self.backgroundColor = [SKColor blackColor];
    [self setupSound];
    [self setupLayers];
    [self setupTitle];
    [self setupStars];
    [self setupLevelManager];
    [self setupPlayer];
    [self setupMotionManager];
    [self setupPhysics];
    [self setupBackground];
  }
  return self;
}

- (void)setupLayers {
  _gameLayer = [SKNode node];
  [self addChild:_gameLayer];
  _hudLayer = [SKNode node];
  [self addChild:_hudLayer];
}

- (void)setupTitle {
  
  NSString *fontName = @"Avenir-Light";
  
  // Title Label 1
  _titleLabel1 = [SKLabelNode labelNodeWithFontNamed:fontName];
  _titleLabel1.text = @"Space Game";
  _titleLabel1.fontSize = [self fontSizeForDevice:48.0];
  _titleLabel1.fontColor = [SKColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
  _titleLabel1.position = CGPointMake(self.size.width/2, self.size.height * 0.8);
  _titleLabel1.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
  [_hudLayer addChild:_titleLabel1];
  
  // Title Label 2
  _titleLabel2 = [SKLabelNode labelNodeWithFontNamed:fontName];
  _titleLabel2.text = @"Starter Kit";
  _titleLabel2.fontSize = [self fontSizeForDevice:96.0];
  _titleLabel2.fontColor = [SKColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
  _titleLabel2.position = CGPointMake(self.size.width/2, self.size.height * 0.6);
  _titleLabel2.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
  [_hudLayer addChild:_titleLabel2];
 
  [_titleLabel1 setScale:0];
  SKAction *waitAction1 = [SKAction waitForDuration:1.0];
  SKAction *scaleAction1 = [SKAction scaleTo:1 duration:0.5];
  scaleAction1.timingMode = SKActionTimingEaseOut;
  [_titleLabel1 runAction:[SKAction sequence:@[waitAction1, _soundTitle, scaleAction1]]];

  [_titleLabel2 setScale:0];
  SKAction *waitAction2 = [SKAction waitForDuration:2.0];
  SKAction *scaleAction2 = [SKAction scaleTo:1 duration:1.0];
  scaleAction2.timingMode = SKActionTimingEaseOut;
  [_titleLabel2 runAction:[SKAction sequence:@[waitAction2, scaleAction2]]];
  
  // Play Label
  _playLabel = [SKLabelNode labelNodeWithFontNamed:fontName];
  [_playLabel setScale:0];
  _playLabel.text = @"Tap to Play";
  _playLabel.fontSize = [self fontSizeForDevice:32.0];
  _playLabel.fontColor = [SKColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
  _playLabel.position = CGPointMake(self.size.width/2, self.size.height * 0.25);
  _playLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
  [_hudLayer addChild:_playLabel];

  SKAction *waitAction3 = [SKAction waitForDuration:3.0];
  SKAction *scaleAction3 = [SKAction scaleTo:1 duration:0.5];
  scaleAction3.timingMode = SKActionTimingEaseOut;
  SKAction *scaleUpAction = [SKAction scaleTo:1.1 duration:0.5];
  scaleUpAction.timingMode = SKActionTimingEaseInEaseOut;
  SKAction *scaleDownAction = [SKAction scaleTo:0.9 duration:0.5];
  scaleDownAction.timingMode = SKActionTimingEaseInEaseOut;
  SKAction *throbAction = [SKAction repeatActionForever:[SKAction sequence:@[scaleUpAction, scaleDownAction]]];
  SKAction *displayAndThrob = [SKAction sequence:@[waitAction3, scaleAction3, throbAction]];
  [_playLabel runAction:displayAndThrob];

}

- (void)setupSound {
  [[SKTAudio sharedInstance] playBackgroundMusic:@"SpaceGame.caf"];
  _soundExplosionLarge = [SKAction playSoundFileNamed:@"explosion_large.caf" waitForCompletion:NO];
  _soundExplosionSmall = [SKAction playSoundFileNamed:@"explosion_small.caf" waitForCompletion:NO];
  _soundLaserEnemy = [SKAction playSoundFileNamed:@"laser_enemy.caf" waitForCompletion:NO];
  _soundLaserShip = [SKAction playSoundFileNamed:@"laser_ship.caf" waitForCompletion:NO];
  _soundShake = [SKAction playSoundFileNamed:@"shake.caf" waitForCompletion:NO];
  _soundPowerup = [SKAction playSoundFileNamed:@"powerup.caf" waitForCompletion:NO];
  _soundBoss = [SKAction playSoundFileNamed:@"boss.caf" waitForCompletion:NO];
  _soundCannon = [SKAction playSoundFileNamed:@"cannon.caf" waitForCompletion:NO];
  _soundTitle = [SKAction playSoundFileNamed:@"title.caf" waitForCompletion:NO];
}

- (void)setupStars {
  // 1
  NSArray *starsArray = @[@"Stars1.sks", @"Stars2.sks", @"Stars3.sks"];
  for (NSString *stars in starsArray) {
    SKEmitterNode *emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:stars ofType:nil]];
    emitter.position = CGPointMake(self.size.width*1.5, self.size.height/2);
    emitter.particlePositionRange = CGVectorMake(emitter.particlePositionRange.dx, self.size.height * 1.5);
    emitter.zPosition = -1;
    [_gameLayer addChild:emitter];
  }
}

- (void)setupLevelManager {
  _levelManager = [[LevelManager alloc] init];
}

- (void)setupPlayer {
  _player = [[Player alloc] init];
  _player.position = CGPointMake(-_player.size.width/2, self.size.height * 0.5);
  _player.zPosition = 1;
  _player.name = @"player";
  [_gameLayer addChild:_player];
}

- (void)setupMotionManager {
  _motionManager = [[CMMotionManager alloc] init];
  _motionManager.accelerometerUpdateInterval = 0.05;
  [_motionManager startAccelerometerUpdates];
}

- (void)setupPhysics {
  self.physicsWorld.contactDelegate = self;
  self.physicsWorld.gravity = CGVectorMake(0, 0);
}

- (void)setupBackground {

  _spacedust1 = [SKSpriteNode spriteNodeWithImageNamed:@"bg_front_spacedust"];
  _spacedust1.position = CGPointMake(0, self.size.height/2);
  _spacedust2 = [SKSpriteNode spriteNodeWithImageNamed:@"bg_front_spacedust"];
  _spacedust2.position = CGPointMake(_spacedust2.size.width, self.size.height/2);
  _planetsunrise = [SKSpriteNode spriteNodeWithImageNamed:@"bg_planetsunrise"];
  _planetsunrise.position = CGPointMake(600, 0);
  _galaxy = [SKSpriteNode spriteNodeWithImageNamed:@"bg_galaxy"];
  _galaxy.position = CGPointMake(0, self.size.height * 0.7);
  _spatialanomaly = [SKSpriteNode spriteNodeWithImageNamed:@"bg_spacialanomaly"];
  _spatialanomaly.position = CGPointMake(900, self.size.height * 0.3);
  _spatialanomaly2 = [SKSpriteNode spriteNodeWithImageNamed:@"bg_spacialanomaly2"];
  _spatialanomaly2.position = CGPointMake(1500, self.size.height * 0.9);
  
  _parallaxNode = [[ParallaxNode alloc] initWithVelocity:CGPointMake(-100, 0)];
  _parallaxNode.position = CGPointMake(0, 0);
  [_parallaxNode addChild:_spacedust1 parallaxRatio:1];
  [_parallaxNode addChild:_spacedust2 parallaxRatio:1];
  [_parallaxNode addChild:_planetsunrise parallaxRatio:0.5];
  [_parallaxNode addChild:_galaxy parallaxRatio:0.5];
  [_parallaxNode addChild:_spatialanomaly parallaxRatio:0.5];
  [_parallaxNode addChild:_spatialanomaly2 parallaxRatio:0.5];
  _parallaxNode.zPosition = -1;
  [_gameLayer addChild:_parallaxNode];
  
}

#pragma mark - Helper methods

- (CGFloat)fontSizeForDevice:(CGFloat)fontSize {
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    return fontSize * 2;
  } else {
    return fontSize;
  }
}

- (void)playExplosionLargeSound {
  [self runAction:_soundExplosionLarge];
}

#pragma mark - Transitions

- (void)startSpawn {
  _levelManager.gameState = GameStatePlay;
  [self runAction:_soundPowerup];
  
  NSArray *nodes = @[_titleLabel1, _titleLabel2, _playLabel];
  for (SKNode *node in nodes) {
    SKAction *scaleAction = [SKAction scaleTo:0 duration:0.5];
    scaleAction.timingMode = SKActionTimingEaseOut;
    SKAction *removeAction = [SKAction removeFromParent];
    [node runAction:[SKAction sequence:@[scaleAction, removeAction]]];
  }
  
  [self spawnPlayer];
}

- (void)spawnPlayer {

  SKAction *moveAction1 = [SKAction moveBy:CGVectorMake(_player.size.width/2 + self.size.width * 0.3, 0) duration:0.5];
  moveAction1.timingMode = SKActionTimingEaseOut;
  SKAction *moveAction2 = [SKAction moveBy:CGVectorMake(-self.size.width * 0.2, 0) duration:0.5];
  moveAction2.timingMode = SKActionTimingEaseInEaseOut;
  [_player runAction:[SKAction sequence:@[moveAction1, moveAction2]]];
  
}

#pragma mark - Touch detection

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

  if (_levelManager.gameState == GameStateMainMenu) {
    [self startSpawn];
    return;
  }
  
  if (_levelManager.gameState == GameStatePlay) {
    [self spawnPlayerLaser];
    return;
  }
  
}

#pragma mark - Update methods

- (void)updatePlayer {
    CGFloat const kFilteringFactor = 0.75;
    static UIAccelerationValue rollingX = 0, rollingY = 0, rollingZ = 0;
    
    rollingX = (_motionManager.accelerometerData.acceleration.x * kFilteringFactor) +
    (rollingX * (1.0 - kFilteringFactor));
    rollingY = (_motionManager.accelerometerData.acceleration.y * kFilteringFactor) +
    (rollingY * (1.0 - kFilteringFactor));
    rollingZ = (_motionManager.accelerometerData.acceleration.z * kFilteringFactor) +
    (rollingZ * (1.0 - kFilteringFactor));
    
    CGFloat accelX = rollingX;
  
    CGFloat kRestAccelX = 0.6;
    CGFloat kPlayerMaxPointsPerSec = self.size.height*0.5;
    CGFloat kMaxDiffX = 0.2;

    CGFloat accelDiffX = kRestAccelX - ABS(accelX);
    CGFloat accelFractionX = accelDiffX / kMaxDiffX;
    CGFloat pointsPerSecX = kPlayerMaxPointsPerSec * accelFractionX;

    CGFloat playerPointsPerSecY = pointsPerSecX;
    CGFloat maxY = self.size.height - _player.size.height/2;
    CGFloat minY = _player.size.height/2;

    CGFloat newY = _player.position.y + (playerPointsPerSecY * _deltaTime);
    newY = MIN(MAX(newY, minY), maxY);
    _player.position = CGPointMake(_player.position.x, newY);
}

- (void)updateBg {
  [_parallaxNode update:_deltaTime];
  // 1
  NSArray *bgs = @[_spacedust1, _spacedust2, _planetsunrise, _galaxy, _spatialanomaly, _spatialanomaly2];
  for (SKSpriteNode * bg in bgs) {
    // 2
    CGPoint scenePos = [bg convertPoint:bg.position toNode:self];
    // 3
    if (scenePos.x < -bg.size.width) {
      bg.position = CGPointAdd(bg.position, CGPointMake(_spacedust1.size.width*2, 0));
    }
  }
}

- (void)update:(CFTimeInterval)currentTime {

  if (_lastUpdateTime) {
    _deltaTime = currentTime - _lastUpdateTime;
  } else {
    _deltaTime = 0;
  }
  _lastUpdateTime = currentTime;
  
  [self updateBg];
  
  if (_levelManager.gameState != GameStatePlay) return;
  
  [self updatePlayer];
  [self updateAsteroids];
  
}

#pragma mark - Asteroids

- (void)spawnAsteroid
{
  CGFloat const moveDurationLow = 2.0;
  CGFloat const moveDurationHigh = 10.0;

  Asteroid *asteroid = [[Asteroid alloc] initWithAsteroidType:arc4random_uniform(NumAsteroidTypes)];
  asteroid.name = @"asteroid";
  asteroid.position = CGPointMake(
    self.size.width + asteroid.size.width/2,
    RandomFloatRange(0, self.size.height));
  [_gameLayer addChild:asteroid];
  
  [asteroid runAction:
    [SKAction sequence:@[
      [SKAction moveBy:CGVectorMake(-self.size.width*1.5, 0) duration:RandomFloatRange(moveDurationLow, moveDurationHigh)],
      [SKAction removeFromParent]
    ]
  ]];
}

- (void)updateAsteroids {

  float spawnSecsLow = 0.2;
  float spawnSecsHigh = 1.0;

  _timeSinceLastAsteroidSpawn += _deltaTime;
  if (_timeSinceLastAsteroidSpawn > _timeForNextAsteroidSpawn) {
    _timeSinceLastAsteroidSpawn = 0;
    _timeForNextAsteroidSpawn = RandomFloatRange(spawnSecsLow, spawnSecsHigh);
    [self spawnAsteroid];
  }

}

#pragma mark - Lasers and Cannons

- (void)spawnPlayerLaser
{
  PlayerLaser *laser = [[PlayerLaser alloc] init];
  laser.position = CGPointMake(_player.position.x + 6, _player.position.y - 4);
  laser.name = @"laser";
  [_gameLayer addChild:laser];
  
  laser.alpha = 0;
  [laser runAction:[SKAction fadeAlphaTo:1.0 duration:0.1]];
  SKAction *actionMove =
    [SKAction moveToX:self.size.width + laser.size.width/2 duration:0.75];
  SKAction *actionRemove = [SKAction removeFromParent];
  [laser runAction:
   [SKAction sequence:@[actionMove, actionRemove]]];
  
  [self runAction:_soundLaserShip];
}

#pragma mark - Physics functions

- (void)didBeginContact:(SKPhysicsContact *)contact
{
  SKNode *node = contact.bodyA.node;
  if ([node isKindOfClass:[Entity class]]) {
    [(Entity*)node collidedWith:contact.bodyB contact:contact];
  }
  
  node = contact.bodyB.node;
  if ([node isKindOfClass:[Entity class]]) {
    [(Entity*)node collidedWith:contact.bodyA contact:contact];
  }
  
}

@end
