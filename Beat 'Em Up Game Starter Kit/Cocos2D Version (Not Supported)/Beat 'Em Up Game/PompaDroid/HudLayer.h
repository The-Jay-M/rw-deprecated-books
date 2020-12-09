//
//  HudLayer.h
//  PompaDroid
//
//  Created by Ray Wenderlich on 2/8/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ActionDPad.h"
#import "ActionButton.h"

@interface HudLayer : CCLayer {
    CCLabelBMFont *_hitPointsLabel;
    CCLabelBMFont *_goLabel;
    CCLabelBMFont *_centerLabel;
}

-(void)setHitPoints:(float)newHP fromMaxHP:(float)maxHP;
-(void)showGoMessage;
-(void)displayLevel:(int)level;
-(void)showMessage:(NSString *)message color:(ccColor3B)color;

@property(nonatomic, weak)ActionDPad *dPad;
@property(nonatomic, weak)ActionButton *buttonA;
@property(nonatomic, weak)ActionButton *buttonB;

@end
