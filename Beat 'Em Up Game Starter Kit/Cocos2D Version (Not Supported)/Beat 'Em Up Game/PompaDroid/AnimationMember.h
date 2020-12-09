//
//  AnimationMember.h
//  PompaDroid
//
//  Created by Ray Wenderlich on 2/12/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface AnimationMember : NSObject {
    id _origFrame;
    __weak CCSprite *_target;
}

@property(nonatomic, strong)CCAnimation *animation;
@property(nonatomic, weak)CCSprite *target;

+(id)memberWithAnimation:(CCAnimation *)animation target:(CCSprite *)target;
-(id)initWithAnimation:(CCAnimation *)animation target:(CCSprite *)target;
-(void)start;
-(void)stop;
-(void)setFrame:(NSUInteger)frameIndex;

@end
