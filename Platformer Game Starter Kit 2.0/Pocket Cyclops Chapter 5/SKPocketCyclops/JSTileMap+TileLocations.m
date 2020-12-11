//
//  JSTileMap+TileLocations.m
//  SKPocketCyclops
//
//  Created by Matthijs on 15-11-13.
//  Copyright (c) 2013 Razeware, LLC. All rights reserved.
//

#import "JSTileMap+TileLocations.h"

@implementation JSTileMap (TileLocations)

- (CGRect)tileRectFromTileCoords:(CGPoint)tileCoords {
  CGFloat levelHeightInPixels = self.mapSize.height * self.tileSize.height;
  CGPoint origin = CGPointMake(tileCoords.x * self.tileSize.width, levelHeightInPixels - (tileCoords.y + 1) * self.tileSize.height);
  return CGRectMake(origin.x, origin.y, self.tileSize.width, self.tileSize.height);
}

@end

@implementation TMXLayer (TileLocations)

- (NSInteger)tileGIDAtTileCoord:(CGPoint)point {
  return [self.layerInfo tileGidAtCoord:point];
}

@end 
