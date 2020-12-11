//
//  GameLevelLayer.h
//  PocketCyclops
//
//  Created by Jake Gundersen on 9/24/12.
//  Copyright 2012 Jake Gundersen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameLevelLayer : CCLayer {
    
}

+(CCScene *)sceneWithLevel:(int)level;
+(CCScene *) scene;

@end
