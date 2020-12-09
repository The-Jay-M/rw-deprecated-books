//
//  ActionButton.h
//  PompaDroid
//
//  Created by Ray Wenderlich on 2/12/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class ActionButton;

@protocol ActionButtonDelegate <NSObject>

-(void)actionButtonWasPressed:(ActionButton *)actionButton;
-(void)actionButtonIsHeld:(ActionButton *)actionButton;
-(void)actionButtonWasReleased:(ActionButton *)actionButton;

@end

@interface ActionButton : CCSprite <CCTouchOneByOneDelegate> {
    float _radius;
    NSString *_prefix;
}

@property(nonatomic, weak)id <ActionButtonDelegate> delegate;
@property(nonatomic, assign)BOOL isHeld;

+(id)buttonWithPrefix:(NSString *)filePrefix radius:(float)radius;
-(id)initWithPrefix:(NSString *)filePrefix radius:(float)radius;

@end