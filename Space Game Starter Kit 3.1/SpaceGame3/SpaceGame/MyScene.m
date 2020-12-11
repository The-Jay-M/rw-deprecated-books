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
#import "Alien.h"
#import "AlienLaser.h"
#import "Powerup.h"

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
  BOOL _okToRestart;
  // NSTimeInterval _timeSinceGameStarted;
  // NSTimeInterval _timeForGameWon;
  SKLabelNode *_levelIntroLabel1;
  SKLabelNode *_levelIntroLabel2;
  NSInteger _numAlienSpawns;
  NSTimeInterval _timeSinceLastAlienSpawn;
  NSTimeInterval _timeForNextAlienSpawn;
  UIBezierPath *_alienPath;
  SKShapeNode *_dd1;
  SKShapeNode *_dd2;
  SKShapeNode *_dd3;
  NSTimeInterval _timeSinceLastPowerup;
  NSTimeInterval _timeForNextPowerup;
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

- (void)shakeScreen:(int)oscillations {
  SKAction *action =
    [SKAction skt_screenShakeWithNode:_gameLayer amount:CGPointMake(0, 10.0)
                         oscillations:oscillations duration:0.1*oscillations];
  [_gameLayer runAction:action];
}

- (void)spawnExplosionAtPosition:(CGPoint)position scale:(float)scale large:(BOOL)large {
  SKEmitterNode *emitter;
  
  if (large) {
    emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"Explosion" ofType:@"sks"]];
  } else {
    emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"SmallExplosion" ofType:@"sks"]];
  }
  emitter.position = position;
  emitter.particleScale = scale;
  emitter.numParticlesToEmit *= scale;
  emitter.particleLifetime /=scale;
  emitter.particlePositionRange = CGVectorMake(emitter.particlePositionRange.dx * scale, emitter.particlePositionRange.dy * scale);
  [emitter runAction:[SKAction skt_removeFromParentAfterDelay:1.0]];
  [_gameLayer addChild:emitter];


  if (large) {
    [self runAction:_soundExplosionLarge];
    [self shakeScreen:10*scale];
  } else {
    [self runAction:_soundExplosionSmall];
  }
  
}

#pragma mark - Transitions

- (void)nextStage {
  [_levelManager nextStage];
  [self newStageStarted];
}

- (void)newStageStarted {
  if (_levelManager.gameState == GameStateDone) {
    [self endScene:YES];
  } else if ([_levelManager boolForProp:@"SpawnLevelIntro"]) {
    [self doLevelIntro];
  }
}

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

  //_timeSinceGameStarted = 0;
  //_timeForGameWon = 30;
  [self nextStage];
}

- (void)spawnPlayer {

  SKAction *moveAction1 = [SKAction moveBy:CGVectorMake(_player.size.width/2 + self.size.width * 0.3, 0) duration:0.5];
  moveAction1.timingMode = SKActionTimingEaseOut;
  SKAction *moveAction2 = [SKAction moveBy:CGVectorMake(-self.size.width * 0.2, 0) duration:0.5];
  moveAction2.timingMode = SKActionTimingEaseInEaseOut;
  [_player runAction:[SKAction sequence:@[moveAction1, moveAction2]]];
  
}

