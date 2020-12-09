//
//  AnimateGroup.h
//  PompaDroid
//
//  Created by Ray Wenderlich on 2/12/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface AnimateGroup : CCAnimate {
}

@property(nonatomic, strong)CCArray *members;

+(id)actionWithAnimation:(CCAnimation *)animation members:(CCArray *)members;
-(id)initWithAnimation:(CCAnimation *)animation members:(CCArray *)members;

+(id)actionWithAnimation:(CCAnimation *)animation memberCount:(int)memberCount;
-(id)initWithAnimation:(CCAnimation *)animation memberCount:(int)memberCount;

@end
