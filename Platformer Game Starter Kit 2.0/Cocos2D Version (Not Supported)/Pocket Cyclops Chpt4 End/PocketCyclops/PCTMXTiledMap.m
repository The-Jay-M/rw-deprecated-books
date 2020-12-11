//
//  PCTMXTiledMap.m
//  PocketCyclops
//
//  Created by Ray Wenderlich on 1/9/13.
//  Copyright 2013 Jake Gundersen. All rights reserved.
//

#import "PCTMXTiledMap.h"

@implementation PCTMXTiledMap

- (CGPoint)tileCoordForPosition:(CGPoint)position
{
    float x = floor(position.x / self.tileSize.width);
    float levelHeightInPixels = self.mapSize.height * self.tileSize.height;
    float y = floor((levelHeightInPixels - position.y) / self.tileSize.height);
    return ccp(x, y);
}

-(CGRect)tileRectFromTileCoords:(CGPoint)tileCoords
{
    float levelHeightInPixels = self.mapSize.height * self.tileSize.height;
    CGPoint origin = ccp(tileCoords.x * self.tileSize.width, levelHeightInPixels - ((tileCoords.y + 1) * self.tileSize.height));
    return CGRectMake(origin.x, origin.y, self.tileSize.width, self.tileSize.height);
}

-(NSArray *)getSurroundingTilesAtPosition:(CGPoint)position forLayer:(CCTMXLayer *)layer {
    //1
    CGPoint plPos = [self tileCoordForPosition:position];
    //2
    NSMutableArray *gids = [NSMutableArray array];
    //3
    for (int i = 0; i < 9; i++) {
        int c = i % 3;
        int r = (int)(i / 3);
        CGPoint tilePos = ccp(plPos.x + (c - 1), plPos.y + (r - 1));
        //4
        int tgid = [layer tileGIDAt:tilePos];
        //5
        CGRect tileRect = [self tileRectFromTileCoords:tilePos];
        //6
        NSDictionary *tileDict = @{
        @"gid":@(tgid),
        @"x":@(tileRect.origin.x),
        @"y":@(tileRect.origin.y),
        @"tilePos":[NSValue valueWithCGPoint:tilePos]};
                      
        [gids addObject:tileDict];
        
    }
    //7
    [gids removeObjectAtIndex:4];
    [gids insertObject:[gids objectAtIndex:2] atIndex:6];
    [gids removeObjectAtIndex:2];
    [gids exchangeObjectAtIndex:4 withObjectAtIndex:6];
    [gids exchangeObjectAtIndex:0 withObjectAtIndex:4];
    //8
    //for (NSDictionary *d in gids) {
    //    NSLog(@"%@", d);
    //}
    return (NSArray *)gids;
}


@end
