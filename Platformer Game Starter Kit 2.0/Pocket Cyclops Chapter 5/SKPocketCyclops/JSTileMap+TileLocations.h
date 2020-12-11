//
//  JSTileMap+TileLocations.h
//  SKPocketCyclops
//
//  Created by Matthijs on 15-11-13.
//  Copyright (c) 2013 Razeware, LLC. All rights reserved.
//

#import "JSTileMap.h"

@interface JSTileMap (TileLocations)
- (CGRect)tileRectFromTileCoords:(CGPoint)tileCoords;
@end

@interface TMXLayer (TileLocations)
- (NSInteger)tileGIDAtTileCoord:(CGPoint)point;
@end
