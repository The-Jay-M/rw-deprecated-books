//
//  ActionDPad.h
//  PompaDroid
//
//  Created by Allen Tan on 6/11/14.
//
//

#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(NSInteger, ActionDPadDirection) {
    kActionDPadDirectionCenter = 0,
    kActionDPadDirectionUp,
    kActionDPadDirectionUpRight,
    kActionDPadDirectionRight,
    kActionDPadDirectionDownRight,
    kActionDPadDirectionDown,
    kActionDPadDirectionDownLeft,
    kActionDPadDirectionLeft,
    kActionDPadDirectionUpLeft
};

@class ActionDPad;

@protocol ActionDPadDelegate <NSObject>

- (void)actionDPad:(ActionDPad *)actionDPad
didChangeDirectionTo:(ActionDPadDirection)direction;

- (void)actionDPad:(ActionDPad *)actionDPad
isHoldingDirection:(ActionDPadDirection)direction;

- (void)actionDPadTouchEnded:(ActionDPad *)actionDPad;

@end

@interface ActionDPad : SKSpriteNode

@property (assign, nonatomic) ActionDPadDirection direction;
@property (weak, nonatomic) id <ActionDPadDelegate> delegate;
@property (assign, nonatomic) BOOL isHeld;

+ (instancetype)dPadWithPrefix:(NSString *)filePrefix
                        radius:(CGFloat)radius;
- (instancetype)initWithPrefix:(NSString *)filePrefix
                        radius:(CGFloat)radius;

- (void)update:(NSTimeInterval)delta;

@end
