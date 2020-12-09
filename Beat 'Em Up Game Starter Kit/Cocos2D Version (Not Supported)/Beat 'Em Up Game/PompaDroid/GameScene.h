//
//  GameScene.h
//  PompaDroid
//
//  Created by Ray Wenderlich on 2/8/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameScene : CCScene {
    
}

+(id)nodeWithLevel:(int)level;
-(id)initWithLevel:(int)level;

@end
