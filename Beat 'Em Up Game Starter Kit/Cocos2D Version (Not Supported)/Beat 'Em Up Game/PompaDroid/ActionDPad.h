//
//  ActionDPad.h
//  PompaDroid
//
//  Created by Ray Wenderlich on 2/8/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum _ActionDPadDirection
{
    kActionDPadDirectionCenter = 0,
    kActionDPadDirectionUp,
    kActionDPadDirectionUpRight,
    kActionDPadDirectionRight,
    kActionDPadDirectionDownRight,
    kActionDPadDirectionDown,
    kActionDPadDirectionDownLeft,
    kActionDPadDirectionLeft,
    kActionDPadDirectionUpLeft
}ActionDPadDirection;

@class ActionDPad;

@protocol ActionDPadDelegate <NSObject>

-(void)actionDPad:(ActionDPad *)actionDPad didChangeDirectionTo:(ActionDPadDirection)direction;
-(void)actionDPad:(ActionDPad *)actionDPad isHoldingDirection:(ActionDPadDirection)direction;
-(void)actionDPadTouchEnded:(ActionDPad *)actionDPad;

@end

@interface ActionDPad : CCSprite <CCTouchOneByOneDelegate>{
    ActionDPadDirection _previousDirection;
    float _radius;
    NSString *_prefix;
}

@property(nonatomic, assign)ActionDPadDirection direction;
@property(nonatomic, weak)id <ActionDPadDelegate> delegate;
@property(nonatomic, assign)BOOL isHeld;

+(id)dPadWithPrefix:(NSString *)filePrefix radius:(float)radius;
-(id)initWithPrefix:(NSString *)filePrefix radius:(float)radius;

@end
