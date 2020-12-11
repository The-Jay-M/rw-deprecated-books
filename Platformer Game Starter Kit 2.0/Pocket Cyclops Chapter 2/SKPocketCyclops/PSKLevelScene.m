//
//  PSKMyScene.m
//  SKPocketCyclops
//
//  Created by Jake Gundersen on 10/26/13.
//  Copyright (c) 2013 Razeware, LLC. All rights reserved.
//

#import "PSKLevelScene.h"
#import "SKTAudio.h"
#import "JLGParallaxNode.h"
#import "JSTileMap+TileLocations.h"
#import "Player.h"

@interface PSKLevelScene ()

@property (nonatomic, assign) NSUInteger currentLevel;
@property (nonatomic, strong) SKNode *gameNode;
@property (nonatomic, strong) JSTileMap *map;
@property (nonatomic, strong) Player *player;
@property (nonatomic, assign) NSTimeInterval previousUpdateTime;

@end

@implementation PSKLevelScene

- (id)initWithSize:(CGSize)size level:(NSUInteger)currentLevel {
  if ((self = [super initWithSize:size])) {
    self.currentLevel = currentLevel;

    NSString *path = [[NSBundle mainBundle] pathForResource:@"levels" ofType:@"plist"];
    NSDictionary *allLevelsDict = [NSDictionary dictionaryWithContentsOfFile:path];

    NSString *levelString = [NSString stringWithFormat:@"level%ld", (long)self.currentLevel];
    NSDictionary *levelDict = allLevelsDict[levelString];

    NSString *musicFilename = levelDict[@"music"];
    [[SKTAudio sharedInstance] playBackgroundMusic:musicFilename];

    self.gameNode = [SKNode node];
    [self addChild:self.gameNode];

    [self loadParallaxBackground:levelDict];
	
    NSString *levelName = [levelDict objectForKey:@"level"];
    self.map = [JSTileMap mapNamed:levelName];
    [self.gameNode addChild:self.map];

    self.player = [[Player alloc] initWithImageNamed:@"Player1"];
    self.player.zPosition = 900;
    [self.map addChild:self.player];
	
    TMXObjectGroup *objects = [self.map groupNamed:@"objects"];
    NSDictionary *playerObj = [objects objectNamed:@"player"];
    self.player.position = CGPointMake([playerObj[@"x"] floatValue], [playerObj[@"y"] floatValue]);
  }
  return self;
}

- (void)loadParallaxBackground:(NSDictionary *)levelDict {
  JLGParallaxNode *parallaxNode = [JLGParallaxNode node];

  NSArray *backgroundArray = levelDict[@"background"];

  for (NSArray *layerArray in backgroundArray) {

    CGFloat indexOfLayer = [backgroundArray indexOfObject:layerArray] + 1.0;
    CGFloat ratio = (4.0 - indexOfLayer) / 8.0;
    if (indexOfLayer == 4.0) {
      ratio = 0.0;
    }

    for (NSString *chunkFilename in layerArray) {

      SKSpriteNode *backgroundSprite = [SKSpriteNode spriteNodeWithImageNamed:chunkFilename];
      backgroundSprite.anchorPoint = CGPointMake(0.0, 0.0);

      NSInteger indexOfChunk = [layerArray indexOfObject:chunkFilename];

      [parallaxNode addChild:backgroundSprite z:-indexOfLayer parallaxRatio:CGPointMake(ratio, 0.6) positionOffset:CGPointMake(indexOfChunk * 1024, 30)];
    }
  }

  [self.gameNode addChild:parallaxNode];
  parallaxNode.name = @"parallax";
  parallaxNode.zPosition = -1000;
}

- (void)update:(NSTimeInterval)currentTime {
  //1
  NSTimeInterval delta = currentTime - self.previousUpdateTime;
  self.previousUpdateTime = currentTime;
  //2
  if (delta > 0.1) {
    delta = 0.1;
  }
  //3
  [self.player update:delta];
}

@end
