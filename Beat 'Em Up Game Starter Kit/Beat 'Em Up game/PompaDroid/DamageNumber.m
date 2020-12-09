//
//  DamageNumber.m
//  PompaDroid
//
//  Created by Allen Tan on 6/11/14.
//
//

#import "DamageNumber.h"
#import "SKAction+SKTExtras.h"

@implementation DamageNumber

- (void)cleanup
{
    self.damageAction = nil;
}

- (instancetype)init
{
    if (self = [super init]) {
        
        self.fontName = @"04b03";
        self.fontSize = 20 * kPointFactor;
        self.colorBlendFactor = 1.0;
        self.color = [UIColor redColor];
        self.damageAction = [SKAction sequence:@[[SKAction showNode:self], [SKAction moveBy:CGVectorMake(0.0, 40.0 * kPointFactor) duration:0.6], [SKAction hideNode:self]]];
        
    }
    return self;
}

- (void)showWithValue:(NSInteger)value
           fromOrigin:(CGPoint)origin
{
    self.text = [NSString stringWithFormat:@"%ld", (long)value];
    self.position = origin;
    [self removeAllActions];
    [self runAction:self.damageAction];
}

@end
