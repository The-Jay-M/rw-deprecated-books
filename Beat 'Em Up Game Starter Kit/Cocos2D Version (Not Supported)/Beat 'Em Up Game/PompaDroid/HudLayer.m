//
//  HudLayer.m
//  PompaDroid
//
//  Created by Ray Wenderlich on 2/8/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import "HudLayer.h"

@implementation HudLayer

-(id)init
{
    if ((self = [super init]))
    {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"joypad.plist"];
        
        float radius = 64.0 * kPointFactor;
        _dPad = [ActionDPad dPadWithPrefix:@"dpad" radius:radius];
        _dPad.position = ccp(radius, radius);
        _dPad.opacity = 128;
        [self addChild:_dPad];
        
        float buttonRadius = radius / 2.0;
        float padding = 8.0 * kPointFactor;

        _buttonB = [ActionButton buttonWithPrefix:@"button_b" radius:buttonRadius];
        _buttonB.position = ccp(SCREEN.width - buttonRadius - padding, buttonRadius * 2 + padding   );
        _buttonB.opacity = 128;
        _buttonB.tag = kTagButtonB;
        [self addChild:_buttonB];

        _buttonA = [ActionButton buttonWithPrefix:@"button_a" radius:buttonRadius];
        _buttonA.position = ccp(_buttonB.position.x - radius - padding, buttonRadius + padding);
        _buttonA.opacity = 128;
        _buttonA.tag = kTagButtonA;
        [self addChild:_buttonA];
        
        float xPadding = 10.0 * kPointFactor;
        float yPadding = 18.0 * kPointFactor;
        _hitPointsLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"HudFont.fnt"];
        _hitPointsLabel.anchorPoint = ccp(0.0, 0.5);
        _hitPointsLabel.position = ccp(xPadding, SCREEN.height - _hitPointsLabel.contentSize.height/2 - yPadding);
        [self addChild:_hitPointsLabel];
        
        _goLabel = [CCLabelBMFont labelWithString:@"[GO>" fntFile:@"HudFont.fnt"];
        _goLabel.anchorPoint = ccp(1.0, 0.5);
        _goLabel.position = ccp(SCREEN.width - xPadding, SCREEN.height - _goLabel.contentSize.height/2 - yPadding);
        _goLabel.color = COLOR_FULLHP;
        _goLabel.visible = NO;
        [self addChild:_goLabel];
        
        _centerLabel = [CCLabelBMFont labelWithString:@"LEVEL 1" fntFile:@"HudFont.fnt"];
        _centerLabel.color = COLOR_MIDHP;
        _centerLabel.visible = NO;
        [self addChild:_centerLabel];

    }
    return self;
}

-(void)setHitPoints:(float)newHP fromMaxHP:(float)maxHP
{
    int wholeHP = newHP;
    
    [_hitPointsLabel setString:[NSString stringWithFormat:@"%d", wholeHP]];
    
    float ratio = newHP / maxHP;
    
    if (ratio > 0.6)
    {
        _hitPointsLabel.color = COLOR_FULLHP;
    }
    else if (ratio > 0.2)
    {
        _hitPointsLabel.color = COLOR_MIDHP;
    }
    else
    {
        _hitPointsLabel.color = COLOR_LOWHP;
    }
}

-(void)showGoMessage
{
    [_goLabel stopAllActions];
    [_goLabel runAction:[CCSequence actions: [CCShow action], [CCBlink actionWithDuration:3.0 blinks:6], [CCHide action], nil]];
}

-(void)displayLevel:(int)level
{
    [_centerLabel setString:[NSString stringWithFormat:@"LEVEL %d", level]];
    [_centerLabel runAction:[CCSequence actions: [CCPlace actionWithPosition:ccp(SCREEN.width + _centerLabel.contentSize.width/2, CENTER.y)], [CCShow action], [CCMoveTo actionWithDuration:0.2 position:CENTER], [CCDelayTime actionWithDuration:1.0], [CCMoveTo actionWithDuration:0.2 position:ccp(-_centerLabel.contentSize.width/2, CENTER.y)], [CCHide action], nil]];
}

-(void)showMessage:(NSString *)message color:(ccColor3B)color
{
    _centerLabel.color = color;
    [_centerLabel setString:message];
    [_centerLabel runAction:[CCSequence actions: [CCPlace actionWithPosition:ccp(SCREEN.width + _centerLabel.contentSize.width/2, CENTER.y)], [CCShow action], [CCMoveTo actionWithDuration:0.2 position:CENTER], [CCDelayTime actionWithDuration:1.0], [CCMoveTo actionWithDuration:0.2 position:ccp(-_centerLabel.contentSize.width/2, CENTER.y)], [CCHide action], nil]];
}

@end
