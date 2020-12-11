//
//  PSKEnemy.m
//  SKPocketCyclops
//
//  Created by Matthijs on 16-11-13.
//  Copyright (c) 2013 Razeware, LLC. All rights reserved.
//

#import "PSKEnemy.h"

@implementation PSKEnemy

- (id)initWithImageNamed:(NSString *)name {
  if (self = [super initWithImageNamed:name]) {
    self.life = 100;
  }
  return self;
}

- (void)tookHit:(PSKCharacter *)character {
  self.life = self.life - 100;
  if (self.life <= 0) {
    [self changeState:kStateDead];
  }
}

- (void)removeSelf {
  self.isActive = NO;
}

@end
