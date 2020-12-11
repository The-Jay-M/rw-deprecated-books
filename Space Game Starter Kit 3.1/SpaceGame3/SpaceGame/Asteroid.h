//
//  Asteroid.h
//  SpaceGame
//
//  Created by Ray Wenderlich on 10/23/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

#import "Entity.h"

typedef NS_ENUM(NSInteger, AsteroidType)
{
  AsteroidTypeSmall = 0,
  AsteroidTypeMedium,
  AsteroidTypeLarge,
  NumAsteroidTypes
};

@interface Asteroid : Entity

@property (assign) AsteroidType asteroidType;

- (instancetype)initWithAsteroidType:(AsteroidType)asteroidType;

@end
