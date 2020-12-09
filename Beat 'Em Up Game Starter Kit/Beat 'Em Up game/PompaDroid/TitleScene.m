//
//  TitleScene.m
//  PompaDroid
//
//  Created by Allen Tan on 6/10/14.
//
//

#import "TitleScene.h"
#import "GameScene.h"
#import "SKAction+SKTExtras.h"
#import "SKTAudio.h"

@implementation TitleScene

- (instancetype)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        [self setupTitle];
        [[SKTAudio sharedInstance] playBackgroundMusic:@"latin_industries.aifc"];
    }
    
    return self;
}

- (void)setupTitle
{
    SKSpriteNode *titleBG =
    [SKSpriteNode spriteNodeWithImageNamed:@"bg_title"];
    
    titleBG.position = CENTER;
    [self addChild:titleBG];
    
    SKSpriteNode *title =
    [SKSpriteNode spriteNodeWithImageNamed:@"txt_title"];
    
    title.position =
    CGPointMake(CENTER.x, CENTER.y + 66 * kPointFactor);
    [self addChild:title];
    
    SKSpriteNode *start =
    [SKSpriteNode spriteNodeWithImageNamed:@"txt_touchtostart"];
    
    start.position =
    CGPointMake(CENTER.x, CENTER.y - 37.5 * kPointFactor);
    [self addChild:start];
    
    [titleBG setScale:kPointFactor];
    [title setScale:kPointFactor];
    [start setScale:kPointFactor];
    
    titleBG.texture.filteringMode = SKTextureFilteringNearest;
    title.texture.filteringMode = SKTextureFilteringNearest;
    start.texture.filteringMode = SKTextureFilteringNearest;
    
    start.name = @"StartText";
    SKAction *blinkAction = [SKAction blinkWithDuration:5.0 blinks:10];
    SKAction *repeatAction = [SKAction repeatActionForever:blinkAction];
    [start runAction:repeatAction];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self runAction:[SKAction playSoundFileNamed:@"blip.caf"
                               waitForCompletion:NO]];
    
    SKSpriteNode *start =
    (SKSpriteNode *)[self childNodeWithName:@"StartText"];
    
    [start removeAllActions];
    start.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PresentGame" object:self userInfo:@{@"Level" : @0}];
}


@end
