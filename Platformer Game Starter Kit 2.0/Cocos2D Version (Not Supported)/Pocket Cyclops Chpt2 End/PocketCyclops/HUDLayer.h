//
//  HUDLayer.h
//  ManOfPac
//
//  Created by Jacob Gundersen on 12/7/11.
//  Copyright 2011 Interrobang Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


typedef enum {
    kJoyDirectionLeft,
    kJoyDirectionRight,
    kJoyDirectionNone
} joystickDirection;

typedef enum {
    kJumpButtonOn,
    kJumpButtonOff
} jumpButtonState;

struct joyState {
    jumpButtonState jumpB;
    joystickDirection joyDirection;
};

@interface HUDLayer : CCLayer

-(joystickDirection)getJoystickDirection;
-(jumpButtonState)getJumpButtonState;
-(void)setLifeMeter:(NSNotification *)note;

@end
