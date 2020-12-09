//
//  Robot.h
//  PompaDroid
//
//  Created by Ray Wenderlich on 2/12/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ActionSprite.h"

@interface Robot : ActionSprite {
    
}

@property(nonatomic, strong)CCSprite *belt;
@property(nonatomic, strong)CCSprite *smoke;
@property(nonatomic, assign)ColorSet colorSet;

@end
