//
//  Enemy.h
//  PocketCyclops
//
//  Created by Ray Wenderlich on 1/23/13.
//  Copyright 2013 Jake Gundersen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Character.h"
#import "Player.h"
#import "PCTMXTiledMap.h"

@interface Enemy : Character {
    
}

-(void)removeSelf;

@property (nonatomic, weak) Player *player;
@property (nonatomic, weak) PCTMXTiledMap *map;

@end
