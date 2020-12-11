//
//  Boss.m
//  SpaceGame
//
//  Created by Main Account on 11/4/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

#import "Boss.h"
#import "MyScene.h"
#import "Player.h"

@implementation Boss {
  BOOL _initialMove;
  SKSpriteNode *_shooter1;
  SKSpriteNode *_shooter2;
  SKSpriteNode *_cannon;
}

- (instancetype)init {
  if ((self = [super initWithImageNamed:@"Boss_ship" maxHp:50 healthBarType:HealthBarTypeRed])) {
    [self setupCollisionBody];
    [self setupWeapons];
  }
  return self;
}

- (void)setupCollisionBody {
  CGPoint offset = CGPointMake(self.size.width * self.anchorPoint.x, self.size.height * self.anchorPoint.y);
  CGMutablePathRef path = CGPathCreateMutable();
  [self moveToPoint:CGPointMake(60, 98) path:path offset:offset];
  [self addLineToPoint:CGPointMake(142, 107) path:path offset:offset];
  [self addLineToPoint:CGPointMake(175, 42) path:path offset:offset];
  [self addLineToPoint:CGPointMake(155, 14) path:path offset:offset];
  [self addLineToPoint:CGPointMake(39, 9) path:path offset:offset];
  [self addLineToPoint:CGPointMake(6, 27) path:path offset:offset];
  CGPathCloseSubpath(path);

  self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
  [self attachDebugFrameFromPath:path color:[SKColor redColor]];

  self.physicsBody.categoryBitMask = EntityCategoryAlien;
  self.physicsBody.collisionBitMask = 0;
  self.physicsBody.contactTestBitMask = EntityCategoryPlayerLaser;
}

- (void)setupWeapons {

  _shooter1 = [SKSpriteNode spriteNodeWithImageNamed:@"Boss_shooter"];
  _shooter1.position = CGPointMake(self.size.width * .15, 0);
  [self addChild:_shooter1];
  
  _shooter2 = [SKSpriteNode spriteNodeWithImageNamed:@"Boss_shooter"];
  _shooter2.position = CGPointMake(self.size.width * .05, -self.size.height * 0.4);
  [self addChild:_shooter2];
  
  _cannon = [SKSpriteNode spriteNodeWithImageNamed:@"Boss_cannon"];
  _cannon.position = CGPointMake(0, self.size.height * 0.45);
  [self addChild:_cannon];

}

- (void)performRandomAction {

  int randomAction = arc4random() % 5;
  SKAction *action;
  
  if (randomAction == 0 || !_initialMove) {
  
    _initialMove = YES;
    float randWidth = RandomFloatRange(self.scene.size.width * 0.6, self.scene.size.width * 1.0);
    float randHeight =RandomFloatRange(self.scene.size.height * 0.1, self.scene.size.height * 0.9);
    CGPoint randDest = CGPointMake(randWidth, randHeight);
    
    CGPoint offset = CGPointSubtract(self.position, randDest);
    float length = CGPointLength(offset);
    float BOSS_POINTS_PER_SEC = 100.0;
    float duration = length / BOSS_POINTS_PER_SEC;
    
    NSLog(@"Moving to %@ over %0.2f", NSStringFromCGPoint(randDest), duration);
    
    action = [SKAction moveTo:randDest duration:duration];
  
  } else if (randomAction == 1) {
    
    action = [SKAction waitForDuration:0.2];
    
  } else if (randomAction >= 2 && randomAction < 4) {
  
    MyScene *scene = (MyScene *)self.scene;
    [scene spawnAlienLaserAtPosition:[self convertPoint:_shooter1.position toNode:self.parent]];
    [scene spawnAlienLaserAtPosition:[self convertPoint:_shooter2.position toNode:self.parent]];
    action = [SKAction waitForDuration:0.2];
    
  } else if (randomAction == 4) {
  
    MyScene *scene = (MyScene *)self.scene;
    [scene shootCannonBallAtPlayerFromPosition:[self convertPoint:_cannon.position toNode:self.parent]];
    action = [SKAction waitForDuration:0.2];
    
  }

  [self runAction:
    [SKAction sequence:@[
      action,
      [SKAction performSelector:@selector(performRandomAction) onTarget:self]
    ]
  ]];

}

- (void)updateCannon {

  MyScene *scene = (MyScene *)self.scene;
  CGPoint cannonWorld = [self convertPoint:_cannon.position toNode:self.parent];
  CGPoint offsetToPlayer = CGPointSubtract(cannonWorld, scene.player.position);
  float cannonAngle = CGPointToAngle(offsetToPlayer);
  _cannon.zRotation = cannonAngle;

}

- (void)update:(CFTimeInterval)dt {
  [super update:dt];
  
  if (!_initialMove) {
    [self performRandomAction];
  }
  
  [self updateCannon];
}

- (void)collidedWith:(SKPhysicsBody *)body contact:(SKPhysicsContact *)contact {

  Entity * other = (Entity *)body.node;
  if (body.categoryBitMask & EntityCategoryPlayerLaser) {
    [other destroy];
    [self takeHit];
    MyScene *scene = (MyScene *)self.scene;
    if ([self isDead]) {
      [scene spawnExplosionAtPosition:contact.contactPoint scale:self.xScale large:YES];
      [scene nextStage];
    } else {
      [scene spawnExplosionAtPosition:contact.contactPoint scale:self.xScale large:NO];
    }
  }
  
}

@end
