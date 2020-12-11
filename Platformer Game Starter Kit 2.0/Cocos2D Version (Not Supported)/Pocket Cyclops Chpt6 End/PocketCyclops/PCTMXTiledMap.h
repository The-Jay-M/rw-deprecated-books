//
//  PCTMXTiledMap.h
//  PocketCyclops
//
//  Created by Ray Wenderlich on 1/9/13.
//  Copyright 2013 Jake Gundersen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface PCTMXTiledMap : CCTMXTiledMap {
    
}

- (CGPoint)tileCoordForPosition:(CGPoint)position;
- (CGRect)tileRectFromTileCoords:(CGPoint)tileCoords;
- (NSArray *)getSurroundingTilesAtPosition:(CGPoint)position forLayer:(CCTMXLayer *)layer;

@end
