//
//  HudLayer.m
//  PompaDroid
//
//  Created by Allen Tan on 6/10/14.
//
//

#import "HudLayer.h"
#import "UIColor+BGSK.h"
#import "SKAction+SKTExtras.h"

@interface HudLayer()

@property (strong, nonatomic) SKLabelNode *hitPointsLabel;
@property (strong, nonatomic) SKLabelNode *goLabel;
@property (strong, nonatomic) SKLabelNode *centerLabel;

@end

@implementation HudLayer

- (instancetype)init
{
    if (self = [super init])
    {
        //directional pad
        CGFloat radius = 64.0 * kPointFactor;
        _dPad = [ActionDPad dPadWithPrefix:@"dpad" radius:radius];
        _dPad.position = CGPointMake(radius, radius);
        _dPad.alpha = 0.5;
        [self addChild:_dPad];
        
        
        CGFloat buttonRadius = radius / 2.0;
        CGFloat padding = 8.0 * kPointFactor;
        
        _buttonB = [ActionButton buttonWithPrefix:@"button_b"
                                           radius:buttonRadius];
        
        _buttonB.position =
        CGPointMake(SCREEN.width - buttonRadius - padding,
                    buttonRadius * 2 + padding);
        
        _buttonB.alpha = 0.5;
        _buttonB.name = @"ButtonB";
        [self addChild:_buttonB];
        
        _buttonA =
        [ActionButton buttonWithPrefix:@"button_a"
                                radius:buttonRadius];
        
        _buttonA.position =
        CGPointMake(_buttonB.position.x - radius - padding,
                    buttonRadius + padding);
        
        _buttonA.alpha = 0.5;
        _buttonA.name = @"ButtonA";
        [self addChild:_buttonA];
        
        CGFloat xPadding = 10.0 * kPointFactor;
        CGFloat yPadding = 40.0 * kPointFactor;
        _hitPointsLabel = [SKLabelNode labelNodeWithFontNamed:@"04b03"];
        _hitPointsLabel.text = @"0";
        _hitPointsLabel.fontSize = 32 * kPointFactor;
        _hitPointsLabel.horizontalAlignmentMode =
        SKLabelHorizontalAlignmentModeLeft;
        _hitPointsLabel.position =
        CGPointMake(xPadding, SCREEN.height - yPadding);
        _hitPointsLabel.colorBlendFactor = 1.0;
        [self addChild:_hitPointsLabel];
        
        _goLabel = [SKLabelNode labelNodeWithFontNamed:@"04b03"];
        _goLabel.text = @"[GO>";
        _goLabel.fontSize = 32 * kPointFactor;
        _goLabel.horizontalAlignmentMode =
        SKLabelHorizontalAlignmentModeRight;
        _goLabel.position = CGPointMake(SCREEN.width - xPadding,
                                        SCREEN.height - yPadding);
        _goLabel.colorBlendFactor = 1.0;
        _goLabel.color = [UIColor fullHPColor];
        _goLabel.hidden = YES;
        [self addChild:_goLabel];
        
        _centerLabel = [SKLabelNode labelNodeWithFontNamed:@"04b03"];
        _centerLabel.text = @"LEVEL 1";
        _centerLabel.fontSize = 32 * kPointFactor;
        _centerLabel.colorBlendFactor = 1.0;
        _centerLabel.color = [UIColor midHPColor];
        _centerLabel.hidden = YES;
        [self addChild:_centerLabel];
    }
    
    return self;
}

- (void)displayLevel:(NSInteger)level
{
    self.centerLabel.text =
    [NSString stringWithFormat:@"LEVEL %ld", (long)level];
    
    [self.centerLabel runAction:[SKAction sequence:@[[SKAction moveTo:CGPointMake(SCREEN.width + 112 * kPointFactor, CENTER.y) duration:0], [SKAction showNode:self.centerLabel], [SKAction moveTo:CENTER duration:0.2], [SKAction waitForDuration:1.0], [SKAction moveTo:CGPointMake(-112 * kPointFactor, CENTER.y) duration:0.2], [SKAction hideNode:self.centerLabel]]]];
    
}

- (void)showGoMessage
{
    [self.goLabel removeAllActions];
    
    [self.goLabel runAction:[SKAction sequence:@[[SKAction showNode:self.goLabel], [SKAction blinkWithDuration:3.0 blinks:6], [SKAction hideNode:self.goLabel]]]];
}

- (void)update:(NSTimeInterval)delta
{
    [self.dPad update:delta];
}

- (void)setHitPoints:(CGFloat)newHP fromMaxHP:(CGFloat)maxHP{
    
    int wholeHP = newHP;
    
    self.hitPointsLabel.text =
    [NSString stringWithFormat:@"%d", wholeHP];
    
    CGFloat ratio = newHP / maxHP;
    
    if (ratio > 0.6) {
        self.hitPointsLabel.color = [UIColor fullHPColor];
    } else if (ratio > 0.2) {
        self.hitPointsLabel.color = [UIColor midHPColor];
    } else {
        self.hitPointsLabel.color = [UIColor lowHPColor];
    }
    
}

- (void)showMessage:(NSString *)message color:(UIColor *)color
{
    self.centerLabel.color = color;
    
    [self.centerLabel setText:message];
    
    [self.centerLabel runAction:[SKAction sequence:@[[SKAction moveTo:CGPointMake(SCREEN.width + 50 * kPointFactor, CENTER.y) duration:0], [SKAction showNode:self.centerLabel], [SKAction moveTo:CENTER duration:0.2], [SKAction waitForDuration:1.0], [SKAction moveTo:CGPointMake(-50 * kPointFactor, CENTER.y) duration:0.2], [SKAction hideNode:self.centerLabel]]]];
    
}

@end