- (void)endScene:(BOOL)win {

  if (_levelManager.gameState == GameStateGameOver) return;
  _levelManager.gameState = GameStateGameOver;
  
  NSString *fontName = @"Avenir-Light";
  
  NSString *message;
  if (win) {
    message = @"You win!";
  } else {
    message = @"You lose!";
  }
  
  // Message Label
  SKLabelNode *messageLabel = [SKLabelNode labelNodeWithFontNamed:fontName];
  [messageLabel setScale:0];
  messageLabel.text = message;
  messageLabel.fontSize = [self fontSizeForDevice:96.0];
  messageLabel.fontColor = [SKColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
  messageLabel.position = CGPointMake(self.size.width/2, self.size.height * 0.6);
  messageLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
  [_hudLayer addChild:messageLabel];

  SKAction *scaleAction = [SKAction scaleTo:1 duration:0.5];
  scaleAction.timingMode = SKActionTimingEaseOut;
  [messageLabel runAction:scaleAction];
  
  // Restart Label
  SKLabelNode *restartLabel = [SKLabelNode labelNodeWithFontNamed:fontName];
  [restartLabel setScale:0];
  restartLabel.text = @"Tap to Restart";
  restartLabel.fontSize = [self fontSizeForDevice:32.0];
  restartLabel.fontColor = [SKColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
  restartLabel.position = CGPointMake(self.size.width/2, self.size.height * 0.3);
  restartLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
  [_hudLayer addChild:restartLabel];
  
  SKAction *waitAction = [SKAction waitForDuration:1.5];
  SKAction *scaleUpAction = [SKAction scaleTo:1.1 duration:0.5];
  scaleUpAction.timingMode = SKActionTimingEaseInEaseOut;
  SKAction *scaleDownAction = [SKAction scaleTo:0.9 duration:0.5];
  scaleDownAction.timingMode = SKActionTimingEaseInEaseOut;
  SKAction *okToRestartAction = [SKAction runBlock:^{
    _okToRestart = YES;
  }];
  SKAction *throbAction = [SKAction repeatActionForever:[SKAction sequence:@[scaleUpAction, scaleDownAction]]];
  SKAction *displayAndThrob = [SKAction sequence:@[waitAction, scaleAction, okToRestartAction, throbAction]];
  [restartLabel runAction:displayAndThrob];

}

- (void)doLevelIntro {
  
  NSString *fontName = @"Avenir-Light";
  
  NSString *message1 = [NSString stringWithFormat:@"Level %d", (int)_levelManager.curLevelIdx+1];
  NSString *message2 = [_levelManager stringForProp:@"LText"];

  // Level Intro Label 1
  _levelIntroLabel1 = [SKLabelNode labelNodeWithFontNamed:fontName];
  [_levelIntroLabel1 setScale:0];
  _levelIntroLabel1.text = message1;
  _levelIntroLabel1.fontSize = [self fontSizeForDevice:48.0];
  _levelIntroLabel1.fontColor = [SKColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
  _levelIntroLabel1.position = CGPointMake(self.size.width/2, self.size.height * 0.6);
  _levelIntroLabel1.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
  [_hudLayer addChild:_levelIntroLabel1];

  SKAction *scaleUpAction1 = [SKAction scaleTo:1 duration:0.5];
  scaleUpAction1.timingMode = SKActionTimingEaseOut;
  SKAction *delayAction1 = [SKAction waitForDuration:3.0];
  SKAction *scaleDownAction1 = [SKAction scaleTo:0 duration:0.5];
  scaleDownAction1.timingMode = SKActionTimingEaseOut;
  SKAction *removeAction = [SKAction removeFromParent];
  SKAction *scaleUpDown = [SKAction sequence:@[scaleUpAction1, delayAction1, scaleDownAction1, removeAction]];
  [_levelIntroLabel1 runAction:scaleUpDown];
  
  // Level Intro Label 2
  _levelIntroLabel2 = [SKLabelNode labelNodeWithFontNamed:fontName];
  [_levelIntroLabel2 setScale:0];
  _levelIntroLabel2.text = message2;
  _levelIntroLabel2.fontSize = [self fontSizeForDevice:48.0];
  _levelIntroLabel2.fontColor = [SKColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
  _levelIntroLabel2.position = CGPointMake(self.size.width/2, self.size.height * 0.4);
  _levelIntroLabel2.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
  [_hudLayer addChild:_levelIntroLabel2];

  [_levelIntroLabel2 runAction:scaleUpDown];
  
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
  
  if (_levelManager.gameState == GameStateGameOver && _okToRestart) {
    MyScene * myScene = [MyScene sceneWithSize:self.size];
    SKTransition * reveal = [SKTransition flipHorizontalWithDuration:0.5];
    [self.view presentScene:myScene transition:reveal];  
    return;
  }
  
}

#pragma mark - Update methods

- (void)updatePlayer {
  CGFloat kFilteringFactor = 0.75;
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

- (void)updateLevel {
  BOOL newStage = [_levelManager update];
  if (newStage) {
    [self newStageStarted];
  }
}

- (void)updateChildren {

  [_gameLayer.children enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    if ([obj isKindOfClass:[Entity class]]) {
      Entity *entity = (Entity *)obj;
      [entity update:_deltaTime];
    }
  }];

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
  
  //_timeSinceGameStarted += _deltaTime;
  //if (_timeSinceGameStarted > _timeForGameWon) {
  //  [self endScene:YES];
  //}
  [self updateLevel];
  [self updateAliens];
  [self updateChildren];
  [self updatePowerups];
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

  if (![_levelManager boolForProp:@"SpawnAsteroids"]) return;

  float spawnSecsLow = [_levelManager floatForProp:@"ASpawnSecsLow"];
  float spawnSecsHigh = [_levelManager floatForProp:@"ASpawnSecsHigh"];

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

- (void)spawnAlienLaserAtPosition:(CGPoint)position {

  AlienLaser * laser = [[AlienLaser alloc] init];
  laser.position = position;
  [_gameLayer addChild:laser];
  
  SKAction *moveAction = [SKAction moveBy:CGVectorMake(-self.size.width, 0) duration:2.0];
  SKAction *removeAction = [SKAction removeFromParent];
  [laser runAction:[SKAction sequence:@[moveAction, removeAction]]];
  
  [self runAction:_soundLaserEnemy];
}

#pragma mark - Aliens

- (void)spawnAlien {
  
  // 1
  if (_numAlienSpawns == 0) {
    
    // 2
    CGPoint alienPosStart = CGPointMake(
      self.size.width * 1.3,
      RandomFloatRange(self.size.height*0.9, self.size.height * 1.0));
    // 3
    CGPoint cp1 = CGPointMake(
      RandomFloatRange(-self.size.width * 0.1, self.size.width * 0.6),
      RandomFloatRange(self.size.height * 0.7, self.size.height * 1.0));
    // 4
    CGPoint alienPosEnd = CGPointMake(
      self.size.width * 1.3,
      RandomFloatRange(0, self.size.height * 0.1));
    // 5
    CGPoint cp2 = CGPointMake(
      RandomFloatRange(-self.size.width * 0.1, self.size.width * 0.6),
      RandomFloatRange(0, self.size.height * 0.3));
    
    // 6
    _alienPath = [[UIBezierPath alloc] init];
    [_alienPath moveToPoint:alienPosStart];
    [_alienPath addCurveToPoint:alienPosEnd controlPoint1:cp1 controlPoint2:cp2];

    // 7
    _numAlienSpawns = RandomFloatRange(1, 20);
    _timeForNextAlienSpawn = 1.0;
    
    // 8
    [_dd1 removeFromParent];
    [_dd2 removeFromParent];
    [_dd3 removeFromParent];
    
    _dd1 = [self attachDebugFrameFromPath:_alienPath.CGPath color:[SKColor greenColor]];
    _dd2 = [self attachDebugFrameFromPoint:alienPosStart toPoint:cp1 color:[SKColor blueColor]];
    _dd3 = [self attachDebugFrameFromPoint:alienPosEnd toPoint:cp2 color:[SKColor blueColor]];
    
  } else {
    // 9
    _numAlienSpawns -= 1;
    
    // 10
    Alien *alien = [[Alien alloc] init];
    alien.name = @"alien";
    SKAction *pathAction = [SKAction followPath:_alienPath.CGPath asOffset:NO orientToPath:NO duration:3.0];
    SKAction *removeAction = [SKAction removeFromParent];
    [alien runAction:[SKAction sequence:@[pathAction, removeAction]]];
    [_gameLayer addChild:alien];
  }
}

- (void)updateAliens {

  if (![_levelManager boolForProp:@"SpawnAlienSwarm"]) return;

  _timeSinceLastAlienSpawn += _deltaTime;
  if (_timeSinceLastAlienSpawn > _timeForNextAlienSpawn) {
    _timeSinceLastAlienSpawn = 0;
    _timeForNextAlienSpawn = 0.3;
    [self spawnAlien];
  }
}

#pragma mark - Powerups

- (void)spawnPowerup {
  
  Powerup *powerup = [[Powerup alloc] init];
  powerup.position = CGPointMake(self.size.width, RandomFloatRange(0, self.size.height));
  SKAction *moveAction = [SKAction moveByX:-self.size.width*1.5 y:0 duration:5.0];
  SKAction *removeAction = [SKAction removeFromParent];
  [powerup runAction:[SKAction sequence:@[moveAction, removeAction]]];
  [_gameLayer addChild:powerup];
  
}

- (void)updatePowerups {

  if (![_levelManager boolForProp:@"SpawnPowerups"]) return;

  _timeSinceLastPowerup += _deltaTime;
  if (_timeSinceLastPowerup > _timeForNextPowerup) {
    _timeSinceLastPowerup = 0;
    _timeForNextPowerup = [_levelManager floatForProp:@"PSpawnSecs"];
    [self spawnPowerup];
  }
}

- (void)applyPowerup {
  [self runAction:_soundPowerup];
  
  // 1
  SKEmitterNode *emitter = [SKEmitterNode skt_emitterNamed:@"Boost"];
  emitter.zPosition = -1;
  [_player addChild:emitter];

  // 2
  float scaleDuration = 1.0;
  float waitDuration = 5.0;

  // 3
  _player.invincible = YES;
  SKAction *moveForwardAction = [SKAction moveByX:self.size.width * 0.6 y:0 duration:scaleDuration];
  SKAction *waitAction = [SKAction waitForDuration:waitDuration];
  SKAction *moveBackAction = [moveForwardAction reversedAction];
  SKAction *boostDoneAction = [SKAction runBlock:^{
    _player.invincible = NO;
    [emitter removeFromParent];
  }];
  [_player runAction:[SKAction sequence:@[moveForwardAction, waitAction, moveBackAction, boostDoneAction]]];

  // 4
  float scale = 0.75;
  float diffX = (_spacedust1.size.width - (_spacedust1.size.width * scale))/2;
  float diffY = (_spacedust1.size.height - (_spacedust1.size.height * scale))/2;
  SKAction *moveOutAction = [SKAction moveByX:diffX y:diffY duration:scaleDuration];
  SKAction *moveInAction = [moveOutAction reversedAction];
  SKAction *scaleOutAction = [SKAction scaleTo:scale duration:scaleDuration];
  SKAction *scaleInAction = [SKAction scaleTo:1.0 duration:scaleDuration];
  SKAction *outAction = [SKAction group:@[moveOutAction, scaleOutAction]];
  SKAction *inAction = [SKAction group:@[moveInAction, scaleInAction]];
  [_gameLayer runAction:[SKAction sequence:@[outAction, waitAction, inAction]]];
  
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
