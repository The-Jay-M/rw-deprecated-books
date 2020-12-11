//
//  PSKEnemy.h
//  SKPocketCyclops
//
//  Created by Matthijs on 16-11-13.
//  Copyright (c) 2013 Razeware, LLC. All rights reserved.
//

#import "PSKCharacter.h"
#import "Player.h"
#import "JSTileMap+TileLocations.h"

@interface PSKEnemy : PSKCharacter

@property (nonatomic, weak) Player *player;
@property (nonatomic, weak) JSTileMap *map;

- (void)removeSelf;

@end
