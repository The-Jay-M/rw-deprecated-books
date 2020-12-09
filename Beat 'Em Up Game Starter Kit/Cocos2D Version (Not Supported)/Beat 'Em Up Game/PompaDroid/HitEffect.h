//
//  HitEffect.h
//  PompaDroid
//
//  Created by Ray Wenderlich on 3/15/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface HitEffect : CCSprite {
    
}

@property(nonatomic, strong)id effectAction;

-(void)showEffectAtPosition:(CGPoint)position;

@end
