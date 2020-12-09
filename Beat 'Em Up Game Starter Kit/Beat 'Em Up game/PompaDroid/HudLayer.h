//
//  HudLayer.h
//  PompaDroid
//
//  Created by Allen Tan on 6/10/14.
//
//

#import <SpriteKit/SpriteKit.h>
#import "ActionDPad.h"
#import "ActionButton.h"

@interface HudLayer : SKNode

@property (strong, nonatomic) ActionDPad *dPad;
@property (strong, nonatomic) ActionButton *buttonA;
@property (strong, nonatomic) ActionButton *buttonB;

- (void)update:(NSTimeInterval)delta;
- (void)setHitPoints:(CGFloat)newHP fromMaxHP:(CGFloat)maxHP;
- (void)showGoMessage;
- (void)displayLevel:(NSInteger)level;
- (void)showMessage:(NSString *)message color:(SKColor *)color;

@end
