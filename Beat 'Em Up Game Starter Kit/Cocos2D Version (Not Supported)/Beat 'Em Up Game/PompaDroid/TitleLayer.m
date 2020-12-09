//
//  TitleLayer.m
//  PompaDroid
//
//  Created by Ray Wenderlich on 2/8/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import "TitleLayer.h"
#import "GameScene.h"
#import "SimpleAudioEngine.h"
@implementation TitleLayer

-(id)init
{
    if ((self = [super init]))
    {
        [self setupTitle];
        self.touchEnabled = YES;
        
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"hit0.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"hit1.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"herodeath.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"enemydeath.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"blip.caf"];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"latin_industries.aifc"];
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.5];
        
    }
    return self;
}

-(void)setupTitle
{
    CCSprite *titleBG = [CCSprite spriteWithFile:@"bg_title.png"];
    titleBG.position = CENTER;
    [self addChild:titleBG];
    
    CCSprite *title = [CCSprite spriteWithFile:@"txt_title.png"];
    title.position = ccp(CENTER.x, CENTER.y + 66 * kPointFactor);
    [self addChild:title];
    
    CCSprite *start = [CCSprite spriteWithFile:@"txt_touchtostart.png"];
    start.position = ccp(CENTER.x, CENTER.y - 37.5 * kPointFactor);
    [self addChild:start];
    
    titleBG.scale *= kScaleFactor;
    title.scale *= kScaleFactor;
    start.scale *= kScaleFactor;
    
    [titleBG.texture setAliasTexParameters];
    [title.texture setAliasTexParameters];
    [start.texture setAliasTexParameters];
    
    start.tag = 1;
    CCBlink * blink = [CCBlink actionWithDuration:5.0 blinks:10];
    CCRepeat * repeat = [CCRepeatForever actionWithAction:blink];
    [start runAction:repeat];

}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"blip.caf"];

    //add level number 0 to GameScene creation
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[GameScene nodeWithLevel:0]]];
    CCSprite *start = (CCSprite *)[self getChildByTag:1];
    [start stopAllActions];
    start.visible = NO;
}

@end
