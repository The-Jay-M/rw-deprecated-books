//
//  DamageNumber.h
//  PompaDroid
//
//  Created by Allen Tan on 6/11/14.
//
//

#import <SpriteKit/SpriteKit.h>

@interface DamageNumber : SKLabelNode

@property (strong, nonatomic) SKAction *damageAction;

- (void)showWithValue:(NSInteger)value
           fromOrigin:(CGPoint)origin;

- (void)cleanup;

@end
